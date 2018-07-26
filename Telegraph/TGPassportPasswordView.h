#import <UIKit/UIKit.h>

@class TGPresentation;

@interface TGPassportPasswordView : UIView

@property (nonatomic, copy) void (^nextPressed)(NSString *);
@property (nonatomic, copy) void (^forgottenPressed)(void);

- (void)setPresentation:(TGPresentation *)presentation;

- (void)setProgress:(bool)progress;
- (void)setHint:(NSString *)hint;
- (void)setRecoverable:(bool)recoverable;
- (void)setAccessDenied:(bool)accessDenied text:(NSString *)text animated:(bool)animated;
- (void)focus;

- (void)setFailed;

@end
