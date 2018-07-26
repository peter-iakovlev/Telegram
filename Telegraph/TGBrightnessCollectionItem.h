#import "TGCollectionItem.h"

@interface TGBrightnessCollectionItem : TGCollectionItem

@property (nonatomic, assign) CGFloat value;
@property (nonatomic, copy) void (^valueChanged)(CGFloat);
@property (nonatomic, copy) void (^interactionEnded)(void);

@property (nonatomic, assign) CGFloat markerValue;

@end
