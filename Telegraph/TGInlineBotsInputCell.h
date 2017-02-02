#import <UIKit/UIKit.h>

@class TGUser;

@interface TGInlineBotsInputCell : UICollectionViewCell

@property (nonatomic, copy) void (^tapped)(TGUser *);
@property (nonatomic, strong) TGUser *user;

- (void)animateIn;
- (void)animateOut;

- (void)setFocused:(bool)focused animated:(bool)animated;

@end
