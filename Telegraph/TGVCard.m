#import "TGVCard.h"

@interface TGVCardValue ()
{
@protected
    ABPropertyID _property;
}
@end

@implementation TGVCardValue

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        arc4random_buf(&_uniqueId, sizeof(int64_t));
    }
    return self;
}

- (ABPropertyID)property
{
    return _property;
}

- (void)writeValueInPerson:(ABRecordRef)__unused person
{
}

@end

@implementation TGVCardValueString

- (instancetype)initWithProperty:(ABPropertyID)property string:(NSString *)string
{
    self = [super init];
    if (self != nil)
    {
        _property = property;
        _value = string;
    }
    return self;
}

- (void)writeValueInPerson:(ABRecordRef)person
{
    if (_value.length > 0)
        ABRecordSetValue(person, _property, (__bridge CFTypeRef)(_value), NULL);
}

@end

@implementation TGVCardValueDate

- (instancetype)initWithProperty:(ABPropertyID)property date:(NSDate *)date
{
    self = [super init];
    if (self != nil)
    {
        _property = property;
        _value = date;
    }
    return self;
}

- (void)writeValueInPerson:(ABRecordRef)person
{
    if (_value != nil)
        ABRecordSetValue(person, _property, (__bridge CFTypeRef)(_value), NULL);
}

@end

@implementation TGVCardValueArrayItem

- (instancetype)initWithLabel:(NSString *)label value:(id)value
{
    self = [super init];
    if (self != nil)
    {
        arc4random_buf(&_uniqueId, sizeof(int64_t));
        _label = label;
        _value = value;
    }
    return self;
}

@end

@implementation TGVCardValueArray

- (instancetype)initWithProperty:(ABPropertyID)property values:(NSArray<TGVCardValueArrayItem<id> *> *)values objectType:(Class)objectType
{
    self = [super init];
    if (self != nil)
    {
        _property = property;
        _values = values;
        _objectType = objectType;
    }
    return self;
}

- (void)writeValueInPerson:(ABRecordRef)person
{
    if (_values.count > 0) {
        ABMutableMultiValueRef multiValue = ABMultiValueCreateMutable(_objectType == [NSString class] ? kABMultiStringPropertyType : kABMultiDictionaryPropertyType);
        
        for (TGVCardValueArrayItem *value in _values) {
            ABMultiValueAddValueAndLabel(multiValue, (__bridge CFTypeRef)(value.value), (__bridge CFStringRef)(value.label), NULL);
        };
        ABRecordSetValue(person, _property, multiValue, nil);
        
        CFRelease(multiValue);
    }
}

@end

@implementation TGVCard

