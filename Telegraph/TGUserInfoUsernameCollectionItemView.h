#import "TGCollectionItemView.h"

@interface TGUserInfoUsernameCollectionItemView : TGCollectionItemView

- (void)setLabel:(NSString *)label;
- (void)setUsername:(NSString *)username;
- (void)setLastInList:(bool)lastInList;

- (void)setChecking:(bool)checking;
- (void)setIsChecked:(bool)checked animated:(bool)animated;

@end
