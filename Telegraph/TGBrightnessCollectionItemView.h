#import "TGCollectionItemView.h"

@interface TGBrightnessCollectionItemView : TGCollectionItemView

@property (nonatomic, strong) void (^valueChanged)(CGFloat value);
@property (nonatomic, strong) void (^interactionEnded)(void);
- (void)setValue:(CGFloat)value;
- (void)setMarkerValue:(CGFloat)value;

@end
