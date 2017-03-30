#import <UIKit/UIKit.h>

@class TGCallSessionState;

@interface TGCallEncryptionKeyView : UIView

@property (nonatomic, copy) void (^backPressed)(void);
@property (nonatomic, copy) CGPoint (^emojiInitialCenter)(void);

- (void)setState:(TGCallSessionState *)state;
- (void)setEmoji:(NSString *)emoji;

- (bool)present;
- (void)dismiss:(void (^)(void))completion;

@end
