#import "TGCollectionItemView.h"

@class TGModernTextViewModel;

@interface TGCollectionStaticMultilineTextItemViewTextView : UIButton {
    NSArray *_currentLinkSelectionViews;
    NSString *_currentLink;
}

@property (nonatomic, copy) void (^followLink)(NSString *);
@property (nonatomic, copy) void (^holdLink)(NSString *);
@property (nonatomic, readonly) bool trackingLink;
@property (nonatomic, strong) TGModernTextViewModel *textModel;

@end

@interface TGCollectionStaticMultilineTextItemView : TGCollectionItemView

+ (CGFloat)heightForWidth:(CGFloat)width textModel:(TGModernTextViewModel *)textModel;

- (void)setTextModel:(TGModernTextViewModel *)textModel;

- (bool)shouldDisplayContextMenu;

- (void)setFollowLink:(void (^)(NSString *))followLink;
- (void)setHoldLink:(void (^)(NSString *))holdLink;

@end
