#import "TGCollectionItemView.h"

@interface TGUsernameCollectionItemView : TGCollectionItemView

@property (nonatomic, copy) void (^usernameChanged)(NSString *);

- (void)setUsername:(NSString *)username;
- (void)setUsernameValid:(bool)usernameValid;
- (void)setUsernameChecking:(bool)usernameChecking;

@end
