#import "TGPassportForm.h"

#import <LegacyComponents/TGStringUtils.h>
#import <MTProtoKit/MTProtoKit.h>

#import "TLaccount_AuthorizationForm$account_authorizationForm.h"
#import "TLSecureValue$secureValue.h"
#import "TLSecureFile.h"

#import "TGTwoStepConfigSignal.h"
#import "TGPassportSignals.h"
#import "TGPassportFile.h"
#import "TGPassportErrors.h"

NSString *const TGPassportFormTypePersonalDetails = @"personal_details";
NSString *const TGPassportFormTypePassport = @"passport";
NSString *const TGPassportFormTypeDriversLicense = @"driver_license";
NSString *const TGPassportFormTypeIdentityCard = @"identity_card";
NSString *const TGPassportFormTypeInternalPassport = @"internal_passport";
NSString *const TGPassportFormTypeAddress = @"address";
NSString *const TGPassportFormTypeUtilityBill = @"utility_bill";
NSString *const TGPassportFormTypeBankStatement = @"bank_statement";
NSString *const TGPassportFormTypeRentalAgreement = @"rental_agreement";
NSString *const TGPassportFormTypePassportRegistration = @"passport_registration";
NSString *const TGPassportFormTypeTemporaryRegistration = @"temporary_registration";
NSString *const TGPassportFormTypePhone = @"phone";
NSString *const TGPassportFormTypeEmail = @"email";

NSString *const TGPassportFormSecureDataKey = @"secure_data";
NSString *const TGPassportFormDataKey = @"data";
NSString *const TGPassportFormDataHashKey = @"data_hash";
NSString *const TGPassportFormFrontSideKey = @"front_side";
NSString *const TGPassportFormReverseSideKey = @"reverse_side";
NSString *const TGPassportFormSelfieKey = @"selfie";
NSString *const TGPassportFormFilesKey = @"files";
NSString *const TGPassportFormFileHashKey = @"file_hash";
NSString *const TGPassportFormSecretKey = @"secret";
NSString *const TGPassportFormPayloadKey = @"payload";

NSString *const TGPassportIdentityFirstNameKey = @"first_name";
NSString *const TGPassportIdentityLastNameKey = @"last_name";
NSString *const TGPassportIdentityDateOfBirthKey = @"birth_date";
NSString *const TGPassportIdentityGenderKey = @"gender";
NSString *const TGPassportIdentityGenderMaleValue = @"male";
NSString *const TGPassportIdentityGenderFemaleValue = @"female";
NSString *const TGPassportIdentityCountryCodeKey = @"country_code";
NSString *const TGPassportIdentityResidenceCountryCodeKey = @"residence_country_code";
NSString *const TGPassportIdentityDocumentNumberKey = @"document_no";
NSString *const TGPassportIdentityExpiryDateKey = @"expiry_date";

NSString *const TGPassportAddressStreetLine1Key = @"street_line1";
NSString *const TGPassportAddressStreetLine2Key = @"street_line2";
NSString *const TGPassportAddressCityKey = @"city";
NSString *const TGPassportAddressStateKey = @"state";
NSString *const TGPassportAddressCountryCodeKey = @"country_code";
NSString *const TGPassportAddressPostcodeKey = @"post_code";

@implementation TGPassportForm

