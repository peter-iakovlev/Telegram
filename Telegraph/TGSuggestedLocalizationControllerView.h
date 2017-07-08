#import <UIKit/UIKit.h>

@class TGSuggestedLocalization;

@interface TGSuggestedLocalizationControllerView : UIView

@property (nonatomic, copy) void (^dismiss)();
@property (nonatomic, copy) void (^appliedLanguage)();
@property (nonatomic, copy) void (^other)();

@property (nonatomic) UIEdgeInsets insets;

- (instancetype)initWithSuggestedLocalization:(TGSuggestedLocalization *)suggestedLocalization;

- (void)animateIn;
- (void)animateOut:(void (^)())completion;

@end
