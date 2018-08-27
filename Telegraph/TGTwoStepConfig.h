#import <Foundation/Foundation.h>

@class TLPasswordKdfAlgo;
@class TLSecurePasswordKdfAlgo;

@interface TGPasswordKdfAlgo : NSObject

- (TLPasswordKdfAlgo *)tl;

+ (instancetype)algoWithTL:(TLPasswordKdfAlgo *)tl;

@end

@interface TGPasswordKdfAlgoUnknown : TGPasswordKdfAlgo
@end

@interface TGPasswordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow : TGPasswordKdfAlgo

@property (nonatomic, readonly) NSData *salt1;
@property (nonatomic, readonly) NSData *salt2;
@property (nonatomic, readonly) int32_t g;
@property (nonatomic, readonly) NSData *p;

- (instancetype)initWithSalt1:(NSData *)salt1 salt2:(NSData *)salt2 g:(int32_t)g p:(NSData *)p;

@end


@interface TGSecurePasswordKdfAlgo : NSObject

- (TLSecurePasswordKdfAlgo *)tl;

+ (instancetype)algoWithTL:(TLSecurePasswordKdfAlgo *)tl;

@end

@interface TGSecurePasswordKdfAlgoUnknown : TGSecurePasswordKdfAlgo

@end

@interface TGSecurePasswordKdfAlgoPBKDF2HMACSHA512iter100000 : TGSecurePasswordKdfAlgo

@property (nonatomic, readonly) NSData *salt;

- (instancetype)initWithSalt:(NSData *)salt;

@end

@interface TGSecurePasswordKdfAlgoSHA512 : TGSecurePasswordKdfAlgo

@property (nonatomic, readonly) NSData *salt;

@end

@interface TGTwoStepConfig : NSObject

@property (nonatomic, readonly) bool hasPassword;
@property (nonatomic, readonly) bool hasRecovery;
@property (nonatomic, readonly) bool hasSecureValues;
@property (nonatomic, strong, readonly) TGPasswordKdfAlgo *currentAlgo;
@property (nonatomic, strong, readonly) NSString *currentHint;
@property (nonatomic, strong, readonly) NSString *unconfirmedEmailPattern;
@property (nonatomic, strong, readonly) TGPasswordKdfAlgo *nextAlgo;
@property (nonatomic, strong, readonly) TGSecurePasswordKdfAlgo *nextSecureAlgo;
@property (nonatomic, strong, readonly) NSData *secureRandom;

@property (nonatomic, readonly) int64_t srpId;
@property (nonatomic, strong, readonly) NSData *srpB;

- (instancetype)initWithHasPassword:(bool)hasPassword hasRecovery:(bool)hasRecovery hasSecureValues:(bool)hasSecureValues currentAlgo:(TGPasswordKdfAlgo *)currentAlgo currentHint:(NSString *)currentHint unconfirmedEmailPattern:(NSString *)unconfirmedEmailPattern nextAlgo:(TGPasswordKdfAlgo *)nextAlgo nextSecureAlgo:(TGSecurePasswordKdfAlgo *)nextSecureAlgo secureRandom:(NSData *)secureRandom srpId:(int64_t)srpId srpB:(NSData *)srpB;

@end


@interface TGPasswordSettings : NSObject

@property (nonatomic, strong, readonly) NSString *password;
@property (nonatomic, strong, readonly) NSString *email;
@property (nonatomic, strong, readonly) NSData *secret;
@property (nonatomic, readonly) int64_t secretHash;
@property (nonatomic, strong, readonly) TGSecurePasswordKdfAlgo *secureAlgo;

- (instancetype)initWithPassword:(NSString *)password email:(NSString *)email secret:(NSData *)secret secretHash:(int64_t)secretHash secureAlgo:(TGSecurePasswordKdfAlgo *)secureAlgo;

@end
