#import <UIKit/UIKit.h>

#import <SSignalKit/SSignalKit.h>

@interface TGPaymentPasswordEntryControllerView : UIView

@property (nonatomic, copy) void (^dismiss)();
@property (nonatomic, copy) SSignal *(^payWithPassword)(NSString *password);

@property (nonatomic) UIEdgeInsets insets;

- (instancetype)initWithCardTitle:(NSString *)cardTitle;

- (void)animateIn;
- (void)animateOut:(void (^)())completion;

@end
