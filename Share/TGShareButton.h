#import <UIKit/UIKit.h>

@interface TGShareButton : UIButton

@property (nonatomic) bool modernHighlight;

@property (nonatomic, strong) UIImage *highlightImage;
@property (nonatomic) bool stretchHighlightImage;
@property (nonatomic, strong) UIColor *highlightBackgroundColor;
@property (nonatomic) UIEdgeInsets backgroundSelectionInsets;
@property (nonatomic) UIEdgeInsets extendedEdgeInsets;

@property (nonatomic, copy) void (^highlitedChanged)(bool highlighted);

- (void)setTitleColor:(UIColor *)color;

- (void)_setHighligtedAnimated:(bool)highlighted animated:(bool)animated;

@end
