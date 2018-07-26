#import <LegacyComponents/LegacyComponents.h>

@class TGPresentation;

@interface TGShareTargetController : TGViewController

@property (nonatomic, strong) TGPresentation *presentation;
@property (nonatomic, copy) void (^completionBlock)(NSArray *selectedPeerIds);

@end
