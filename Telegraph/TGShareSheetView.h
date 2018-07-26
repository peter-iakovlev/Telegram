#import <UIKit/UIKit.h>

@class TGShareSheetWindow;
@class TGPresentation;

@interface TGShareSheetView : UIView

+ (UIImage *)selectionBackgroundWithFirst:(bool)first last:(bool)last color:(UIColor *)color;

@property (nonatomic, strong) TGPresentation *presentation;
@property (nonatomic, assign) UIEdgeInsets safeAreaInset;
@property (nonatomic, weak) TGShareSheetWindow *attachmentSheetWindow;
@property (nonatomic, copy) void (^cancel)();

@property (nonatomic, strong) NSArray *items;

- (void)performAnimated:(bool)animated updates:(void (^)(void))updates completion:(void (^)(void))completion;
- (void)performAnimated:(bool)animated updates:(void (^)(void))updates stickToBottom:(bool)stickToBottom completion:(void (^)(void))completion;

- (void)scrollToBottomAnimated:(bool)animated;

- (void)animateIn;
- (void)animateInInitial:(bool)initial;

- (void)animateOut:(void (^)())completion;
- (void)animateOutForInterchange:(bool)interchange completion:(void (^)())completion;

@end
