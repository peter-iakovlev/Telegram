#import "TGCollectionItemView.h"

@class TGModernTextViewModel;

@interface TGUpdateAppInfoItemView : TGCollectionItemView

+ (CGFloat)heightForWidth:(CGFloat)width textModel:(TGModernTextViewModel *)textModel;

- (void)setTitle:(NSString *)title;
- (void)setTextModel:(TGModernTextViewModel *)textModel;

- (void)setFollowLink:(void (^)(NSString *))followLink;

@end
