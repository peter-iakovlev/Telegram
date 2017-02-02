#import "TGBridgeContextService.h"
#import "TGChatListSignals.h"

#import "PGCamera.h"

#import "TGBridgeChat+TGConversation.h"
#import "TGBridgeUser+TGUser.h"

#import "TGDatabase.h"

const NSUInteger TGBridgeContextChatsCount = 4;

@interface TGBridgeContextService ()
{
    SSignal *_chatListSignal;
    SMetaDisposable *_disposable;
}
@end


@implementation TGBridgeContextService

- (instancetype)initWithServer:(TGBridgeServer *)server
{
    self = [super initWithServer:server];
    if (self != nil)
    {
        _chatListSignal = [[server server] mapToSignal:^SSignal *(TGBridgeServer *server) {
            return [server serviceSignalForKey:@"chatList" producer:^SSignal *{
                return [TGChatListSignals chatListWithLimit:24];
            }];
        }];
        
        __weak TGBridgeContextService *weakSelf = self;
        _disposable = [[SMetaDisposable alloc] init];
        [_disposable setDisposable:[[_chatListSignal mapToSignal:^SSignal *(id next)
        {
            return [[SSignal single:next] delay:2.0 onQueue:[SQueue concurrentDefaultQueue]];
        }] startWithNext:^(NSArray *next)
        {
            __strong TGBridgeContextService *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            bool micAccessAllowed = ([PGCamera microphoneAuthorizationStatus] == PGMicrophoneAuthorizationStatusAuthorized);
            
            if (next.count > 0)
            {
                NSUInteger limit = MIN(next.count, TGBridgeContextChatsCount);
                
                NSMutableArray *bridgeChats = [[NSMutableArray alloc] init];
                NSMutableDictionary *bridgeUsers = [[NSMutableDictionary alloc] init];
                
                NSMutableIndexSet *userIds = [[NSMutableIndexSet alloc] init];
                
                NSUInteger i = 0;
                for (TGConversation *chat in next)
                {
                    if (chat.isBroadcast || chat.isEncrypted)
                        continue;
                    
                    if (i >= limit)
                        break;
                    
                    TGBridgeChat *bridgeChat = [TGBridgeChat chatWithTGConversation:chat];
                    if (bridgeChat != nil)
                    {
                        [bridgeChats addObject:bridgeChat];
                        [userIds addIndexes:[bridgeChat involvedUserIds]];
                    }
                    
                    i++;
                }
                
                [userIds enumerateIndexesUsingBlock:^(NSUInteger userId, __unused BOOL *stop)
                {
                    TGBridgeUser *bridgeUser = [TGBridgeUser userWithTGUser:[[TGDatabase instance] loadUser:(int)userId]];
                    if (bridgeUser != nil)
                        bridgeUsers[@(userId)] = bridgeUser;
                }];
                
                [[[strongSelf.server server] onNext:^(TGBridgeServer *server) {
                    [server setStartupData:@{ TGBridgeChatsArrayKey: bridgeChats, TGBridgeUsersDictionaryKey: bridgeUsers } micAccessAllowed:micAccessAllowed];
                }] startWithNext:nil];
            }
            else
            {
                [[[strongSelf.server server] onNext:^(TGBridgeServer *server) {
                    [server setStartupData:nil micAccessAllowed:micAccessAllowed];
                }] startWithNext:nil];
            }
        }]];
    }
    return self;
}

- (void)dealloc
{
    [_disposable dispose];
}

@end
