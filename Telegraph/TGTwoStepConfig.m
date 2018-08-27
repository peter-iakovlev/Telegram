#import "TGTwoStepConfig.h"

#import "TLMetaScheme.h"

@implementation TGTwoStepConfig

- (instancetype)initWithHasPassword:(bool)hasPassword hasRecovery:(bool)hasRecovery hasSecureValues:(bool)hasSecureValues currentAlgo:(TGPasswordKdfAlgo *)currentAlgo currentHint:(NSString *)currentHint unconfirmedEmailPattern:(NSString *)unconfirmedEmailPattern nextAlgo:(TGPasswordKdfAlgo *)nextAlgo nextSecureAlgo:(TGSecurePasswordKdfAlgo *)nextSecureAlgo secureRandom:(NSData *)secureRandom srpId:(int64_t)srpId srpB:(NSData *)srpB
{
    self = [super init];
    if (self != nil)
    {
        _hasPassword = hasPassword;
        _hasRecovery = hasRecovery;
        _hasSecureValues = hasSecureValues;
        _currentAlgo = currentAlgo;
        _currentHint = currentHint;
        _unconfirmedEmailPattern = unconfirmedEmailPattern;
        _nextAlgo = nextAlgo;
        _nextSecureAlgo = nextSecureAlgo;
        _secureRandom = secureRandom;
        _srpId = srpId;
        _srpB = srpB;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGTwoStepConfig class]] && ((TGTwoStepConfig *)object)->_hasPassword == _hasPassword && ((TGTwoStepConfig *)object)->_hasRecovery == _hasRecovery && ((TGTwoStepConfig *)object)->_hasSecureValues == _hasSecureValues && TGObjectCompare(((TGTwoStepConfig *)object)->_currentAlgo, _currentAlgo) && TGStringCompare(((TGTwoStepConfig *)object)->_currentHint, _currentHint) && TGStringCompare(((TGTwoStepConfig *)object)->_unconfirmedEmailPattern, _unconfirmedEmailPattern) && TGObjectCompare(((TGTwoStepConfig *)object)->_nextAlgo, _nextAlgo) && TGObjectCompare(((TGTwoStepConfig *)object)->_nextSecureAlgo, _nextSecureAlgo) && TGObjectCompare(((TGTwoStepConfig *)object)->_secureRandom, _secureRandom) && ((TGTwoStepConfig *)object)->_srpId == _srpId && TGObjectCompare(((TGTwoStepConfig *)object)->_srpB, _srpB);
}

@end


@implementation TGPasswordSettings

- (instancetype)initWithPassword:(NSString *)password email:(NSString *)email secret:(NSData *)secret secretHash:(int64_t)secretHash secureAlgo:(TGSecurePasswordKdfAlgo *)secureAlgo
{
    self = [super init];
    if (self != nil)
    {
        _password = password;
        _email = email;
        _secret = secret;
        _secretHash = secretHash;
        _secureAlgo = secureAlgo;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGPasswordSettings class]] && ((TGPasswordSettings *)object)->_password == _password && TGObjectCompare(((TGPasswordSettings *)object)->_email, _email) && TGObjectCompare(((TGPasswordSettings *)object)->_secret, _secret) && ((TGPasswordSettings *)object)->_secretHash == _secretHash && TGObjectCompare(((TGPasswordSettings *)object)->_secureAlgo, _secureAlgo);
}

@end


@implementation TGPasswordKdfAlgoUnknown

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGPasswordKdfAlgoUnknown class]];
}

@end

@implementation TGPasswordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow

- (TLPasswordKdfAlgo *)tl
{
    TLPasswordKdfAlgo$passwordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow *algo = [[TLPasswordKdfAlgo$passwordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow alloc] init];
    algo.salt1 = self.salt1;
    algo.salt2 = self.salt2;
    algo.g = self.g;
    algo.p = self.p;
    return algo;
}

- (instancetype)initWithSalt1:(NSData *)salt1 salt2:(NSData *)salt2 g:(int32_t)g p:(NSData *)p
{
    self = [super init];
    if (self != nil)
    {
        _salt1 = salt1;
        _salt2 = salt2;
        _g = g;
        _p = p;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGPasswordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow class]] && TGObjectCompare(((TGPasswordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow *)object)->_salt1, _salt1) && TGObjectCompare(((TGPasswordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow *)object)->_salt2, _salt2) && ((TGPasswordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow *)object)->_g == _g && TGObjectCompare(((TGPasswordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow *)object)->_p, _p);
}

