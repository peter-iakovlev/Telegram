#import <UIKit/UIKit.h>

@interface TGModernConversationGenericContextResultsAssociatedPanelSwitchPm : UIView

@property (nonatomic, copy) void (^pressed)();
@property (nonatomic, strong) NSString *title;

- (void)setBackgroundColor:(UIColor *)backgroundColor separatorColor:(UIColor *)separatorColor accentColor:(UIColor *)accentColor;

@end
