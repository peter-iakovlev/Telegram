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
NSString *const TGPassportFormTranslationKey = @"translation";
NSString *const TGPassportFormFilesKey = @"files";
NSString *const TGPassportFormFileHashKey = @"file_hash";
NSString *const TGPassportFormSecretKey = @"secret";
NSString *const TGPassportFormPayloadKey = @"payload";
NSString *const TGPassportFormNonceKey = @"nonce";

NSString *const TGPassportIdentityFirstNameKey = @"first_name";
NSString *const TGPassportIdentityFirstNameNativeKey = @"first_name_native";
NSString *const TGPassportIdentityMiddleNameKey = @"middle_name";
NSString *const TGPassportIdentityMiddleNameNativeKey = @"middle_name_native";
NSString *const TGPassportIdentityLastNameKey = @"last_name";
NSString *const TGPassportIdentityLastNameNativeKey = @"last_name_native";
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
            _requiredTypes = [TGPassportSignals requiredTypesForSecureRequiredTypes:form.required_types];
            
            NSMutableSet *existingFiles = [[NSMutableSet alloc] init];
            for (TLSecureValue$secureValue *value in ((TLaccount_AuthorizationForm$account_authorizationForm *)form).values)
            {
                if ([value.front_side isKindOfClass:[TLSecureFile$secureFile class]])
                    [existingFiles addObject:[TGStringUtils stringByEncodingInBase64:((TLSecureFile$secureFile *)value.front_side).file_hash]];
                if ([value.reverse_side isKindOfClass:[TLSecureFile$secureFile class]])
                    [existingFiles addObject:[TGStringUtils stringByEncodingInBase64:((TLSecureFile$secureFile *)value.reverse_side).file_hash]];
                if ([value.selfie isKindOfClass:[TLSecureFile$secureFile class]])
                    [existingFiles addObject:[TGStringUtils stringByEncodingInBase64:((TLSecureFile$secureFile *)value.selfie).file_hash]];
                for (TLSecureFile$secureFile *file in value.translation)
                {
                    if ([file isKindOfClass:[TLSecureFile$secureFile class]])
                        [existingFiles addObject:[TGStringUtils stringByEncodingInBase64:file.file_hash]];
                }
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

- (bool)hasValues
{
    return _values.count > 0;
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

- (bool)selfieRequiredForValue:(TGPassportDecryptedValue *)value
{
    for (NSObject<TGPassportRequiredType> *requiredType in self.requiredTypes)
    {
        if ([requiredType isKindOfClass:[TGPassportRequiredType class]])
        {
            if (((TGPassportRequiredType *)requiredType).type == value.type)
                return ((TGPassportRequiredType *)requiredType).selfieRequired;
        }
        else if ([requiredType isKindOfClass:[TGPassportRequiredOneOfTypes class]])
        {
            for (TGPassportRequiredType *subtype in ((TGPassportRequiredOneOfTypes *)requiredType).types)
            {
                if (subtype.type == value.type)
                    return subtype.selfieRequired;
            }
        }
    }
    return false;
}

- (bool)translationRequiredForValue:(TGPassportDecryptedValue *)value
{
    for (NSObject<TGPassportRequiredType> *requiredType in self.requiredTypes)
    {
        if ([requiredType isKindOfClass:[TGPassportRequiredType class]])
        {
            if (((TGPassportRequiredType *)requiredType).type == value.type)
                return ((TGPassportRequiredType *)requiredType).translationRequired;
        }
        else if ([requiredType isKindOfClass:[TGPassportRequiredOneOfTypes class]])
        {
            for (TGPassportRequiredType *subtype in ((TGPassportRequiredOneOfTypes *)requiredType).types)
            {
                if (subtype.type == value.type)
                    return subtype.translationRequired;
            }
        }
    }
    return false;
}

- (NSArray *)fulfilledValues
{
    NSMutableArray *requestedValues = [[NSMutableArray alloc] init];
    for (NSObject<TGPassportRequiredType> *requiredType in self.requiredTypes)
    {
        if ([requiredType isKindOfClass:[TGPassportRequiredType class]])
        {
            for (TGPassportDecryptedValue *value in self.values)
            {
                if (((TGPassportRequiredType *)requiredType).type == value.type)
                {
                    [requestedValues addObject:value];
                    break;
                }
            }
        }
        else if ([requiredType isKindOfClass:[TGPassportRequiredOneOfTypes class]])
        {
            TGPassportDecryptedValue *documentValue = nil;
            bool complete = false;
            
            for (TGPassportRequiredType *subtype in ((TGPassportRequiredOneOfTypes *)requiredType).types)
            {
                if (documentValue == nil || !complete)
                {
                    TGPassportDecryptedValue *value = [self valueForType:subtype.type];
                    if (value != nil)
                    {
                        NSInteger bestScore = subtype.translationRequired + subtype.selfieRequired * 2;
                        NSInteger valueScore = (subtype.translationRequired ? value.translation.count > 0 : 0) + (subtype.selfieRequired && value.selfie != nil ? 2 : 0);
                        if (documentValue == nil || bestScore == valueScore)
                            documentValue = value;
                        
                        complete = valueScore == bestScore;
                    }
                }
            }
            
            [requestedValues addObject:documentValue];
        }
    }
    return requestedValues;
}

- (NSData *)credentialsDataWithPayload:(NSString *)payload nonce:(NSString *)nonce
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *secureData = [[NSMutableDictionary alloc] init];
    dictionary[TGPassportFormSecureDataKey] = secureData;
    
    for (TGPassportDecryptedValue *value in self.fulfilledValues)
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
        
        if (value.selfie != nil && [self selfieRequiredForValue:value])
        {
            valueDict[TGPassportFormSelfieKey] = @{TGPassportFormFileHashKey: [TGStringUtils stringByEncodingInBase64:value.selfie.fileHash], TGPassportFormSecretKey: [TGStringUtils stringByEncodingInBase64:value.selfie.fileSecret]};
        }
        
        if (value.translation.count > 0 && [self translationRequiredForValue:value])
        {
            NSMutableArray *translation = [[NSMutableArray alloc] init];
            for (TGPassportFile *file in value.translation)
            {
                if (file.fileHash != nil && file.fileSecret != nil)
                {
                    [translation addObject:@{TGPassportFormFileHashKey: [TGStringUtils stringByEncodingInBase64:file.fileHash], TGPassportFormSecretKey: [TGStringUtils stringByEncodingInBase64:file.fileSecret]}];
                }
            }
            if (translation.count > 0)
                valueDict[TGPassportFormTranslationKey] = translation;
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
    
    if (nonce.length > 0)
        dictionary[TGPassportFormNonceKey] = nonce;
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:&error];
    return data;
}

@end

@implementation TGPassportDecryptedValue

- (instancetype)initWithType:(TGPassportType)type data:(TGPassportSecureData *)data frontSide:(TGPassportFile *)frontSide reverseSide:(TGPassportFile *)reverseSide selfie:(TGPassportFile *)selfie translation:(NSArray *)translation files:(NSArray *)files plainData:(TGPassportPlainData *)plainData
{
    self = [super init];
    if (self != nil)
    {
        _type = type;
        _data = data;
        _frontSide = frontSide;
        _reverseSide = reverseSide;
        _selfie = selfie;
        _translation = translation;
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

- (bool)isCompleted
{
    return false;
}

+ (NSDictionary *)extractUnknownFields:(NSDictionary *)json knownFields:(NSArray *)knownFields
{
    NSMutableDictionary *unknownFields = [[NSMutableDictionary alloc] init];
    [json enumerateKeysAndObjectsUsingBlock:^(id key, id obj, __unused BOOL *stop)
    {
        if (![knownFields containsObject:key])
            unknownFields[key] = obj;
    }];
    return unknownFields;
}

@end


@implementation TGPassportPersonalDetailsData

- (instancetype)initWithFirstName:(NSString *)firstName middleName:(NSString *)middleName lastName:(NSString *)lastName firstNameNative:(NSString *)firstNameNative middleNameNative:(NSString *)middleNameNative lastNameNative:(NSString *)lastNameNative birthDate:(NSString *)birthDate gender:(TGPassportGender)gender countryCode:(NSString *)countryCode residenceCountryCode:(NSString *)residenceCountryCode unknownFields:(NSDictionary *)unknownFields secret:(NSData *)secret
{
    return [self initWithFirstName:firstName middleName:middleName lastName:lastName firstNameNative:firstNameNative middleNameNative:middleNameNative lastNameNative:lastNameNative birthDate:birthDate gender:gender countryCode:countryCode residenceCountryCode:residenceCountryCode unknownFields:unknownFields paddedData:nil dataSecret:nil encryptedDataSecret:nil secret:secret];
}

- (instancetype)initWithFirstName:(NSString *)firstName middleName:(NSString *)middleName lastName:(NSString *)lastName firstNameNative:(NSString *)firstNameNative middleNameNative:(NSString *)middleNameNative lastNameNative:(NSString *)lastNameNative birthDate:(NSString *)birthDate gender:(TGPassportGender)gender countryCode:(NSString *)countryCode residenceCountryCode:(NSString *)residenceCountryCode unknownFields:(NSDictionary *)unknownFields paddedData:(NSData *)paddedData dataSecret:(NSData *)dataSecret encryptedDataSecret:(NSData *)encryptedDataSecret secret:(NSData *)secret
{
    self = [super init];
    if (self != nil)
    {
        _firstName = firstName;
        _middleName = middleName;
        _lastName = lastName;
        _firstNameNative = firstNameNative;
        _middleNameNative = middleNameNative;
        _lastNameNative = lastNameNative;
        _birthDate = birthDate;
        _gender = gender;
        _countryCode = countryCode;
        _residenceCountryCode = residenceCountryCode;
        _unknownFields = unknownFields;
        
        [self setupPaddedData:paddedData dataSecret:dataSecret encryptedDataSecret:encryptedDataSecret secret:secret];
    }
    return self;
}

- (instancetype)initWithJSON:(NSDictionary *)json paddedData:(NSData *)paddedData dataSecret:(NSData *)dataSecret encryptedDataSecret:(NSData *)encryptedDataSecret
{
    NSArray *knownFields = @
    [
     TGPassportIdentityFirstNameKey,
     TGPassportIdentityMiddleNameKey,
     TGPassportIdentityLastNameKey,
     TGPassportIdentityFirstNameNativeKey,
     TGPassportIdentityMiddleNameNativeKey,
     TGPassportIdentityLastNameNativeKey,
     TGPassportIdentityDateOfBirthKey,
     TGPassportIdentityGenderKey,
     TGPassportIdentityCountryCodeKey,
     TGPassportIdentityResidenceCountryCodeKey
    ];
    NSDictionary *unknownFields = [TGPassportSecureData extractUnknownFields:json knownFields:knownFields];
    
    return [self initWithFirstName:json[TGPassportIdentityFirstNameKey] middleName:json[TGPassportIdentityMiddleNameKey] lastName:json[TGPassportIdentityLastNameKey] firstNameNative:json[TGPassportIdentityFirstNameNativeKey] middleNameNative:json[TGPassportIdentityMiddleNameNativeKey] lastNameNative:json[TGPassportIdentityLastNameNativeKey] birthDate:json[TGPassportIdentityDateOfBirthKey] gender:[TGPassportPersonalDetailsData genderForStringValue:json[TGPassportIdentityGenderKey]] countryCode:json[TGPassportIdentityCountryCodeKey] residenceCountryCode:json[TGPassportIdentityResidenceCountryCodeKey] unknownFields:unknownFields paddedData:paddedData dataSecret:dataSecret encryptedDataSecret:encryptedDataSecret secret:nil];
}

- (NSDictionary *)jsonValue
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    if (_firstName != nil)
        dictionary[TGPassportIdentityFirstNameKey] = _firstName;
    if (_middleName != nil)
        dictionary[TGPassportIdentityMiddleNameKey] = _middleName;
    if (_lastName != nil)
        dictionary[TGPassportIdentityLastNameKey] = _lastName;
    if (_firstNameNative != nil)
        dictionary[TGPassportIdentityFirstNameNativeKey] = _firstNameNative;
    if (_middleNameNative != nil)
        dictionary[TGPassportIdentityMiddleNameNativeKey] = _middleNameNative;
    if (_lastNameNative != nil)
        dictionary[TGPassportIdentityLastNameNativeKey] = _lastNameNative;
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

- (bool)hasNativeName
{
    return _firstNameNative.length > 0 && _lastNameNative.length > 0;
}

- (bool)isCompleted
{
    bool hasName = _firstName.length > 0 && _lastName.length > 0;
    bool hasBirthdate = _birthDate.length > 0;
    bool hasGender = _gender != TGPassportGenderUndefined;
    bool hasCountry = _countryCode.length > 0;
    bool hasResidence = _residenceCountryCode.length > 0;
    return hasName && hasBirthdate && hasGender && hasCountry && hasResidence;
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

- (instancetype)initWithDocumentNumber:(NSString *)documentNumber expiryDate:(NSString *)expiryDate unknownFields:(NSDictionary *)unknownFields secret:(NSData *)secret
{
    return [self initWithDocumentNumber:documentNumber expiryDate:expiryDate unknownFields:unknownFields paddedData:nil dataSecret:nil encryptedDataSecret:nil secret:secret];
}

- (instancetype)initWithDocumentNumber:(NSString *)documentNumber expiryDate:(NSString *)expiryDate unknownFields:(NSDictionary *)unknownFields paddedData:(NSData *)paddedData dataSecret:(NSData *)dataSecret encryptedDataSecret:(NSData *)encryptedDataSecret secret:(NSData *)secret
{
    self = [super init];
    if (self != nil)
    {
        _documentNumber = documentNumber;
        _expiryDate = expiryDate;
        _unknownFields = unknownFields;
        
        [self setupPaddedData:paddedData dataSecret:dataSecret encryptedDataSecret:encryptedDataSecret secret:secret];
    }
    return self;
}

- (instancetype)initWithJSON:(NSDictionary *)json paddedData:(NSData *)paddedData dataSecret:(NSData *)dataSecret encryptedDataSecret:(NSData *)encryptedDataSecret
{
    NSArray *knownFields = @
    [
     TGPassportIdentityDocumentNumberKey,
     TGPassportIdentityExpiryDateKey
    ];
    NSDictionary *unknownFields = [TGPassportSecureData extractUnknownFields:json knownFields:knownFields];
    return [self initWithDocumentNumber:json[TGPassportIdentityDocumentNumberKey] expiryDate:json[TGPassportIdentityExpiryDateKey] unknownFields:unknownFields paddedData:paddedData dataSecret:dataSecret encryptedDataSecret:encryptedDataSecret secret:nil];
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

- (bool)isCompleted
{
    return _documentNumber.length > 0;
}

@end


@implementation TGPassportAddressData

- (instancetype)initWithStreet1:(NSString *)street1 street2:(NSString *)street2 postcode:(NSString *)postcode city:(NSString *)city state:(NSString *)state countryCode:(NSString *)countryCode unknownFields:(NSDictionary *)unknownFields secret:(NSData *)secret
{
    return [self initWithStreet1:street1 street2:street2 postcode:postcode city:city state:state countryCode:countryCode unknownFields:unknownFields paddedData:nil dataSecret:nil encryptedDataSecret:nil secret:secret];
}

- (instancetype)initWithStreet1:(NSString *)street1 street2:(NSString *)street2 postcode:(NSString *)postcode city:(NSString *)city state:(NSString *)state countryCode:(NSString *)countryCode unknownFields:(NSDictionary *)unknownFields paddedData:(NSData *)paddedData dataSecret:(NSData *)dataSecret encryptedDataSecret:(NSData *)encryptedDataSecret secret:(NSData *)secret
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
        _unknownFields = unknownFields;
        
        [self setupPaddedData:paddedData dataSecret:dataSecret encryptedDataSecret:encryptedDataSecret secret:secret];
    }
    return self;
}

- (instancetype)initWithJSON:(NSDictionary *)json paddedData:(NSData *)paddedData dataSecret:(NSData *)dataSecret encryptedDataSecret:(NSData *)encryptedDataSecret
{
    NSArray *knownFields = @
    [
     TGPassportAddressStreetLine1Key,
     TGPassportAddressStreetLine2Key,
     TGPassportAddressPostcodeKey,
     TGPassportAddressCityKey,
     TGPassportAddressStateKey,
     TGPassportAddressCountryCodeKey
    ];
    NSDictionary *unknownFields = [TGPassportSecureData extractUnknownFields:json knownFields:knownFields];
    return [self initWithStreet1:json[TGPassportAddressStreetLine1Key] street2:json[TGPassportAddressStreetLine2Key] postcode:json[TGPassportAddressPostcodeKey] city:json[TGPassportAddressCityKey] state:json[TGPassportAddressStateKey] countryCode:json[TGPassportAddressCountryCodeKey] unknownFields:unknownFields paddedData:paddedData dataSecret:dataSecret encryptedDataSecret:encryptedDataSecret secret:nil];
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

- (bool)isCompleted
{
    bool hasStreet = _street1.length > 0;
    bool hasPostcode = _postcode.length > 0;
    bool hasCity = _city.length > 0;
    bool hasCountry = _countryCode.length > 0;
    return hasStreet && hasPostcode && hasCity && hasCountry;
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


@implementation TGPassportRequiredType

- (instancetype)initWithType:(TGPassportType)type includeNativeNames:(bool)includeNativeNames selfieRequired:(bool)selfieRequired translationRequired:(bool)translationRequired
{
    self = [super init];
    if (self != nil)
    {
        _type = type;
        _includeNativeNames = includeNativeNames;
        _selfieRequired = selfieRequired;
        _translationRequired = translationRequired;
    }
    return self;
}

+ (instancetype)requiredTypeForType:(TGPassportType)type
{
    return [[TGPassportRequiredType alloc] initWithType:type includeNativeNames:false selfieRequired:false translationRequired:false];
}

+ (NSArray *)requiredIdentityTypes
{
    NSMutableArray *types = [[NSMutableArray alloc] init];
    for (NSNumber *type in [TGPassportSignals identityTypes])
    {
        [types addObject:[TGPassportRequiredType requiredTypeForType:(TGPassportType)type.integerValue]];
    }
    return types;
}

+ (NSArray *)requiredAddressTypes
{
    NSMutableArray *types = [[NSMutableArray alloc] init];
    for (NSNumber *type in [TGPassportSignals addressTypes])
    {
        [types addObject:[TGPassportRequiredType requiredTypeForType:(TGPassportType)type.integerValue]];
    }
    return types;
}

@end

@implementation TGPassportRequiredOneOfTypes

- (instancetype)initWithTypes:(NSArray *)types
{
    self = [self init];
    if (self != nil)
    {
        _types = types;
    }
    return self;
}

@end
