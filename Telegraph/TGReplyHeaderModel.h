#import "TGModernViewModel.h"

@class TGUser;
@class TGModernColorViewModel;
@class TGModernTextViewModel;

@interface TGReplyHeaderModel : TGModernViewModel
{
    TGModernColorViewModel *_lineModel;
    TGModernTextViewModel *_nameModel;
    TGModernTextViewModel *_textModel;
    bool _incoming;
    bool _system;
    CGFloat _leftInset;
}

- (instancetype)initWithPeer:(id)peer incoming:(bool)incoming text:(NSString *)text truncateTextInTheMiddle:(bool)truncateTextInTheMiddle textColor:(UIColor *)textColor leftInset:(CGFloat)leftInset system:(bool)system;

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition;

+ (UIColor *)colorForMediaText:(bool)incoming;
+ (CGFloat)thumbnailCornerRadius;

- (void)layoutForContainerSize:(CGSize)containerSize updateContent:(bool *)updateContent;

@end
