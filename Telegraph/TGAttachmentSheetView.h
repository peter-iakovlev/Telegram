#import <UIKit/UIKit.h>

@class TGAttachmentSheetWindow;

@interface TGAttachmentSheetView : UIView

@property (nonatomic, weak) TGAttachmentSheetWindow *attachmentSheetWindow;

@property (nonatomic, strong) NSArray *items;

- (void)performAnimated:(bool)animated updates:(void (^)(void))updates completion:(void (^)(void))completion;
- (void)performAnimated:(bool)animated updates:(void (^)(void))updates stickToBottom:(bool)stickToBottom completion:(void (^)(void))completion;

- (void)scrollToBottomAnimated:(bool)animated;

- (void)animateIn;
- (void)animateInInitial:(bool)initial;

- (void)animateOut:(void (^)())completion;
- (void)animateOutForInterchange:(bool)interchange completion:(void (^)())completion;

@end
