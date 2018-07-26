#import "TGCollectionItemView.h"

@class TGModernTextViewModel;

@interface TGUserInfoTextCollectionItemView : TGCollectionItemView

+ (CGFloat)heightForWidth:(CGFloat)width textModel:(TGModernTextViewModel *)textModel;

- (void)setTitle:(NSString *)title;
- (void)setTextModel:(TGModernTextViewModel *)textModel;

- (void)setChecking:(bool)checking;
- (void)setIsChecked:(bool)checked animated:(bool)animated;

- (bool)shouldDisplayContextMenu;

- (void)setFollowLink:(void (^)(NSString *))followLink;
- (void)setHoldLink:(void (^)(NSString *))holdLink;

@end
