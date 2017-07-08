#import "TGCollectionItemView.h"

@interface TGUsernameCollectionItemView : TGCollectionItemView

@property (nonatomic, copy) void (^usernameChanged)(NSString *);
@property (nonatomic, copy) void (^returnPressed)();

- (void)setTitle:(NSString *)title;
- (void)setPlaceholder:(NSString *)placeholder;
- (void)setPrefix:(NSString *)prefix;
- (void)setSecureEntry:(bool)secureEntry;
- (void)setKeyboardType:(UIKeyboardType)keyboardType;
- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType;
- (void)setUsername:(NSString *)username;
- (void)setUsernameValid:(bool)usernameValid;
- (void)setUsernameChecking:(bool)usernameChecking;
- (void)setMinimalInset:(CGFloat)minimalInset;
- (void)setAutoCapitalize:(bool)autoCapitalize;

@end
