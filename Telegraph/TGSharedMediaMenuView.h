#import <UIKit/UIKit.h>

@interface TGSharedMediaMenuView : UIView

@property (nonatomic) NSUInteger selectedItemIndex;

@property (nonatomic, copy) void (^selectedItemIndexChanged)(NSUInteger);
@property (nonatomic, copy) void (^willHide)();

- (void)setItems:(NSArray *)items;
- (void)showAnimated:(bool)animated;
- (void)hideAnimated:(bool)animated;

@end
