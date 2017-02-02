#import <UIKit/UIKit.h>

@class TGCallSessionState;

@interface TGCallEncryptionKeyView : UIView

@property (nonatomic, copy) void (^backPressed)(void);
@property (nonatomic, weak) UIView *identiconView;

- (void)setState:(TGCallSessionState *)state duration:(NSTimeInterval)duration;

- (void)present;
- (void)dismiss;

@end
