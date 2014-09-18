#import "TGContactBinding.h"

@implementation TGContactBinding

@synthesize phoneId = _phoneId;

@synthesize firstName = _firstName;
@synthesize lastName = _lastName;

@synthesize phoneNumber = _phoneNumber;

- (bool)equalsToContactBinding:(TGContactBinding *)another
{
    if (_phoneId != another.phoneId)
        return false;
    if ((_firstName == nil) != (another.firstName != nil) || (_firstName != nil && ![_firstName isEqualToString:another.firstName]))
        return false;
    if ((_lastName == nil) != (another.lastName != nil) || (_lastName != nil && ![_lastName isEqualToString:another.lastName]))
        return false;
    if ((_phoneNumber == nil) != (another.phoneNumber != nil) || (_phoneNumber != nil && ![_phoneNumber isEqualToString:another.phoneNumber]))
        return false;
    
    return true;
}

@end
