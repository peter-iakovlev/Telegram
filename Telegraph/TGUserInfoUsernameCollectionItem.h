#import "TGCollectionItem.h"

@interface TGUserInfoUsernameCollectionItem : TGCollectionItem

@property (nonatomic, strong) NSString *username;
@property (nonatomic) SEL action;

- (instancetype)initWithLabel:(NSString *)label username:(NSString *)username;

@end
