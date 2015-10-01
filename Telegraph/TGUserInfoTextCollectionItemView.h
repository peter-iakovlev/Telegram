#import "TGCollectionItemView.h"

@interface TGUserInfoTextCollectionItemView : TGCollectionItemView

+ (CGFloat)heightForWidth:(CGFloat)width text:(NSString *)text;

- (void)setTitle:(NSString *)title;
- (void)setText:(NSString *)text;

@end