- (instancetype)initWithTL:(TLaccount_AuthorizationForm *)form
{
    self = [super init];
    if (self != nil)
    {
        if ([form isKindOfClass:[TLaccount_AuthorizationForm$account_authorizationForm class]])
        {
            _tl = form;
            _privacyPolicyUrl = form.privacy_policy_url;
            _requiredTypes = [TGPassportSignals typesForSecureValueTypes:form.required_types];
            _selfieRequired = form.flags & (1 << 1);
            
            NSMutableSet *existingFiles = [[NSMutableSet alloc] init];
            for (TLSecureValue$secureValue *value in ((TLaccount_AuthorizationForm$account_authorizationForm *)form).values)
            {
                if ([value.front_side isKindOfClass:[TLSecureFile$secureFile class]])
                    [existingFiles addObject:[TGStringUtils stringByEncodingInBase64:((TLSecureFile$secureFile *)value.front_side).file_hash]];
                if ([value.reverse_side isKindOfClass:[TLSecureFile$secureFile class]])
                    [existingFiles addObject:[TGStringUtils stringByEncodingInBase64:((TLSecureFile$secureFile *)value.reverse_side).file_hash]];
                if ([value.selfie isKindOfClass:[TLSecureFile$secureFile class]])
                    [existingFiles addObject:[TGStringUtils stringByEncodingInBase64:((TLSecureFile$secureFile *)value.selfie).file_hash]];
                for (TLSecureFile$secureFile *file in value.files)
                {
                    if ([file isKindOfClass:[TLSecureFile$secureFile class]])
                        [existingFiles addObject:[TGStringUtils stringByEncodingInBase64:file.file_hash]];
                }
            }
            _errors = [[TGPassportErrors alloc] initWithArray:form.errors fileHashes:existingFiles];
        }
    }
    return self;
}

@end


@implementation TGPassportDecryptedForm

- (instancetype)initWithForm:(TGPassportForm *)form values:(NSArray<TGPassportDecryptedValue *> *)values
{
    self = [super initWithTL:form ? form->_tl : nil];
    if (self != nil)
    {
        _values = values;
    }
    return self;
}

- (TGPassportDecryptedValue *)valueForType:(TGPassportType)type
{
    for (TGPassportDecryptedValue *value in _values)
    {
        if (value.type == type)
            return value;
    }
    return nil;
}

- (instancetype)updateWithValues:(NSArray<TGPassportDecryptedValue *> *)values removeValueTypes:(NSArray *)removeValueTypes
{
    NSMutableArray *updateValueTypes = [[NSMutableArray alloc] init];
    for (TGPassportDecryptedValue *value in values)
    {
        [updateValueTypes addObject:@(value.type)];
    }
    
    NSMutableArray *newValues = [self.values mutableCopy];
    NSMutableIndexSet *indexesToRemove = [[NSMutableIndexSet alloc] init];
    [newValues enumerateObjectsUsingBlock:^(TGPassportDecryptedValue *value, NSUInteger index, __unused BOOL *stop) {
        if ([updateValueTypes containsObject:@(value.type)] || [removeValueTypes containsObject:@(value.type)])
            [indexesToRemove addIndex:index];
    }];
    
    [newValues removeObjectsAtIndexes:indexesToRemove];
    
    [newValues addObjectsFromArray:values];
    
    return [[TGPassportDecryptedForm alloc] initWithForm:self values:newValues];
}

