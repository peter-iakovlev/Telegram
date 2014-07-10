#import <Foundation/Foundation.h>

#import "TGPhonebookPhone.h"

@interface TGPhonebookEntry : NSObject

@property (nonatomic, strong, readonly) NSString *firstName;
@property (nonatomic, strong, readonly) NSString *lastName;
@property (nonatomic, strong, readonly) NSString *middleName;
@property (nonatomic, strong, readonly) NSString *organization;

@property (nonatomic, strong, readonly) NSArray *phones;

- (instancetype)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName middleName:(NSString *)middleName organization:(NSString *)organization phones:(NSArray *)phones;

@end
