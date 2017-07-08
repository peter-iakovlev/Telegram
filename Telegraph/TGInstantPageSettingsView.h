#import <UIKit/UIKit.h>

#import "TGInstantPageLayout.h"

@interface TGInstantPageSettingsView : UIView

@property (nonatomic, copy) void (^dismiss)(void);
@property (nonatomic, copy) CGPoint (^buttonPosition)(void);

@property (nonatomic, copy) void (^themeChanged)(TGInstantPagePresentationTheme theme);
@property (nonatomic, copy) void (^fontSizeChanged)(CGFloat multiplier);
@property (nonatomic, copy) void (^fontSerifChanged)(bool serif);
@property (nonatomic, copy) void (^autoNightThemeChanged)(bool enabled);

- (instancetype)initWithFrame:(CGRect)frame presentation:(TGInstantPagePresentation *)presentation autoNightThemeEnabled:(bool)autoNightThemeEnabled;

- (void)updatePresentation:(TGInstantPagePresentation *)presentation animated:(bool)animated;

- (void)transitionIn;
- (void)transitionOut:(void (^)(void))completion;

@end
