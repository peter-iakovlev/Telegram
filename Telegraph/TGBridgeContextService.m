#import "TGBridgeContextService.h"
#import "TGChatListSignals.h"
#import "TGBridgeServer.h"

#import "TGBridgeChat+TGConversation.h"
#import "TGBridgeUser+TGUser.h"

#import "TGDatabase.h"

const NSUInteger TGBridgeContextChatsCount = 4;

@interface TGBridgeContextService ()
{
    SSignal *_chatListSignal;
    SMetaDisposable *_disposable;
}

@property (nonatomic, weak) TGBridgeServer *server;

@end


@implementation TGBridgeContextService

- (instancetype)initWithServer:(TGBridgeServer *)server
{
    self = [super init];
    if (self != nil)
    {
        self.server = server;
        
        _chatListSignal = [server serviceSignalForKey:@"chatList" producer:^SSignal *
        {
            return [TGChatListSignals chatListWithLimit:24];
        }];
        
        __weak TGBridgeContextService *weakSelf = self;
        _disposable = [[SMetaDisposable alloc] init];
        [_disposable setDisposable:[_chatListSignal startWithNext:^(NSArray *next)
        {
            __strong TGBridgeContextService *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
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
                
                [strongSelf.server setStartupData:@{ TGBridgeChatsArrayKey: bridgeChats, TGBridgeUsersDictionaryKey: bridgeUsers }];
            }
            else
            {
                [strongSelf.server setStartupData:nil];
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
