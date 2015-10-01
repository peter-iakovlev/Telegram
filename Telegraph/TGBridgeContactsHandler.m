#import "TGBridgeContactsHandler.h"
#import "TGBridgeContactsSubscription.h"

#import "TGSearchPeersSignals.h"
#import "TGUser.h"

#import "TGBridgeUser+TGUser.h"

@implementation TGBridgeContactsHandler

+ (SSignal *)handlingSignalForSubscription:(TGBridgeSubscription *)subscription server:(TGBridgeServer *)__unused server
{
    if ([subscription isKindOfClass:[TGBridgeContactsSubscription class]])
    {
        TGBridgeContactsSubscription *contactsSubscription = (TGBridgeContactsSubscription *)subscription;
        
        return [[TGSearchPeersSignals searchPeersWithQuery:contactsSubscription.query] map:^NSArray *(NSDictionary *results)
        {
            NSArray *users = results[@"dialogs"];
            
            NSMutableArray *bridgeUsers = [[NSMutableArray alloc] init];
            
            for (id object in users)
            {
                if ([object isKindOfClass:[TGUser class]])
                {
                    TGUser *user = (TGUser *)object;
                    TGBridgeUser *bridgeUser = [TGBridgeUser userWithTGUser:user];
                    if (bridgeUser != nil)
                        [bridgeUsers addObject:bridgeUser];
                }
            }
            
            return bridgeUsers;
        }];
    }
    
    return [SSignal fail:nil];
}

+ (NSArray *)handledSubscriptions
{
    return @[ [TGBridgeContactsSubscription class] ];
}

@end
