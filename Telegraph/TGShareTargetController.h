#import "TGViewController.h"

@interface TGShareTargetController : TGViewController

@property (nonatomic, copy) void (^completionBlock)(NSArray *selectedPeerIds);

@end
