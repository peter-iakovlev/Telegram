#import "TGPhonebookRecord.h"

@implementation TGPhonebookRecord

- (instancetype)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName middleName:(NSString *)middleName phoneNumbers:(NSArray *)phoneNumbers
{
    self = [super init];
    if (self != nil)
    {
        _firstName = firstName;
        _lastName = lastName;
        _middleName = middleName;
        _phoneNumbers = phoneNumbers;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGPhonebookRecord class]] && TGStringCompare(((TGPhonebookRecord *)object)->_firstName, _firstName) && TGStringCompare(((TGPhonebookRecord *)object)->_lastName, _lastName) && TGStringCompare(((TGPhonebookRecord *)object)->_middleName, _middleName) && TGObjectCompare(((TGPhonebookRecord *)object)->_phoneNumbers, _phoneNumbers);
}

@end
