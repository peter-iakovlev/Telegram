#import "TGConversationSignals.h"

#import "ActionStage.h"
#import "TGDatabase.h"
#import "TGTelegramNetworking.h"
#import "TGTelegraph.h"

@interface TGConversationUpdatesHelper : NSObject <ASWatcher>
{
    int64_t _conversationId;
    void (^_conversationUpdated)(TGConversation *);
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGConversationUpdatesHelper

- (NSString *)watchPath
{
    return [[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _conversationId];
}

- (instancetype)initWithConversationId:(int64_t)conversationId conversationUpdated:(void (^)(TGConversation *))conversationUpdated
{
    self = [super init];
    if (self != nil)
    {
        _conversationId = conversationId;
        _conversationUpdated = [conversationUpdated copy];
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        [ActionStageInstance() watchForPath:[self watchPath] watcher:self];
        
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversationExtended/(%lld)", conversationId] options:@{@"conversationId": @(conversationId)} watcher:TGTelegraphInstance];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self fromPath:[self watchPath]];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:[self watchPath]])
    {
        TGConversation *conversation = ((SGraphObjectNode *)resource).object;
        if (_conversationUpdated)
            _conversationUpdated(conversation);
    }
}

@end

@implementation TGConversationSignals

+ (SSignal *)conversationWithPeerId:(int64_t)peerId
{
    SSignal *updatesSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGConversationUpdatesHelper *helper = [[TGConversationUpdatesHelper alloc] initWithConversationId:peerId conversationUpdated:^(TGConversation *conversation)
        {
            [subscriber putNext:conversation];
        }];
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [helper description]; //keep reference
        }];
    }];
    
    return [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:peerId];
        [subscriber putNext:conversation];
        [subscriber putCompletion];
        return nil;
    }] then:updatesSignal];
}

@end
