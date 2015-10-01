#import "TGCollectionItemView.h"

@interface TGPasswordInputItemView : TGCollectionItemView

@property (nonatomic, copy) void (^passwordChanged)(NSString *);

- (void)setPlaceholder:(NSString *)placeholder;
- (void)setPassword:(NSString *)password;

- (void)makeTextFieldFirstResponder;

@end
