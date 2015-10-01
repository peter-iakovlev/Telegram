#import "TGCollectionItemView.h"

@interface TGUsernameCollectionItemView : TGCollectionItemView

@property (nonatomic, copy) void (^usernameChanged)(NSString *);

- (void)setTitle:(NSString *)title;
- (void)setPlaceholder:(NSString *)placeholder;
- (void)setPrefix:(NSString *)prefix;
- (void)setSecureEntry:(bool)secureEntry;
- (void)setKeyboardType:(UIKeyboardType)keyboardType;
- (void)setUsername:(NSString *)username;
- (void)setUsernameValid:(bool)usernameValid;
- (void)setUsernameChecking:(bool)usernameChecking;

@end
