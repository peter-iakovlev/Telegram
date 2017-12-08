#import "TGCollectionItemView.h"

@interface TGSizeSliderCollectionItemView : TGCollectionItemView

@property (nonatomic, strong) void (^valueChanged)(int32_t value);
- (void)setValue:(int32_t)value;

@end
