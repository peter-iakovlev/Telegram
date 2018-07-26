#import <UIKit/UIKit.h>

@class TGPresentation;

@interface TGChangePhoneNumberHelpView : UIView

@property (nonatomic, strong) TGPresentation *presentation;

@property (nonatomic, copy) void (^changePhonePressed)();
@property (nonatomic, copy) void (^debugPressed)();

- (void)setInsets:(UIEdgeInsets)insets;

@end
