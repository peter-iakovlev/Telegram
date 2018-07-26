#import "TGUserInfoTextCollectionItem.h"

@class CLPlacemark;

@interface TGUserInfoAddressCollectionItem : TGUserInfoTextCollectionItem

@property (nonatomic) SEL action;
@property (nonatomic, strong) NSDictionary *address;

@property (nonatomic, assign) int64_t uniqueId;

- (CLPlacemark *)placemark;

@end
