#import <Foundation/Foundation.h>

#import "TGPhonebookNumber.h"

@interface TGPhonebookRecord : NSObject

@property (nonatomic, strong, readonly) NSString *firstName;
@property (nonatomic, strong, readonly) NSString *lastName;
@property (nonatomic, strong, readonly) NSString *middleName;

@property (nonatomic, strong, readonly) NSArray *phoneNumbers;

- (instancetype)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName middleName:(NSString *)middleName phoneNumbers:(NSArray *)phoneNumbers;

@end