- (instancetype)initWithString:(NSString *)string
{
    if (string.length == 0)
        return nil;
    
    return [self initWithData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (instancetype)initWithData:(NSData *)data
{
    ABAddressBookRef book = ABAddressBookCreate();
    ABRecordRef defaultSource = ABAddressBookCopyDefaultSource(book);
    CFArrayRef vCardPeople = ABPersonCreatePeopleInSourceWithVCardRepresentation(defaultSource, (__bridge CFDataRef)(data));
    if (vCardPeople == NULL || CFArrayGetCount(vCardPeople) == 0) {
        if (vCardPeople != NULL)
            CFRelease(vCardPeople);
        if (defaultSource != NULL)
            CFRelease(defaultSource);
        if (book != NULL)
            CFRelease(book);
        
        return nil;
    }
    
    CFIndex index = 0;
    ABRecordRef person = CFArrayGetValueAtIndex(vCardPeople, index);
    
    if (vCardPeople != NULL)
        CFRelease(vCardPeople);
    if (defaultSource != NULL)
        CFRelease(defaultSource);
    if (book != NULL)
        CFRelease(book);
    
    return [self initWithPerson:person];
}

- (instancetype)initWithPerson:(ABRecordRef)person
{
    self = [super init];
    if (self != nil)
    {
        TGVCardValueString *(^getStringValueProperty)(ABPropertyID) = ^TGVCardValueString *(ABPropertyID property) {
            NSString *value = (__bridge_transfer NSString *)ABRecordCopyValue(person, property);
            if (value.length > 0) {
                return [[TGVCardValueString alloc] initWithProperty:property string:value];
            } else {
                return nil;
            }
        };
        
        TGVCardValueDate *(^getDateValueProperty)(ABPropertyID) = ^TGVCardValueDate *(ABPropertyID property) {
            NSDate *value = (__bridge_transfer NSDate *)ABRecordCopyValue(person, property);
            if (value != nil) {
                return [[TGVCardValueDate alloc] initWithProperty:property date:value];
            } else {
                return nil;
            }
        };
        
        void (^getMultiValuePropertyValues)(ABPropertyID, NSMutableArray *) = ^(ABPropertyID property, NSMutableArray *array) {
            ABMultiValueRef values = ABRecordCopyValue(person, property);
            NSInteger valueCount = (values == NULL) ? 0 : ABMultiValueGetCount(values);
            
            for (CFIndex i = 0; i < valueCount; i++) {
                NSString *label = (__bridge NSString *)(ABMultiValueCopyLabelAtIndex(values, i));
                id value = (__bridge id)(ABMultiValueCopyValueAtIndex(values, i));

                TGVCardValueArrayItem *item = [[TGVCardValueArrayItem alloc] initWithLabel:label value:value];
                if (item != nil) {
                    [array addObject:item];
                }
            }
            
            if (values != NULL)
                CFRelease(values);
        };
        
        TGVCardValueArray *(^getMultiStringValueProperty)(ABPropertyID) = ^TGVCardValueArray *(ABPropertyID property) {
            NSMutableArray<TGVCardValueArrayItem<NSString *> *> *array = [[NSMutableArray alloc] init];
            getMultiValuePropertyValues(property, array);
            
            if (array.count > 0) {
                return [[TGVCardValueArray alloc] initWithProperty:property values:array objectType:[NSString class]];
            } else {
                return nil;
            }
        };
        
        TGVCardValueArray *(^getMultiDictionaryValueProperty)(ABPropertyID) = ^TGVCardValueArray *(ABPropertyID property) {
            NSMutableArray<TGVCardValueArrayItem<NSDictionary *> *> *array = [[NSMutableArray alloc] init];
            getMultiValuePropertyValues(property, array);
            
            if (array.count > 0) {
                return [[TGVCardValueArray alloc] initWithProperty:property values:array objectType:[NSDictionary class]];
            } else {
                return nil;
            }
        };
        
        _firstName = getStringValueProperty(kABPersonFirstNameProperty);
        _lastName = getStringValueProperty(kABPersonLastNameProperty);
        _middleName = getStringValueProperty(kABPersonMiddleNameProperty);
        _prefix = getStringValueProperty(kABPersonPrefixProperty);
        _suffix = getStringValueProperty(kABPersonSuffixProperty);
        _organization = getStringValueProperty(kABPersonOrganizationProperty);
        _jobTitle = getStringValueProperty(kABPersonJobTitleProperty);
        _department = getStringValueProperty(kABPersonDepartmentProperty);
        _phones = getMultiStringValueProperty(kABPersonPhoneProperty);
        _emails = getMultiStringValueProperty(kABPersonEmailProperty);
        _urls = getMultiStringValueProperty(kABPersonURLProperty);
        _addresses = getMultiDictionaryValueProperty(kABPersonAddressProperty);
        _birthday = getDateValueProperty(kABPersonBirthdayProperty);
        _socialProfiles = getMultiDictionaryValueProperty(kABPersonSocialProfileProperty);
        _instantMessengers = getMultiDictionaryValueProperty(kABPersonInstantMessageProperty);
        
    }
    return self;
}

- (NSString *)fileName
{
    if (self.firstName.value.length > 0 || self.lastName.value.length > 0)
    {
        NSMutableArray *components = [[NSMutableArray alloc] init];
        if (self.firstName.value.length > 0)
            [components addObject:self.firstName.value];
        if (self.lastName.value.length > 0)
            [components addObject:self.lastName.value];
        return [components componentsJoinedByString:@" "];
    }
    else if (self.organization.value.length > 0)
    {
        return self.organization.value;
    }
    else
    {
        return @"card";
    }
}

- (bool)isPrimitive
{
    if (_organization != nil)
        return false;
    if (_jobTitle != nil)
        return false;
    if (_department != nil)
        return false;
    if (_phones.values.count > 1)
        return false;
    if (_emails.values.count > 0)
        return false;
    if (_urls.values.count > 0)
        return false;
    if (_addresses.values.count > 0)
        return false;
    if (_birthday != nil)
        return false;
    if (_socialProfiles.values.count > 0)
        return false;
    if (_instantMessengers.values.count > 0)
        return false;
    return true;
}

- (instancetype)vcardBySkippingItemsWithIds:(NSSet *)uniqueIds
{
    return [self vcardByCopying:false withIds:uniqueIds];
}

- (instancetype)vcardByKeepingItemsWithIds:(NSSet *)uniqueIds
{
    return [self vcardByCopying:true withIds:uniqueIds];
}

- (instancetype)vcardByCopying:(bool)keep withIds:(NSSet *)uniqueIds
{
    TGVCard *vcard = [[TGVCard alloc] init];
    vcard->_firstName = _firstName;
    vcard->_lastName = _lastName;
    
    vcard->_middleName = _middleName;
    vcard->_prefix = _prefix;
    vcard->_suffix = _suffix;
    
    if ((keep && [uniqueIds containsObject:@(_organization.uniqueId)]) || (!keep && ![uniqueIds containsObject:@(_organization.uniqueId)]))
        vcard->_organization = _organization;
    if ((keep && [uniqueIds containsObject:@(_jobTitle.uniqueId)]) || (!keep && ![uniqueIds containsObject:@(_jobTitle.uniqueId)]))
        vcard->_jobTitle = _jobTitle;
    if ((keep && [uniqueIds containsObject:@(_department.uniqueId)]) || (!keep && ![uniqueIds containsObject:@(_jobTitle.uniqueId)]))
        vcard->_department = _department;
    
    void (^processValues)(TGVCardValueArray *, TGVCardValueArray **) = ^(TGVCardValueArray *origin, TGVCardValueArray **target) {
        NSMutableArray *values = [[NSMutableArray alloc] init];
        for (TGVCardValueArrayItem *value in origin.values) {
            if ((keep && [uniqueIds containsObject:@(value.uniqueId)]) || (!keep && ![uniqueIds containsObject:@(value.uniqueId)])) {
                [values addObject:value];
            }
        }
        if (values.count > 0) {
            *target = [[TGVCardValueArray alloc] initWithProperty:origin.property values:values objectType:origin.objectType];
        }
    };

    TGVCardValueArray *phones = nil;
    processValues(_phones, &phones);
    vcard->_phones = phones;
    
    TGVCardValueArray *emails = nil;
    processValues(_emails, &emails);
    vcard->_emails = emails;
    
    TGVCardValueArray *urls = nil;
    processValues(_urls, &urls);
    vcard->_urls = urls;
    
    TGVCardValueArray *addresses = nil;
    processValues(_addresses, &addresses);
    vcard->_addresses = addresses;
        
    if ((keep && [uniqueIds containsObject:@(_birthday.uniqueId)]) || (!keep && ![uniqueIds containsObject:@(_birthday.uniqueId)]))
        vcard->_birthday = _birthday;
    
    TGVCardValueArray *socialProfiles = nil;
    processValues(_socialProfiles, &socialProfiles);
    vcard->_socialProfiles = socialProfiles;
    
    TGVCardValueArray *instantMessengers = nil;
    processValues(_instantMessengers, &instantMessengers);
    vcard->_instantMessengers = instantMessengers;
    
    return vcard;
}

- (NSString *)vcardString
{
    ABRecordRef newPerson = ABPersonCreate();
    
    if (self.firstName != nil)
        [self.firstName writeValueInPerson:newPerson];
    if (self.lastName != nil)
        [self.lastName writeValueInPerson:newPerson];
    if (self.middleName != nil)
        [self.middleName writeValueInPerson:newPerson];
    if (self.prefix != nil)
        [self.prefix writeValueInPerson:newPerson];
    if (self.suffix != nil)
        [self.suffix writeValueInPerson:newPerson];
    if (self.organization != nil)
        [self.organization writeValueInPerson:newPerson];
    if (self.jobTitle != nil)
        [self.jobTitle writeValueInPerson:newPerson];
    if (self.department != nil)
        [self.department writeValueInPerson:newPerson];
    if (self.phones != nil)
        [self.phones writeValueInPerson:newPerson];
    if (self.emails != nil)
        [self.emails writeValueInPerson:newPerson];
    if (self.urls != nil)
        [self.urls writeValueInPerson:newPerson];
    if (self.addresses != nil)
        [self.addresses writeValueInPerson:newPerson];
    if (self.birthday != nil)
        [self.birthday writeValueInPerson:newPerson];
    if (self.socialProfiles != nil)
        [self.socialProfiles writeValueInPerson:newPerson];
    if (self.instantMessengers != nil)
        [self.instantMessengers writeValueInPerson:newPerson];
    
    ABRecordRef people[1] = {
        newPerson
    };
    
    CFArrayRef peopleArray = CFArrayCreate(kCFAllocatorDefault, (const void **)&people, 1, NULL);
    NSData *vCardData = (__bridge NSData *)(ABPersonCreateVCardRepresentationWithPeople(peopleArray));
    NSString *vcard = [[NSString alloc] initWithData:vCardData encoding:NSUTF8StringEncoding];
    vcard = [vcard stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
    CFRelease(peopleArray);
    CFRelease(newPerson);
    
    return vcard;
}

@end
