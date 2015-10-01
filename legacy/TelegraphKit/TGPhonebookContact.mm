#import "TGPhonebookContact.h"

#import "TGStringUtils.h"
#import "TGPhoneUtils.h"

@implementation TGPhoneNumber

@synthesize label = _label;
@synthesize number = _number;

@synthesize phoneId = _phoneId;

- (id)initWithLabel:(NSString *)label number:(NSString *)number
{
    self = [super init];
    if (self != nil)
    {
        _label = label;
        _number = number;
    }
    return self;
}

- (int)phoneId
{
    if (_phoneId == 0)
        _phoneId = phoneMatchHash([TGPhoneUtils cleanPhone:_number]);
    
    return _phoneId;
}

- (bool)isEqualToPhoneNumber:(TGPhoneNumber *)other
{
    if ((_label != nil) != (other.label != nil) || (_label != nil && ![_label isEqualToString:other.label]))
        return false;
    
    if ((_number != nil) != (other.number != nil) || (_number != nil && ![_number isEqualToString:other.number]))
        return false;
    
    return true;
}

- (bool)isEqualToPhoneNumberFuzzy:(TGPhoneNumber *)other
{
    if ((_label != nil) != (other.label != nil) || (_label != nil && ![_label isEqualToString:other.label]))
        return false;
    
    if ((_number != nil) != (other.number != nil) || (_number != nil && ![[TGPhoneUtils cleanPhone:_number] isEqualToString:[TGPhoneUtils cleanPhone:other.number]]))
        return false;
    
    return true;
}

@end

@implementation TGPhonebookContact

@synthesize nativeId = _nativeId;

@synthesize firstName = _firstName;
@synthesize lastName = _lastName;

@synthesize phoneNumbers = _phoneNumbers;

- (id)copyWithZone:(NSZone *)__unused zone
{
    TGPhonebookContact *newContact = [[TGPhonebookContact alloc] init];
    
    newContact.nativeId = _nativeId;
    newContact.firstName = _firstName;
    newContact.lastName = _lastName;
    newContact.phoneNumbers = [_phoneNumbers copy];
    
    return newContact;
}

- (void)fillPhoneHashToNativeMap:(std::map<int, int> *)pMap replace:(bool)replace
{
    for (TGPhoneNumber *numberDesc in _phoneNumbers)
    {
        if (replace)
            (*pMap)[[numberDesc phoneId]] = _nativeId;
        else
            pMap->insert(std::pair<int, int>([numberDesc phoneId], _nativeId));
    }
}

- (bool)isEqualToPhonebookContact:(TGPhonebookContact *)other
{
    if (_nativeId != other.nativeId)
        return false;
    
    if ((_firstName != nil) != (other.firstName != nil) || (_firstName != nil && ![_firstName isEqualToString:other.firstName]))
        return false;
    
    if ((_lastName != nil) != (other.lastName != nil) || (_lastName != nil && ![_lastName isEqualToString:other.lastName]))
        return false;
    
    if (_phoneNumbers.count != other.phoneNumbers.count)
        return false;
    
    int count = (int)_phoneNumbers.count;
    NSArray *otherPhoneNumbers = other.phoneNumbers;
    for (int i = 0; i < count; i++)
    {
        TGPhoneNumber *phoneNumber1 = [_phoneNumbers objectAtIndex:i];
        TGPhoneNumber *phoneNumber2 = [otherPhoneNumbers objectAtIndex:i];
        
        if (![phoneNumber1 isEqualToPhoneNumber:phoneNumber2])
            return false;
    }
    
    return true;
}

- (bool)hasEqualPhonesFuzzy:(NSArray *)otherPhoneNumbers
{
    if (_phoneNumbers.count != otherPhoneNumbers.count)
        return false;
    
    int count = (int)_phoneNumbers.count;
    for (int i = 0; i < count; i++)
    {
        TGPhoneNumber *phoneNumber1 = [_phoneNumbers objectAtIndex:i];
        TGPhoneNumber *phoneNumber2 = [otherPhoneNumbers objectAtIndex:i];
        
        if (![phoneNumber1 isEqualToPhoneNumberFuzzy:phoneNumber2])
            return false;
    }
    
    return true;
}

- (bool)containsPhoneId:(int)phoneId
{
    for (TGPhoneNumber *numberDesc in _phoneNumbers)
    {
        if (phoneId == numberDesc.phoneId)
            return true;
    }
    
    return false;
}

@end
