#import "TGCollectionItem.h"

@interface TGUsernameCollectionItem : TGCollectionItem

@property (nonatomic, strong) NSString *username;
@property (nonatomic) bool usernameValid;
@property (nonatomic) bool usernameChecking;

@property (nonatomic, copy) void (^usernameChanged)(NSString *);

@end
