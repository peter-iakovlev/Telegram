#import "TGCollectionItem.h"

@interface TGUserInfoUsernameCollectionItem : TGCollectionItem

@property (nonatomic, strong) NSString *username;

- (instancetype)initWithLabel:(NSString *)label username:(NSString *)username;

@end
