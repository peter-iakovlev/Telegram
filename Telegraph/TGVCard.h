#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface TGVCardValue : NSObject

@property (nonatomic, readonly) int64_t uniqueId;
@property (nonatomic, readonly) ABPropertyID property;

@end

@interface TGVCardValueString : TGVCardValue

@property (nonatomic, readonly) NSString *value;

@end

@interface TGVCardValueDate : TGVCardValue

@property (nonatomic, readonly) NSDate *value;

@end

@interface TGVCardValueArrayItem<__covariant ObjectType> : NSObject

@property (nonatomic, readonly) int64_t uniqueId;
@property (nonatomic, readonly) NSString *label;
@property (nonatomic, readonly) ObjectType value;

@end

@interface TGVCardValueArray : TGVCardValue

@property (nonatomic, readonly) NSArray<TGVCardValueArrayItem *> *values;
@property (nonatomic, readonly) Class objectType;

@end


@interface TGVCard : NSObject

@property (nonatomic, readonly) TGVCardValueString *firstName;
@property (nonatomic, readonly) TGVCardValueString *lastName;
@property (nonatomic, readonly) TGVCardValueString *middleName;
@property (nonatomic, readonly) TGVCardValueString *prefix;
@property (nonatomic, readonly) TGVCardValueString *suffix;

@property (nonatomic, readonly) TGVCardValueString *organization;
@property (nonatomic, readonly) TGVCardValueString *jobTitle;
@property (nonatomic, readonly) TGVCardValueString *department;

@property (nonatomic, readonly) TGVCardValueArray *phones;
@property (nonatomic, readonly) TGVCardValueArray *emails;
@property (nonatomic, readonly) TGVCardValueArray *urls;
@property (nonatomic, readonly) TGVCardValueArray *addresses;

@property (nonatomic, readonly) TGVCardValueDate *birthday;

@property (nonatomic, readonly) TGVCardValueArray *socialProfiles;
@property (nonatomic, readonly) TGVCardValueArray *instantMessengers;

@property (nonatomic, readonly) NSString *fileName;

- (instancetype)initWithString:(NSString *)string;
- (instancetype)initWithData:(NSData *)data;
- (instancetype)initWithPerson:(ABRecordRef)person;

- (bool)isPrimitive;

- (instancetype)vcardBySkippingItemsWithIds:(NSSet *)uniqueIds;
- (instancetype)vcardByKeepingItemsWithIds:(NSSet *)uniqueIds;
- (NSString *)vcardString;

@end
