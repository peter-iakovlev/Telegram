#import "TGContactModel.h"
#import "TGLegacyDatabasePhoneUtils.h"

@implementation TGPhoneNumberModel

- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber label:(NSString *)label
{
    self = [super init];
    if (self != nil)
    {
        _phoneNumber = [TGLegacyDatabasePhoneUtils cleanInternationalPhone:phoneNumber forceInternational:false];
        _displayPhoneNumber = [TGLegacyDatabasePhoneUtils formatPhone:_phoneNumber forceInternational:false];
        _label = label;
    }
    return self;
}

@end

@implementation TGContactModel

- (instancetype)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName phoneNumbers:(NSArray *)phoneNumbers
{
    self = [super init];
    if (self != nil)
    {
        _firstName = firstName;
        _lastName = lastName;
        _phoneNumbers = phoneNumbers;
    }
    return self;
}

@end
