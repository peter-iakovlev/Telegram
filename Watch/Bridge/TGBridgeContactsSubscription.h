#import "TGBridgeSubscription.h"

@interface TGBridgeContactsSubscription : TGBridgeSubscription

@property (nonatomic, readonly) NSString *query;

- (instancetype)initWithQuery:(NSString *)query;

@end