- (NSData *)credentialsDataWithPayload:(NSString *)payload
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *secureData = [[NSMutableDictionary alloc] init];
    dictionary[TGPassportFormSecureDataKey] = secureData;
    for (TGPassportDecryptedValue *value in self.values)
    {
        if (value.plainData != nil)
            continue;
        
        NSMutableDictionary *valueDict = [[NSMutableDictionary alloc] init];
        if (value.data != nil)
        {
            valueDict[TGPassportFormDataKey] = @{TGPassportFormDataHashKey: [TGStringUtils stringByEncodingInBase64:value.data.dataHash], TGPassportFormSecretKey: [TGStringUtils stringByEncodingInBase64:value.data.dataSecret]};
        }
        
        if (value.frontSide != nil)
        {
            valueDict[TGPassportFormFrontSideKey] = @{TGPassportFormFileHashKey: [TGStringUtils stringByEncodingInBase64:value.frontSide.fileHash], TGPassportFormSecretKey: [TGStringUtils stringByEncodingInBase64:value.frontSide.fileSecret]};
        }
        
        if (value.reverseSide != nil)
        {
            valueDict[TGPassportFormReverseSideKey] = @{TGPassportFormFileHashKey: [TGStringUtils stringByEncodingInBase64:value.reverseSide.fileHash], TGPassportFormSecretKey: [TGStringUtils stringByEncodingInBase64:value.reverseSide.fileSecret]};
        }
        
        if (self.selfieRequired && value.selfie != nil)
        {
            valueDict[TGPassportFormSelfieKey] = @{TGPassportFormFileHashKey: [TGStringUtils stringByEncodingInBase64:value.selfie.fileHash], TGPassportFormSecretKey: [TGStringUtils stringByEncodingInBase64:value.selfie.fileSecret]};
        }
        
        NSMutableArray *files = [[NSMutableArray alloc] init];
        for (TGPassportFile *file in value.files)
        {
            if (file.fileHash != nil && file.fileSecret != nil)
            {
                [files addObject:@{TGPassportFormFileHashKey: [TGStringUtils stringByEncodingInBase64:file.fileHash], TGPassportFormSecretKey: [TGStringUtils stringByEncodingInBase64:file.fileSecret]}];
            }
        }
        if (files.count > 0)
            valueDict[TGPassportFormFilesKey] = files;
        
        NSString *key = [TGPassportDecryptedValue stringValueForType:value.type];
        if (key != nil)
            secureData[key] = valueDict;
    }
    
    if (payload.length > 0)
        dictionary[TGPassportFormPayloadKey] = payload;
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:&error];
    return data;
}

@end

@implementation TGPassportDecryptedValue

- (instancetype)initWithType:(TGPassportType)type data:(TGPassportSecureData *)data frontSide:(TGPassportFile *)frontSide reverseSide:(TGPassportFile *)reverseSide selfie:(TGPassportFile *)selfie files:(NSArray *)files plainData:(TGPassportPlainData *)plainData
{
    self = [super init];
    if (self != nil)
    {
        _type = type;
        _data = data;
        _frontSide = frontSide;
        _reverseSide = reverseSide;
        _selfie = selfie;
        _files = files;
        _plainData = plainData;
    }
    return self;
}

- (instancetype)updateWithValueHash:(NSData *)valueHash
{
    _valueHash = valueHash;
    return self;
}

+ (NSString *)stringValueForType:(TGPassportType)type
{
    switch (type)
    {
        case TGPassportTypePersonalDetails:
            return TGPassportFormTypePersonalDetails;
            
        case TGPassportTypePassport:
            return TGPassportFormTypePassport;
            
        case TGPassportTypeDriversLicense:
            return TGPassportFormTypeDriversLicense;
            
        case TGPassportTypeIdentityCard:
            return TGPassportFormTypeIdentityCard;
            
        case TGPassportTypeInternalPassport:
            return TGPassportFormTypeInternalPassport;
            
        case TGPassportTypeAddress:
            return TGPassportFormTypeAddress;
            
        case TGPassportTypeUtilityBill:
            return TGPassportFormTypeUtilityBill;
            
        case TGPassportTypeBankStatement:
            return TGPassportFormTypeBankStatement;
            
        case TGPassportTypeRentalAgreement:
            return TGPassportFormTypeRentalAgreement;
            
        case TGPassportTypePassportRegistration:
            return TGPassportFormTypePassportRegistration;
            
        case TGPassportTypeTemporaryRegistration:
            return TGPassportFormTypeTemporaryRegistration;
            
        case TGPassportTypePhone:
            return TGPassportFormTypePhone;
            
        case TGPassportTypeEmail:
            return TGPassportFormTypeEmail;
            
        default:
            return @"";
    }
}

