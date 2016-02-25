#import "TGCollectionItemView.h"

@class TGModernTextViewModel;

@interface TGUserInfoTextCollectionItemView : TGCollectionItemView

+ (CGFloat)heightForWidth:(CGFloat)width textModel:(TGModernTextViewModel *)textModel;

- (void)setTitle:(NSString *)title;
- (void)setTextModel:(TGModernTextViewModel *)textModel;

- (bool)shouldDisplayContextMenu;

- (void)setFollowLink:(void (^)(NSString *))followLink;

@end
