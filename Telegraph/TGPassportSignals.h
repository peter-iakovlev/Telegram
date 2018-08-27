#import <SSignalKit/SSignalKit.h>

#import "TGPassportForm.h"

@class TLSecureValueType;

@class TGSecurePasswordKdfAlgo;

@interface TGPassportSignals : NSObject

+ (SSignal *)languageMap;

+ (SSignal *)hasPassport;

+ (SSignal *)allSecureValuesWithSecret:(NSData *)secret;

+ (SSignal *)authorizationFormForBotId:(int32_t)botId scope:(NSString *)scope publicKey:(NSString *)publicKey;
+ (SSignal *)acceptAuthorizationForBotId:(int32_t)botId scope:(NSString *)scope publicKey:(NSString *)publicKey finalForm:(TGPassportDecryptedForm *)finalForm payload:(NSString *)payload nonce:(NSString *)nonce;

+ (SSignal *)sendPhoneVerificationCode:(NSString *)phoneNumber;
+ (SSignal *)verifyPhone:(NSString *)phoneNumber code:(NSString *)code hash:(NSString *)hash;

+ (SSignal *)sendEmailVerificationCode:(NSString *)email;
+ (SSignal *)verifyEmail:(NSString *)email code:(NSString *)code;

+ (SSignal *)deleteSecureValueTypes:(NSArray *)types;
+ (SSignal *)deleteAllSecureValues;
+ (SSignal *)secureValueTypes:(NSArray *)types;
+ (SSignal *)saveSecureValue:(TGPassportDecryptedValue *)value secret:(NSData *)secret;

+ (SSignal *)uploadSecureData:(NSData *)data thumbnailData:(NSData *)thumbnailData secret:(NSData *)secret;

+ (NSData *)encrypted:(bool)encrypted data:(NSData *)data hash:(NSData *)hash secret:(NSData *)secret;
+ (TGPassportDecryptedForm *)decryptedForm:(TGPassportForm *)form secret:(NSData *)secret;
+ (NSData *)decryptedDataWithData:(NSData *)data dataHash:(NSData *)dataHash dataSecret:(NSData *)dataSecret keepPadding:(bool)keepPadding;

+ (NSData *)paddedDataForEncryption:(NSData *)data;
+ (NSData *)secretWithSecretRandom:(NSData *)secretRandom;
+ (int64_t)secureSecretId:(NSData *)secureSecret;

+ (NSData *)encryptedSecureSecretWithData:(NSData *)data password:(NSString *)password nextSecureAlgo:(TGSecurePasswordKdfAlgo *)nextSecureAlgo secureAlgoOut:(TGSecurePasswordKdfAlgo *__autoreleasing *)secureAlgoOut;
+ (NSData *)decryptedSecureSecretWithData:(NSData *)data password:(NSString *)password secureAlgo:(TGSecurePasswordKdfAlgo *)secureAlgo;
+ (NSData *)decryptedSecureSecretWithData:(NSData *)data passwordHash:(NSData *)passwordHashData;

+ (NSArray *)typesForSecureValueTypes:(NSArray *)valueTypes;
+ (TGPassportType)typeForSecureValueType:(TLSecureValueType *)valueType;

+ (NSArray *)identityTypes;
+ (NSArray *)addressTypes;

+ (bool)isIdentityType:(TGPassportType)type;
+ (bool)isAddressType:(TGPassportType)type;

+ (NSArray *)requiredTypesForSecureRequiredTypes:(NSArray *)requiredTypes;

+ (void)storePasswordHash:(NSData *)passwordHash secretPasswordHash:(NSData *)secretPasswordHash;
+ (NSData *)storedPasswordHash;
+ (NSData *)storedSecretPasswordHash;
+ (void)clearStoredPasswordHashes;

@end