+ (TGPassportType)typeForStringValue:(NSString *)value
{
    if ([value isEqualToString:TGPassportFormTypePersonalDetails])
        return TGPassportTypePersonalDetails;
    else if ([value isEqualToString:TGPassportFormTypePassport])
        return TGPassportTypePassport;
    else if ([value isEqualToString:TGPassportFormTypeDriversLicense])
        return TGPassportTypeDriversLicense;
    else if ([value isEqualToString:TGPassportFormTypeIdentityCard])
        return TGPassportTypeIdentityCard;
    else if ([value isEqualToString:TGPassportFormTypeInternalPassport])
        return TGPassportTypeInternalPassport;
    else if ([value isEqualToString:TGPassportFormTypeAddress])
        return TGPassportTypeAddress;
    else if ([value isEqualToString:TGPassportFormTypeUtilityBill])
        return TGPassportTypeUtilityBill;
    else if ([value isEqualToString:TGPassportFormTypeBankStatement])
        return TGPassportTypeBankStatement;
    else if ([value isEqualToString:TGPassportFormTypeRentalAgreement])
        return TGPassportTypeRentalAgreement;
    else if ([value isEqualToString:TGPassportFormTypePassportRegistration])
        return TGPassportTypePassportRegistration;
    else if ([value isEqualToString:TGPassportFormTypeTemporaryRegistration])
        return TGPassportTypeTemporaryRegistration;
    else if ([value isEqualToString:TGPassportFormTypePhone])
        return TGPassportTypePhone;
    else if ([value isEqualToString:TGPassportFormTypeEmail])
        return TGPassportTypeEmail;
    else
        return TGPassportTypeUndefined;
}

@end

@implementation TGPassportSecureData
{
    NSData *_paddedData;
    NSData *_valueHash;
}

- (instancetype)initWithPaddedData:(NSData *)paddedData dataSecret:(NSData *)dataSecret encryptedDataSecret:(NSData *)encryptedDataSecret
{
    uint8_t paddingLength;
    [paddedData getBytes:&paddingLength length:sizeof(uint8_t)];
    
    if (paddingLength >= paddedData.length)
        return nil;
    
    NSData *jsonData = [paddedData subdataWithRange:NSMakeRange(paddingLength, paddedData.length - paddingLength)];
    NSDictionary *dictionary = nil;
    @try {
        NSError *error;
        dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    } @catch (id e) {
    }
    
    if (dictionary == nil)
        return nil;
    
    return [self initWithJSON:dictionary paddedData:paddedData dataSecret:dataSecret encryptedDataSecret:encryptedDataSecret];
}

- (instancetype)initWithJSON:(NSDictionary *)__unused json paddedData:(NSData *)__unused paddedData dataSecret:(NSData *)__unused dataSecret encryptedDataSecret:(NSData *)__unused encryptedDataSecret
{
    return nil;
}

- (void)setupPaddedData:(NSData *)paddedData dataSecret:(NSData *)dataSecret encryptedDataSecret:(NSData *)encryptedDataSecret secret:(NSData *)secret
{
    _paddedData = paddedData;
    
    if (dataSecret == nil && secret != nil)
    {
        dataSecret = [TGPassportSignals secretWithSecretRandom:nil];
        encryptedDataSecret = [TGPassportSignals encrypted:true data:dataSecret hash:self.dataHash secret:secret];
    }
    
    _dataSecret = dataSecret;
    _encryptedDataSecret = encryptedDataSecret;
}

- (NSData *)dataHash
{
    return MTSha256(self.paddedData);
}

- (NSData *)paddedData
{
    if (_paddedData == nil)
        _paddedData = [TGPassportSignals paddedDataForEncryption:[self jsonData]];
    
    return _paddedData;
}

- (NSData *)jsonData
{
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.jsonValue options:kNilOptions error:&error];
    if (error != nil)
        return nil;
    
    return data;
}

- (NSDictionary *)jsonValue
{
    return nil;
}

@end


@implementation TGPassportPersonalDetailsData

- (instancetype)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName birthDate:(NSString *)birthDate gender:(TGPassportGender)gender countryCode:(NSString *)countryCode residenceCountryCode:(NSString *)residenceCountryCode secret:(NSData *)secret
{
    return [self initWithFirstName:firstName lastName:lastName birthDate:birthDate gender:gender countryCode:countryCode residenceCountryCode:residenceCountryCode paddedData:nil dataSecret:nil encryptedDataSecret:nil secret:secret];
}

