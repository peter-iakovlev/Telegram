#import "TGCollectionItemView.h"

@interface TGUsernameCollectionItemView : TGCollectionItemView

@property (nonatomic, copy) void (^usernameChanged)(NSString *);
@property (nonatomic, copy) void (^returnPressed)();
@property (nonatomic, copy) NSString *(^textPasted)(NSRange, NSString *);
@property (nonatomic, copy) bool (^shouldChangeText)(NSString *);

- (void)setTitle:(NSString *)title;
- (void)setTitleColor:(UIColor *)titleColor;

- (void)setPlaceholder:(NSString *)placeholder;
- (void)setPrefix:(NSString *)prefix;
- (void)setSecureEntry:(bool)secureEntry;
- (void)setKeyboardType:(UIKeyboardType)keyboardType;
- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType;
- (void)setUsername:(NSString *)username;
- (void)setUsernameValid:(bool)usernameValid;
- (void)setUsernameChecking:(bool)usernameChecking;
- (void)setClearable:(bool)clearable;
- (void)setMinimalInset:(CGFloat)minimalInset;
- (void)setAutocapitalizationType:(UITextAutocapitalizationType)autocapitalizationType;

- (bool)textFieldIsFirstResponder;

@end
