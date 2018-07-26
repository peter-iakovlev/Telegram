#import "TGCollectionItem.h"

@interface TGUserInfoUsernameCollectionItem : TGCollectionItem

@property (nonatomic) bool lastInList;

@property (nonatomic, strong) NSString *username;
@property (nonatomic) SEL action;
@property (nonatomic, strong) NSDictionary *userInfo;

@property (nonatomic, assign) bool checking;
@property (nonatomic, assign) bool isChecked;

@property (nonatomic, assign) int64_t uniqueId;

- (instancetype)initWithLabel:(NSString *)label username:(NSString *)username;

@end
