#import <UIKit/UIKit.h>

@interface TGInstantPageLinkSelectionView : UIButton

@property (nonatomic, copy) void (^itemTapped)(id);

- (instancetype)initWithFrame:(CGRect)frame rects:(NSArray<NSValue *> *)rects urlItem:(id)urlItem;

@end
