#import "TGUploadFileSignals.h"

#import "TL/TLMetaScheme.h"
#import "ActionStage.h"

@interface TGUploadFileHelper : NSObject <ASWatcher> {
    void (^_completion)(TLInputFile *);
    void (^_error)();
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGUploadFileHelper

- (instancetype)initWithCompletion:(void(^)(TLInputFile *))completion error:(void (^)())error {
    self = [super init];
    if (self != nil) {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        _completion = [completion copy];
        _error = [error copy];
    }
    return self;
}

- (void)uploadData:(NSData *)data mediaTypeTag:(TGNetworkMediaTypeTag)mediaTypeTag {
    static int uploadIndex = 0;
    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/upload/(%duploadFileHelper)", uploadIndex++] options:@{@"data": data, @"mediaTypeTag": @(mediaTypeTag)} watcher:self];
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
            _completion(result[@"file"]);
        }
    } else {
        if (_error) {
            _error();
        }
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
        }];
        
        [helper uploadData:data mediaTypeTag:mediaTypeTag];
        
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
        }];
        
        [helper uploadPath:path liveData:liveData mediaTypeTag:mediaTypeTag];
        
        return [[SBlockDisposable alloc] initWithBlock:^{
            [helper description]; // keep reference
        }];
    }];
}

@end
