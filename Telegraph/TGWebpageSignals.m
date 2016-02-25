#import "TGWebpageSignals.h"

#import "ActionStage.h"

#import "TL/TLMetaScheme.h"
#import "TGTelegramNetworking.h"

#import "TGWebPageMediaAttachment+Telegraph.h"

#import "TLWebPage_manual.h"

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

@end
