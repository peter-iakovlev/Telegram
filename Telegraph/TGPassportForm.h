#import <Foundation/Foundation.h>

@class TGPassportDecryptedValue;
@class TGPassportSecureData;
@class TGPassportPlainData;
@class TGPassportFile;
@class TGPassportErrors;

typedef enum
{
    TGPassportTypeUndefined,
    TGPassportTypePersonalDetails,
    TGPassportTypePassport,
    TGPassportTypeDriversLicense,
    TGPassportTypeIdentityCard,
    TGPassportTypeInternalPassport,
    TGPassportTypeAddress,
    TGPassportTypeUtilityBill,
    TGPassportTypeBankStatement,
    TGPassportTypeRentalAgreement,
    TGPassportTypePassportRegistration,
    TGPassportTypeTemporaryRegistration,
    TGPassportTypePhone,
    TGPassportTypeEmail
} TGPassportType;

typedef enum
{
    TGPassportGenderUndefined,
    TGPassportGenderMale,
    TGPassportGenderFemale
} TGPassportGender;

@class TLaccount_AuthorizationForm;

@interface TGPassportForm : NSObject
{
    @public
    TLaccount_AuthorizationForm *_tl;
}

@property (nonatomic, readonly) NSArray *requiredTypes;
@property (nonatomic, readonly) bool selfieRequired;
@property (nonatomic, readonly) NSString *privacyPolicyUrl;
@property (nonatomic, readonly) TGPassportErrors *errors;

- (instancetype)initWithTL:(TLaccount_AuthorizationForm *)form;

@end


@interface TGPassportDecryptedForm : TGPassportForm

@property (nonatomic, readonly) NSArray<TGPassportDecryptedValue *> *values;

- (instancetype)initWithForm:(TGPassportForm *)form values:(NSArray<TGPassportDecryptedValue *> *)values;

- (TGPassportDecryptedValue *)valueForType:(TGPassportType)type;

- (instancetype)updateWithValues:(NSArray<TGPassportDecryptedValue *> *)values removeValueTypes:(NSArray *)valueTypes;
- (NSData *)credentialsDataWithPayload:(NSString *)payload;

@end

@interface TGPassportDecryptedValue : NSObject

@property (nonatomic, readonly) TGPassportType type;
@property (nonatomic, readonly) TGPassportSecureData *data;
@property (nonatomic, readonly) TGPassportFile *frontSide;
@property (nonatomic, readonly) TGPassportFile *reverseSide;
@property (nonatomic, readonly) TGPassportFile *selfie;
@property (nonatomic, readonly) NSArray *files;
@property (nonatomic, readonly) TGPassportPlainData *plainData;

@property (nonatomic, readonly) NSData *valueHash;

- (instancetype)initWithType:(TGPassportType)type data:(TGPassportSecureData *)data frontSide:(TGPassportFile *)frontSide reverseSide:(TGPassportFile *)reverseSide selfie:(TGPassportFile *)selfie files:(NSArray *)files plainData:(TGPassportPlainData *)plainData;

- (instancetype)updateWithValueHash:(NSData *)valueHash;

+ (NSString *)stringValueForType:(TGPassportType)type;
+ (TGPassportType)typeForStringValue:(NSString *)value;

@end


@interface TGPassportSecureData : NSObject

@property (nonatomic, readonly) NSData *paddedData;
@property (nonatomic, readonly) NSData *dataHash;
@property (nonatomic, readonly) NSData *dataSecret;
@property (nonatomic, readonly) NSData *encryptedDataSecret;

- (instancetype)initWithPaddedData:(NSData *)paddedData dataSecret:(NSData *)dataSecret encryptedDataSecret:(NSData *)encryptedDataSecret;

@end

@interface TGPassportPersonalDetailsData : TGPassportSecureData

@property (nonatomic, readonly) NSString *firstName;
@property (nonatomic, readonly) NSString *lastName;
@property (nonatomic, readonly) NSString *birthDate;
@property (nonatomic, readonly) TGPassportGender gender;
@property (nonatomic, readonly) NSString *countryCode;
@property (nonatomic, readonly) NSString *residenceCountryCode;

- (instancetype)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName birthDate:(NSString *)birthDate gender:(TGPassportGender)gender countryCode:(NSString *)countryCode residenceCountryCode:(NSString *)residenceCountryCode secret:(NSData *)secret;

@end

@interface TGPassportDocumentData : TGPassportSecureData

@property (nonatomic, readonly) NSString *documentNumber;
@property (nonatomic, readonly) NSString *expiryDate;

- (instancetype)initWithDocumentNumber:(NSString *)documentNumber expiryDate:(NSString *)expiryDate secret:(NSData *)secret;

@end


@interface TGPassportAddressData : TGPassportSecureData

@property (nonatomic, readonly) NSString *street1;
@property (nonatomic, readonly) NSString *street2;
@property (nonatomic, readonly) NSString *postcode;
@property (nonatomic, readonly) NSString *city;
@property (nonatomic, readonly) NSString *state;
@property (nonatomic, readonly) NSString *countryCode;

- (instancetype)initWithStreet1:(NSString *)street1 street2:(NSString *)street2 postcode:(NSString *)postcode city:(NSString *)city state:(NSString *)state countryCode:(NSString *)countryCode secret:(NSData *)secret;

@end

@interface TGPassportPlainData : NSObject

@end

@interface TGPassportPhoneData : TGPassportPlainData

@property (nonatomic, readonly) NSString *phone;

- (instancetype)initWithPhone:(NSString *)phone;

@end

@interface TGPassportEmailData : TGPassportPlainData

@property (nonatomic, readonly) NSString *email;

- (instancetype)initWithEmail:(NSString *)email;

@end

extern NSString *const TGPassportFormTypePersonalDetails;
extern NSString *const TGPassportFormTypePassport;
extern NSString *const TGPassportFormTypeDriversLicense;
extern NSString *const TGPassportFormTypeIdentityCard;
extern NSString *const TGPassportFormTypeAddress;
extern NSString *const TGPassportFormTypeUtilityBill;
extern NSString *const TGPassportFormTypeBankStatement;
extern NSString *const TGPassportFormTypeRentalAgreement;
extern NSString *const TGPassportFormTypePhone;
extern NSString *const TGPassportFormTypeEmail;

extern NSString *const TGPassportIdentityFirstNameKey;
extern NSString *const TGPassportIdentityLastNameKey;
extern NSString *const TGPassportIdentityDateOfBirthKey;
extern NSString *const TGPassportIdentityGenderKey;
extern NSString *const TGPassportIdentityCountryCodeKey;
extern NSString *const TGPassportIdentityResidenceCountryCodeKey;
extern NSString *const TGPassportIdentityDocumentNumberKey;
extern NSString *const TGPassportIdentityExpiryDateKey;

extern NSString *const TGPassportAddressStreetLine1Key;
extern NSString *const TGPassportAddressStreetLine2Key;
extern NSString *const TGPassportAddressCityKey;
extern NSString *const TGPassportAddressStateKey;
extern NSString *const TGPassportAddressCountryCodeKey;
extern NSString *const TGPassportAddressPostcodeKey;
