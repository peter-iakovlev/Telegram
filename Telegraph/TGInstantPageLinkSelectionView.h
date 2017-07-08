#import <UIKit/UIKit.h>

@interface TGInstantPageLinkSelectionView : UIButton

@property (nonatomic, copy) void (^itemTapped)(id);
@property (nonatomic, copy) void (^itemLongPressed)(id);

- (instancetype)initWithFrame:(CGRect)frame rects:(NSArray<NSValue *> *)rects urlItem:(id)urlItem;
- (void)setColor:(UIColor *)color;

@end


@interface TGInstantPageTextSelectionView : UIView

@property (nonatomic, copy) void (^itemLongPressed)(TGInstantPageTextSelectionView *, NSString *);

- (instancetype)initWithFrame:(CGRect)frame rects:(NSArray<NSValue *> *)rects text:(NSString *)text;

- (void)setHighlighted:(bool)highlighted;
- (void)setColor:(UIColor *)color;

@end
