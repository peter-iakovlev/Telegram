#import "TGTwoStepConfig.h"

@implementation TGTwoStepConfig

- (instancetype)initWithNextSalt:(NSData *)nextSalt currentSalt:(NSData *)currentSalt secretRandom:(NSData *)secretRandom nextSecureSalt:(NSData *)nextSecureSalt hasRecovery:(bool)hasRecovery hasSecureValues:(bool)hasSecureValues currentHint:(NSString *)currentHint unconfirmedEmailPattern:(NSString *)unconfirmedEmailPattern
{
    self = [super init];
    if (self != nil)
    {
        _nextSalt = nextSalt;
        _currentSalt = currentSalt;
        _secretRandom = secretRandom;
        _nextSecureSalt = nextSecureSalt;
        _hasRecovery = hasRecovery;
        _hasSecureValues = hasSecureValues;
        _currentHint = currentHint;
        _unconfirmedEmailPattern = unconfirmedEmailPattern;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGTwoStepConfig class]] && TGObjectCompare(((TGTwoStepConfig *)object)->_nextSalt, _nextSalt) && TGObjectCompare(((TGTwoStepConfig *)object)->_currentSalt, _currentSalt) && TGObjectCompare(((TGTwoStepConfig *)object)->_secretRandom, _secretRandom) && TGObjectCompare(((TGTwoStepConfig *)object)->_nextSecureSalt, _nextSecureSalt) && ((TGTwoStepConfig *)object)->_hasRecovery == _hasRecovery && ((TGTwoStepConfig *)object)->_hasSecureValues == _hasSecureValues && TGStringCompare(((TGTwoStepConfig *)object)->_currentHint, _currentHint) && TGStringCompare(((TGTwoStepConfig *)object)->_unconfirmedEmailPattern, _unconfirmedEmailPattern);
}

@end


@implementation TGPasswordSettings

- (instancetype)initWithPassword:(NSString *)password email:(NSString *)email secret:(NSData *)secret secretHash:(int64_t)secretHash secureSalt:(NSData *)secureSalt
{
    self = [super init];
    if (self != nil)
    {
        _password = password;
        _email = email;
        _secret = secret;
        _secretHash = secretHash;
        _secureSalt = secureSalt;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGPasswordSettings class]]  && ((TGPasswordSettings *)object)->_password == _password && TGObjectCompare(((TGPasswordSettings *)object)->_email, _email) && TGObjectCompare(((TGPasswordSettings *)object)->_secret, _secret) && ((TGPasswordSettings *)object)->_secretHash == _secretHash && TGObjectCompare(((TGPasswordSettings *)object)->_secureSalt, _secureSalt);
}

@end
