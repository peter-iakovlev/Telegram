#import <SSignalKit/SSignalKit.h>

#import "TGPassportForm.h"

@class TLSecureValueType;

@interface TGPassportSignals : NSObject

+ (SSignal *)hasPassport;

+ (SSignal *)allSecureValuesWithSecret:(NSData *)secret;

+ (SSignal *)authorizationFormForBotId:(int32_t)botId scope:(NSString *)scope publicKey:(NSString *)publicKey;
+ (SSignal *)acceptAuthorizationForBotId:(int32_t)botId scope:(NSString *)scope publicKey:(NSString *)publicKey finalForm:(TGPassportDecryptedForm *)finalForm payload:(NSString *)payload;

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

+ (NSData *)encryptedSecureSecretWithData:(NSData *)data passord:(NSString *)password nextSecureSalt:(NSData *)nextSecureSalt secureSaltOut:(NSData **)secureSaltOut;
+ (NSData *)decryptedSecureSecretWithData:(NSData *)data passord:(NSString *)password secureSalt:(NSData *)secureSalt;
+ (NSData *)decryptedSecureSecretWithData:(NSData *)data passwordHash:(NSData *)passwordHashData;

+ (NSArray *)typesForSecureValueTypes:(NSArray *)valueTypes;

+ (TGPassportType)typeForSecureValueType:(TLSecureValueType *)valueType;

+ (void)storePasswordHash:(NSData *)passwordHash secretPasswordHash:(NSData *)secretPasswordHash;
+ (NSData *)storedPasswordHash;
+ (NSData *)storedSecretPasswordHash;
+ (void)clearStoredPasswordHashes;

@end
