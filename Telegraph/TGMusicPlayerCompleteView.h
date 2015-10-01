#import <UIKit/UIKit.h>

@interface TGMusicPlayerCompleteView : UIView

@property (nonatomic) CGFloat topInset;
@property (nonatomic, copy) void (^setTitle)(NSString *);
@property (nonatomic, copy) void (^actionsEnabled)(bool);

- (instancetype)initWithFrame:(CGRect)frame setTitle:(void (^)(NSString *))setTitle actionsEnabled:(void (^)(bool))actionsEnabled;

@end
