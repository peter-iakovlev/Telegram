#import "TGPhonebookEntry.h"

@implementation TGPhonebookEntry

- (instancetype)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName middleName:(NSString *)middleName organization:(NSString *)organization phones:(NSArray *)phones
{
    self = [super init];
    if (self != nil)
    {
        _firstName = firstName;
        _lastName = lastName;
        _middleName = middleName;
        _organization = organization;
        _phones = phones;
    }
    return self;
}

@end