- (instancetype)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName birthDate:(NSString *)birthDate gender:(TGPassportGender)gender countryCode:(NSString *)countryCode residenceCountryCode:(NSString *)residenceCountryCode paddedData:(NSData *)paddedData dataSecret:(NSData *)dataSecret encryptedDataSecret:(NSData *)encryptedDataSecret secret:(NSData *)secret
{
    self = [super init];
    if (self != nil)
    {
        _firstName = firstName;
        _lastName = lastName;
        _birthDate = birthDate;
        _gender = gender;
        _countryCode = countryCode;
        _residenceCountryCode = residenceCountryCode;
        
        [self setupPaddedData:paddedData dataSecret:dataSecret encryptedDataSecret:encryptedDataSecret secret:secret];
    }
    return self;
}

- (instancetype)initWithJSON:(NSDictionary *)json paddedData:(NSData *)paddedData dataSecret:(NSData *)dataSecret encryptedDataSecret:(NSData *)encryptedDataSecret
{
    return [self initWithFirstName:json[TGPassportIdentityFirstNameKey] lastName:json[TGPassportIdentityLastNameKey] birthDate:json[TGPassportIdentityDateOfBirthKey] gender:[TGPassportPersonalDetailsData genderForStringValue:json[TGPassportIdentityGenderKey]] countryCode:json[TGPassportIdentityCountryCodeKey] residenceCountryCode:json[TGPassportIdentityResidenceCountryCodeKey] paddedData:paddedData dataSecret:dataSecret encryptedDataSecret:encryptedDataSecret secret:nil];
}

- (NSDictionary *)jsonValue
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    if (_firstName != nil)
        dictionary[TGPassportIdentityFirstNameKey] = _firstName;
    if (_lastName != nil)
        dictionary[TGPassportIdentityLastNameKey] = _lastName;
    if (_birthDate != nil)
        dictionary[TGPassportIdentityDateOfBirthKey] = _birthDate;
    if (_gender != TGPassportGenderUndefined)
        dictionary[TGPassportIdentityGenderKey] = [TGPassportPersonalDetailsData stringValueForGender:_gender];
    if (_countryCode != nil)
        dictionary[TGPassportIdentityCountryCodeKey] = [_countryCode uppercaseString];
    if (_residenceCountryCode != nil)
        dictionary[TGPassportIdentityResidenceCountryCodeKey] = [_residenceCountryCode uppercaseString];
    return dictionary;
}

+ (NSString *)stringValueForGender:(TGPassportGender)gender
{
    switch (gender) {
        case TGPassportGenderMale:
            return TGPassportIdentityGenderMaleValue;
            
        case TGPassportGenderFemale:
            return TGPassportIdentityGenderFemaleValue;
            
        default:
            return @"";
    }
}

+ (TGPassportGender)genderForStringValue:(NSString *)value
{
    if ([value isEqualToString:TGPassportIdentityGenderMaleValue])
        return TGPassportGenderMale;
    else if ([value isEqualToString:TGPassportIdentityGenderFemaleValue])
        return TGPassportGenderFemale;
    else
        return TGPassportGenderUndefined;
}

@end

@implementation TGPassportDocumentData

- (instancetype)initWithDocumentNumber:(NSString *)documentNumber expiryDate:(NSString *)expiryDate secret:(NSData *)secret
{
    return [self initWithDocumentNumber:documentNumber expiryDate:expiryDate paddedData:nil dataSecret:nil encryptedDataSecret:nil secret:secret];
}

- (instancetype)initWithDocumentNumber:(NSString *)documentNumber expiryDate:(NSString *)expiryDate paddedData:(NSData *)paddedData dataSecret:(NSData *)dataSecret encryptedDataSecret:(NSData *)encryptedDataSecret secret:(NSData *)secret
{
    self = [super init];
    if (self != nil)
    {
        _documentNumber = documentNumber;
        _expiryDate = expiryDate;
        
        [self setupPaddedData:paddedData dataSecret:dataSecret encryptedDataSecret:encryptedDataSecret secret:secret];
    }
    return self;
}

