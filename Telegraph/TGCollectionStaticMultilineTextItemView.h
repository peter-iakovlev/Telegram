#import "TGCollectionItemView.h"

@class TGModernTextViewModel;

@interface TGCollectionStaticMultilineTextItemView : TGCollectionItemView

+ (CGFloat)heightForWidth:(CGFloat)width textModel:(TGModernTextViewModel *)textModel;

- (void)setTextModel:(TGModernTextViewModel *)textModel;

- (bool)shouldDisplayContextMenu;

- (void)setFollowLink:(void (^)(NSString *))followLink;

@end
