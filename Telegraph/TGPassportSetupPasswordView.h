#import <UIKit/UIKit.h>

@class TGPresentation;

@interface TGPassportSetupPasswordView : UIView

@property (nonatomic) bool request;
@property (nonatomic, copy) void (^setupPressed)(void);

- (void)setPresentation:(TGPresentation *)presentation;

@end
