#import <UIKit/UIKit.h>

@interface TGChangePhoneNumberHelpView : UIView

@property (nonatomic, copy) void (^changePhonePressed)();
@property (nonatomic, copy) void (^debugPressed)();

- (void)setInsets:(UIEdgeInsets)insets;

@end