@end

@implementation TGPasswordKdfAlgo

- (TLPasswordKdfAlgo *)tl
{
    return [[TLPasswordKdfAlgo$passwordKdfAlgoUnknown alloc] init];
}

+ (instancetype)algoWithTL:(TLPasswordKdfAlgo *)tl
{
    if (tl == nil)
        return nil;
    
    if ([tl isKindOfClass:[TLPasswordKdfAlgo$passwordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow class]])
    {
        return [[TGPasswordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow alloc] initWithSalt1:((TLPasswordKdfAlgo$passwordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow *)tl).salt1 salt2:((TLPasswordKdfAlgo$passwordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow *)tl).salt2 g:((TLPasswordKdfAlgo$passwordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow *)tl).g p:((TLPasswordKdfAlgo$passwordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow *)tl).p];
    }
    
    return [[TGPasswordKdfAlgoUnknown alloc] init];
}

@end

@implementation TGSecurePasswordKdfAlgoUnknown

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGSecurePasswordKdfAlgoUnknown class]];
}

@end

@implementation TGSecurePasswordKdfAlgoPBKDF2HMACSHA512iter100000

- (instancetype)initWithSalt:(NSData *)salt
{
    self = [super init];
    if (self != nil)
    {
        _salt = salt;
    }
    return self;
}

- (TLSecurePasswordKdfAlgo *)tl
{
    TLSecurePasswordKdfAlgo$securePasswordKdfAlgoPBKDF2HMACSHA512iter100000 *algo = [[TLSecurePasswordKdfAlgo$securePasswordKdfAlgoPBKDF2HMACSHA512iter100000 alloc] init];
    algo.salt = self.salt;
    return algo;
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGSecurePasswordKdfAlgoPBKDF2HMACSHA512iter100000 class]] && TGObjectCompare(((TGSecurePasswordKdfAlgoPBKDF2HMACSHA512iter100000 *)object)->_salt, _salt);
}

@end

@implementation TGSecurePasswordKdfAlgoSHA512

- (instancetype)initWithSalt:(NSData *)salt
{
    self = [super init];
    if (self != nil)
    {
        _salt = salt;
    }
    return self;
}

- (TLSecurePasswordKdfAlgo *)tl
{
    TLSecurePasswordKdfAlgo$securePasswordKdfAlgoSHA512 *algo = [[TLSecurePasswordKdfAlgo$securePasswordKdfAlgoSHA512 alloc] init];
    algo.salt = self.salt;
    return algo;
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGSecurePasswordKdfAlgoSHA512 class]] && TGObjectCompare(((TGSecurePasswordKdfAlgoSHA512 *)object)->_salt, _salt);
}

@end

@implementation TGSecurePasswordKdfAlgo

- (TLSecurePasswordKdfAlgo *)tl
{
    return [[TLSecurePasswordKdfAlgo$securePasswordKdfAlgoUnknown alloc] init];
}

+ (instancetype)algoWithTL:(TLSecurePasswordKdfAlgo *)tl
{
    if (tl == nil)
        return nil;
    
    if ([tl isKindOfClass:[TLSecurePasswordKdfAlgo$securePasswordKdfAlgoPBKDF2HMACSHA512iter100000 class]])
    {
        return [[TGSecurePasswordKdfAlgoPBKDF2HMACSHA512iter100000 alloc] initWithSalt:((TLSecurePasswordKdfAlgo$securePasswordKdfAlgoPBKDF2HMACSHA512iter100000 *)tl).salt];
    }
    else if ([tl isKindOfClass:[TLSecurePasswordKdfAlgo$securePasswordKdfAlgoSHA512 class]])
    {
        return [[TGSecurePasswordKdfAlgoSHA512 alloc] initWithSalt:((TLSecurePasswordKdfAlgo$securePasswordKdfAlgoSHA512 *)tl).salt];
    }
    
    return [[TGSecurePasswordKdfAlgoUnknown alloc] init];
}

@end
