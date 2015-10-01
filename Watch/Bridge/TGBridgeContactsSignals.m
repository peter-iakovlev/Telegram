#import "TGBridgeContactsSignals.h"
#import "TGBridgeContactsSubscription.h"
#import "TGBridgeResponse.h"
#import "TGBridgeUser.h"
#import "TGBridgeClient.h"

@implementation TGBridgeContactsSignals

+ (SSignal *)searchContactsWithQuery:(NSString *)query
{
    return [[TGBridgeClient instance] requestSignalWithSubscription:[[TGBridgeContactsSubscription alloc] initWithQuery:query]];
}

@end
