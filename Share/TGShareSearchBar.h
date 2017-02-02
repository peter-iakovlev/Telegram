#import <UIKit/UIKit.h>

@interface TGShareSearchBar : UIView

+ (CGFloat)searchBarBaseHeight;
+ (CGFloat)searchBarScopeHeight;
- (CGFloat)baseHeight;

@property (nonatomic, weak) id<UISearchBarDelegate> delegate;

@property (nonatomic, strong) UITextField *customTextField;
@property (nonatomic, readonly) UITextField *maybeCustomTextField;

@property (nonatomic, strong) UIImageView *customBackgroundView;
@property (nonatomic, strong) UIImageView *customActiveBackgroundView;

@property (nonatomic) bool alwaysExtended;
@property (nonatomic) bool hidesCancelButton;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *placeholder;

@property (nonatomic) bool showActivity;
@property (nonatomic) bool delayActivity;

- (void)setShowsCancelButton:(bool)showsCancelButton animated:(bool)animated;

- (void)updateClipping:(CGFloat)clippedHeight;

@end
