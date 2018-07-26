#import "TGUploadFileSignals.h"

#import "TL/TLMetaScheme.h"
#import <LegacyComponents/ActionStage.h>

@interface TGUploadFileHelper : NSObject <ASWatcher> {
    void (^_completion)(id);
    void (^_error)();
    void (^_progress)(CGFloat);
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGUploadFileHelper

- (instancetype)initWithCompletion:(void(^)(id))completion error:(void (^)())error progress:(void (^)(CGFloat))progress {
    self = [super init];
    if (self != nil) {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        _completion = [completion copy];
        _error = [error copy];
        _progress = [progress copy];
    }
    return self;
}

- (void)uploadData:(NSData *)data mediaTypeTag:(TGNetworkMediaTypeTag)mediaTypeTag {
    static int uploadIndex = 0;
    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/upload/(%duploadFileHelper)", uploadIndex++] options:@{@"data": data, @"mediaTypeTag": @(mediaTypeTag)} watcher:self];
}

- (void)uploadSecureData:(NSData *)data mediaTypeTag:(TGNetworkMediaTypeTag)mediaTypeTag {
    static int uploadIndex = 0;
    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/upload/(%duploadFileHelper)", uploadIndex++] options:@{ @"secure": @true, @"data": data, @"mediaTypeTag": @(mediaTypeTag)} watcher:self];
}

- (void)uploadPath:(NSString *)path liveData:(id)liveData mediaTypeTag:(TGNetworkMediaTypeTag)mediaTypeTag {
    static int uploadIndex = 100000;
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    options[@"file"] = path;
    options[@"mediaTypeTag"] = @(mediaTypeTag);
    if (liveData)
        options[@"liveData"] = liveData;
    
    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/upload/(%duploadFileHelper)", uploadIndex++] options:options watcher:self];
}

- (void)dealloc {
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)actorCompleted:(int)status path:(NSString *)__unused path result:(id)result {
    if (status == ASStatusSuccess) {
        if (_completion) {
            if (result[@"passportFile"] != nil)
                _completion(result[@"passportFile"]);
            else
                _completion(result[@"file"]);
        }
    } else {
        if (_error) {
            _error();
        }
    }
}

- (void)actorReportedProgress:(NSString *)__unused path progress:(float)progress
{
    if (_progress) {
        _progress(progress);
    }
}

@end

@implementation TGUploadFileSignals

+ (SSignal *)uploadedFileWithData:(NSData *)data mediaTypeTag:(TGNetworkMediaTypeTag)mediaTypeTag {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        TGUploadFileHelper *helper = [[TGUploadFileHelper alloc] initWithCompletion:^(TLInputFile *file) {
            [subscriber putNext:file];
            [subscriber putCompletion];
        } error:^{
            [subscriber putError:nil];
        } progress:nil];
        
        [helper uploadData:data mediaTypeTag:mediaTypeTag];
        
        return [[SBlockDisposable alloc] initWithBlock:^{
            [helper description]; // keep reference
        }];
    }];
}


+ (SSignal *)uploadedSecureFileWithData:(NSData *)data mediaTypeTag:(TGNetworkMediaTypeTag)mediaTypeTag {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        TGUploadFileHelper *helper = [[TGUploadFileHelper alloc] initWithCompletion:^(TLInputSecureFile *file) {
            [subscriber putNext:file];
            [subscriber putCompletion];
        } error:^{
            [subscriber putError:nil];
        } progress:^(CGFloat progress) {
            [subscriber putNext:@(progress)];
        }];
        
        [helper uploadSecureData:data mediaTypeTag:mediaTypeTag];
        
        return [[SBlockDisposable alloc] initWithBlock:^{
            [helper description]; // keep reference
        }];
    }];
}

+ (SSignal *)uploadedFileWithPath:(NSString *)path liveData:(id)liveData mediaTypeTag:(TGNetworkMediaTypeTag)mediaTypeTag {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        TGUploadFileHelper *helper = [[TGUploadFileHelper alloc] initWithCompletion:^(TLInputFile *file) {
            [subscriber putNext:file];
            [subscriber putCompletion];
        } error:^{
            [subscriber putError:nil];
        } progress:nil];
        
        [helper uploadPath:path liveData:liveData mediaTypeTag:mediaTypeTag];
        
        return [[SBlockDisposable alloc] initWithBlock:^{
            [helper description]; // keep reference
        }];
    }];
}

@end
