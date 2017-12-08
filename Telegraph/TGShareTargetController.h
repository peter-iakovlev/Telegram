#import <LegacyComponents/LegacyComponents.h>

@interface TGShareTargetController : TGViewController

@property (nonatomic, copy) void (^completionBlock)(NSArray *selectedPeerIds);

@end
