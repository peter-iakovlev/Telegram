#import <UIKit/UIKit.h>

@class TGWebPageMediaAttachment;

@interface TGEmbedPreviewView : UIView

@property (nonatomic, copy) void (^dismiss)();

- (instancetype)initWithFrame:(CGRect)frame webPage:(TGWebPageMediaAttachment *)webPage;

- (void)animateIn;
- (void)animateOut:(void (^)())completion;

@end