- (instancetype)initWithJSON:(NSDictionary *)json paddedData:(NSData *)paddedData dataSecret:(NSData *)dataSecret encryptedDataSecret:(NSData *)encryptedDataSecret
{
    return [self initWithDocumentNumber:json[TGPassportIdentityDocumentNumberKey] expiryDate:json[TGPassportIdentityExpiryDateKey] paddedData:paddedData dataSecret:dataSecret encryptedDataSecret:encryptedDataSecret secret:nil];
}

- (NSDictionary *)jsonValue
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    if (_documentNumber != nil)
        dictionary[TGPassportIdentityDocumentNumberKey] = _documentNumber;
    if (_expiryDate != nil)
        dictionary[TGPassportIdentityExpiryDateKey] = _expiryDate;
    return dictionary;
}

@end


@implementation TGPassportAddressData

- (instancetype)initWithStreet1:(NSString *)street1 street2:(NSString *)street2 postcode:(NSString *)postcode city:(NSString *)city state:(NSString *)state countryCode:(NSString *)countryCode secret:(NSData *)secret
{
    return [self initWithStreet1:street1 street2:street2 postcode:postcode city:city state:state countryCode:countryCode paddedData:nil dataSecret:nil encryptedDataSecret:nil secret:secret];
}

- (instancetype)initWithStreet1:(NSString *)street1 street2:(NSString *)street2 postcode:(NSString *)postcode city:(NSString *)city state:(NSString *)state countryCode:(NSString *)countryCode paddedData:(NSData *)paddedData dataSecret:(NSData *)dataSecret encryptedDataSecret:(NSData *)encryptedDataSecret secret:(NSData *)secret
{
    self = [super init];
    if (self != nil)
    {
        _street1 = street1;
        _street2 = street2;
        _postcode = postcode;
        _city = city;
        _state = state;
        _countryCode = countryCode;
        
        [self setupPaddedData:paddedData dataSecret:dataSecret encryptedDataSecret:encryptedDataSecret secret:secret];
    }
    return self;
}

- (instancetype)initWithJSON:(NSDictionary *)json paddedData:(NSData *)paddedData dataSecret:(NSData *)dataSecret encryptedDataSecret:(NSData *)encryptedDataSecret
{
    return [self initWithStreet1:json[TGPassportAddressStreetLine1Key] street2:json[TGPassportAddressStreetLine2Key] postcode:json[TGPassportAddressPostcodeKey] city:json[TGPassportAddressCityKey] state:json[TGPassportAddressStateKey] countryCode:json[TGPassportAddressCountryCodeKey] paddedData:paddedData dataSecret:dataSecret encryptedDataSecret:encryptedDataSecret secret:nil];
}

- (NSDictionary *)jsonValue
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    if (_street1 != nil)
        dictionary[TGPassportAddressStreetLine1Key] = _street1;
    if (_street2 != nil)
        dictionary[TGPassportAddressStreetLine2Key] = _street2;
    if (_postcode != nil)
        dictionary[TGPassportAddressPostcodeKey] = _postcode;
    if (_city != nil)
        dictionary[TGPassportAddressCityKey] = _city;
    if (_state != nil)
        dictionary[TGPassportAddressStateKey] = _state;
    if (_countryCode != nil)
        dictionary[TGPassportAddressCountryCodeKey] = [_countryCode uppercaseString];
    return dictionary;
}

@end


@implementation TGPassportPlainData

@end


@implementation TGPassportPhoneData

- (instancetype)initWithPhone:(NSString *)phone
{
    self = [super init];
    if (self != nil)
    {
        _phone = phone;
    }
    return self;
}

@end


@implementation TGPassportEmailData

- (instancetype)initWithEmail:(NSString *)email
{
    self = [super init];
    if (self != nil)
    {
        _email = email;
    }
    return self;
}

@end
