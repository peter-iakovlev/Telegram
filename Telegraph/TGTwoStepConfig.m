#import "TGTwoStepConfig.h"

@implementation TGTwoStepConfig

- (instancetype)initWithNextSalt:(NSData *)nextSalt currentSalt:(NSData *)currentSalt hasRecovery:(bool)hasRecovery currentHint:(NSString *)currentHint unconfirmedEmailPattern:(NSString *)unconfirmedEmailPattern
{
    self = [super init];
    if (self != nil)
    {
        _nextSalt = nextSalt;
        _currentSalt = currentSalt;
        _hasRecovery = hasRecovery;
        _currentHint = currentHint;
        _unconfirmedEmailPattern = unconfirmedEmailPattern;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGTwoStepConfig class]] && TGObjectCompare(((TGTwoStepConfig *)object)->_nextSalt, _nextSalt) && TGObjectCompare(((TGTwoStepConfig *)object)->_currentSalt, _currentSalt) && ((TGTwoStepConfig *)object)->_hasRecovery == _hasRecovery && TGStringCompare(((TGTwoStepConfig *)object)->_currentHint, _currentHint) && TGStringCompare(((TGTwoStepConfig *)object)->_unconfirmedEmailPattern, _unconfirmedEmailPattern);
}

@end
