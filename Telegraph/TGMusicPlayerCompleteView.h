#import <UIKit/UIKit.h>

@interface TGMusicPlayerCompleteView : UIView

@property (nonatomic) CGFloat topInset;
@property (nonatomic, assign) bool preview;
@property (nonatomic, copy) void (^setTitle)(NSString *);
@property (nonatomic, copy) void (^actionsEnabled)(bool);

@property (nonatomic, copy) void (^dismissPressed)(void);
@property (nonatomic, copy) void (^actionsPressed)(void);
@property (nonatomic, copy) void (^playlistPressed)(void);

@property (nonatomic, copy) void (^statusBarStyleChange)(bool whiteOnBlack);

- (instancetype)initWithFrame:(CGRect)frame setTitle:(void (^)(NSString *))setTitle actionsEnabled:(void (^)(bool))actionsEnabled;

- (void)dismissToRect:(CGRect)rect completion:(void (^)(void))completion;

- (void)setGradientAlpha:(CGFloat)alpha;

- (bool)isSwipeGestureAllowedAtPoint:(CGPoint)point;

@end
