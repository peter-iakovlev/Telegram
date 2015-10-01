#import "TGCollectionItemView.h"

@interface TGGroupInfoShareLinkLinkItemView : TGCollectionItemView

+ (CGSize)itemSizeForText:(NSString *)text maxWidth:(CGFloat)maxWidth;

- (void)setText:(NSString *)text;

@end
