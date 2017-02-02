#import "TGWebpageSignals.h"

#import "ActionStage.h"

#import "TL/TLMetaScheme.h"
#import "TGTelegramNetworking.h"

#import "TGWebPageMediaAttachment+Telegraph.h"

#import "TLWebPage_manual.h"

#import "TGDatabase.h"

@interface TGWebpageSignalsResourceHelper : NSObject <ASWatcher>

@property (nonatomic, copy) void (^handler)(NSArray *);
@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGWebpageSignalsResourceHelper

- (instancetype)initWithHandler:(void (^)(NSArray *))handler {
    self = [super init];
    if (self != nil) {
        self.handler = handler;
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
        [ActionStageInstance() watchForPath:@"/webpages" watcher:self];
    }
    return self;
}

- (void)dealloc {
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments {
    if ([path isEqualToString:@"/webpages"]) {
        if (_handler) {
            _handler(resource);
        }
    }
}

@end

@implementation TGWebpageSignals

+ (SSignal *)webpagePreview:(NSString *)url {
    return [SSignal defer:^SSignal *{
        TLRPCmessages_getWebPagePreview$messages_getWebPagePreview *getWebpagePreview = [[TLRPCmessages_getWebPagePreview$messages_getWebPagePreview alloc] init];
        
        getWebpagePreview.message = url;
        
        SAtomic *webpagePendingId = [[SAtomic alloc] initWithValue:nil];
        
        SSignal *resourceSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
            TGWebpageSignalsResourceHelper *helper = [[TGWebpageSignalsResourceHelper alloc] initWithHandler:^(NSArray *webpages) {
                NSNumber *nId = [webpagePendingId with:^id(id value) {
                    return value;
                }];
                if (nId != nil) {
                    for (TGWebPageMediaAttachment *webpage in webpages) {
                        if (webpage.webPageId == [nId longLongValue]) {
                            if (webpage.url != nil) {
                                [subscriber putNext:webpage];
                                [subscriber putCompletion];
                            } else {
                                TGLog(@"updateWebPage with pending page for %@", url);
                            }
                            break;
                        }
                    }
                }
            }];
            
            return [[SBlockDisposable alloc] initWithBlock:^{
                [helper description]; // keep reference
            }];
        }];
        
        SSignal *requestSignal = [[[TGTelegramNetworking instance] requestSignal:getWebpagePreview] mapToSignal:^SSignal *(TLMessageMedia *result) {
            if ([result isKindOfClass:[TLMessageMedia$messageMediaWebPage class]]) {
                TLMessageMedia$messageMediaWebPage *concreteMedia = (TLMessageMedia$messageMediaWebPage *)result;
                if ([concreteMedia.webpage isKindOfClass:[TLWebPage_manual class]]) {
                    return [SSignal single:[[TGWebPageMediaAttachment alloc] initWithTelegraphWebPageDesc:concreteMedia.webpage]];
                } else if ([concreteMedia.webpage isKindOfClass:[TLWebPage$webPagePending class]]) {
                    [webpagePendingId swap:@(((TLWebPage$webPagePending *)concreteMedia.webpage).n_id)];
                    return [SSignal complete];
                } else {
                    return [SSignal fail:nil];
                }
            } else {
                return [SSignal fail:nil];
            }
        }];
        
        SSignal *delaySignal = [[SSignal complete] delay:1.0 onQueue:[SQueue concurrentDefaultQueue]];
        
        SSignal *pollingSignal = [[SSignal mergeSignals:@[resourceSignal, [[requestSignal then:delaySignal] restart]]] take:1];
        
#ifdef DEBUG
        /*pollingSignal = [pollingSignal mapToSignal:^SSignal *(__unused id next) {
            return [SSignal fail:nil];
        }];*/
#endif
        
        return pollingSignal;
    }];
}

+ (SSignal *)updatedWebpage:(TGWebPageMediaAttachment *)webPage {
    TLRPCmessages_getWebPage$messages_getWebPage *getWebPage = [[TLRPCmessages_getWebPage$messages_getWebPage alloc] init];
    getWebPage.url = webPage.url;
    getWebPage.n_hash = webPage.webPageHash;
    return [[[TGTelegramNetworking instance] requestSignal:getWebPage] mapToSignal:^SSignal *(TLWebPage *desc) {
        if ([desc isKindOfClass:[TLWebPage$webPageNotModified class]]) {
            return [SSignal complete];
        } else {
            TGWebPageMediaAttachment *updatedWebPage = [[TGWebPageMediaAttachment alloc] initWithTelegraphWebPageDesc:desc];
            if (updatedWebPage != nil) {
                return [TGDatabaseInstance() modify:^id{
                    [TGDatabaseInstance() updateWebpages:@[updatedWebPage]];
                    [ActionStageInstance() dispatchResource:@"/webpages" resource:@[updatedWebPage]];
                    return updatedWebPage;
                }];
            } else {
                return [SSignal complete];
            }
        }
    }];
}

+ (SSignal *)cachedOrRemoteWebpage:(int64_t)webPageId url:(NSString *)url {
    return [[TGDatabaseInstance() modify:^id{
        TGWebPageMediaAttachment *webPage = [TGDatabaseInstance() _webpageWithId:webPageId];
        if (webPage != nil && webPage.url.length != 0) {
            return [SSignal single:webPage];
        } else{
            TLRPCmessages_getWebPage$messages_getWebPage *getWebPage = [[TLRPCmessages_getWebPage$messages_getWebPage alloc] init];
            getWebPage.url = url;
            getWebPage.n_hash = 0;
            return [[[TGTelegramNetworking instance] requestSignal:getWebPage] mapToSignal:^SSignal *(TLWebPage *desc) {
                if ([desc isKindOfClass:[TLWebPage$webPageNotModified class]]) {
                    return [SSignal fail:nil];
                } else {
                    TGWebPageMediaAttachment *updatedWebPage = [[TGWebPageMediaAttachment alloc] initWithTelegraphWebPageDesc:desc];
                    if (updatedWebPage != nil) {
                        return [TGDatabaseInstance() modify:^id{
                            [TGDatabaseInstance() updateWebpages:@[updatedWebPage]];
                            [ActionStageInstance() dispatchResource:@"/webpages" resource:@[updatedWebPage]];
                            return updatedWebPage;
                        }];
                    } else {
                        return [SSignal fail:nil];
                    }
                }
            }];
        }
    }] switchToLatest];
}

@end
