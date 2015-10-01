#import "TGDownloadHistoryForNavigatingToMessageSignal.h"

#import "ActionStage.h"

@interface TGDownloadHistoryForNavigatingToMessageSignalHelper : NSObject <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;
@property (nonatomic, copy) void (^completion)();

@end

@implementation TGDownloadHistoryForNavigatingToMessageSignalHelper

- (instancetype)initWithPeerId:(int64_t)peerId messageId:(int32_t)messageId completion:(void (^)())completion
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        _completion = completion;
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/loadConversationAndMessageForSearch/(%" PRId64 ", %" PRId32 ")", peerId, messageId] options:@{@"peerId": @(peerId), @"messageId": @(messageId)} flags:0 watcher:self];
    }
    return self;
}

- (void)dealloc
{
    [self cancel];
}

- (void)cancel
{
    [ActionStageInstance() removeWatcher:self];
}

- (void)actorCompleted:(int)__unused status path:(NSString *)__unused path result:(id)__unused result
{
    if (_completion)
        _completion();
}

@end

@implementation TGDownloadHistoryForNavigatingToMessageSignal

+ (SSignal *)signalForPeerId:(int64_t)peerId messageId:(int32_t)messageId
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGDownloadHistoryForNavigatingToMessageSignalHelper *helper = [[TGDownloadHistoryForNavigatingToMessageSignalHelper alloc] initWithPeerId:peerId messageId:messageId completion:^
        {
            [subscriber putCompletion];
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [helper cancel];
        }];
    }];
}

@end
