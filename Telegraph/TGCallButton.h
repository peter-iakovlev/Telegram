#import <UIKit/UIKit.h>

@protocol TGPasscodeBackground;

@interface TGCallButton : UIButton

@property (nonatomic, assign) bool hasBorder;

@property (nonatomic, strong) UIColor *backColor;
@property (nonatomic, assign) CGFloat iconRotation;

- (void)setBackground:(NSObject<TGPasscodeBackground> *)background;
- (void)setAbsoluteOffset:(CGPoint)absoluteOffset;

+ (CGSize)buttonSize;

@end
