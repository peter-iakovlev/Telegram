#import <UIKit/UIKit.h>

@class TGUser;

@interface TGInlineBotsInputPanel : UIView

@property (nonatomic, copy) void (^botSelected)(TGUser *);

- (void)animateIn;
- (void)animateOut:(void (^)())completion;

- (void)setCurrentBot:(TGUser *)currentBot;

- (void)setBarOffset:(CGFloat)barOffset;

@end
