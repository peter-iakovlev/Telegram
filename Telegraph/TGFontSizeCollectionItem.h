#import "TGCollectionItem.h"

@interface TGFontSizeCollectionItem : TGCollectionItem

@property (nonatomic, assign) int32_t value;
@property (nonatomic, copy) void (^valueChanged)(int32_t);

@end
