#import <UIKit/UIKit.h>

@interface TGShareCommentView : UIView

@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, readonly) UITextView *textView;
@property (nonatomic, strong) NSString *placeholder;

@property (nonatomic, copy) void (^didBeginEditing)(void);
@property (nonatomic, copy) void (^heightChanged)(CGFloat height);

@property (nonatomic, strong, readonly) NSString *text;

@end
