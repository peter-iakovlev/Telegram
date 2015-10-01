#import "TGBotReplyMarkup.h"

#import "PSKeyValueCoder.h"

@implementation TGBotReplyMarkup

- (instancetype)initWithUserId:(int32_t)userId messageId:(int32_t)messageId rows:(NSArray *)rows matchDefaultHeight:(bool)matchDefaultHeight hideKeyboardOnActivation:(bool)hideKeyboardOnActivation alreadyActivated:(bool)alreadyActivated
{
    self = [super init];
    if (self != nil)
    {
        _userId = userId;
        _messageId = messageId;
        _rows = rows;
        _matchDefaultHeight = matchDefaultHeight;
        _hideKeyboardOnActivation = hideKeyboardOnActivation;
        _alreadyActivated = alreadyActivated;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    return [self initWithUserId:[coder decodeInt32ForCKey:"userId"] messageId:[coder decodeInt32ForCKey:"messageId"] rows:[coder decodeArrayForCKey:"rows"] matchDefaultHeight:[coder decodeInt32ForCKey:"matchDefaultHeight"] hideKeyboardOnActivation:[coder decodeInt32ForCKey:"hideKeyboardOnActivation"] alreadyActivated:[coder decodeInt32ForCKey:"alreadyActivated"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeInt32:_userId forCKey:"userId"];
    [coder encodeInt32:_messageId forCKey:"messageId"];
    [coder encodeArray:_rows forCKey:"rows"];
    [coder encodeInt32:_matchDefaultHeight forCKey:"matchDefaultHeight"];
    [coder encodeInt32:_hideKeyboardOnActivation forCKey:"hideKeyboardOnActivation"];
    [coder encodeInt32:_alreadyActivated forCKey:"alreadyActivated"];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGBotReplyMarkup class]] && [((TGBotReplyMarkup *)object)->_rows isEqual:_rows] && ((TGBotReplyMarkup *)object)->_userId == _userId && ((TGBotReplyMarkup *)object)->_messageId == _messageId && ((TGBotReplyMarkup *)object)->_matchDefaultHeight == _matchDefaultHeight;
}

- (TGBotReplyMarkup *)activatedMarkup
{
    if (_alreadyActivated)
        return self;
    
    return [[TGBotReplyMarkup alloc] initWithUserId:_userId messageId:_messageId rows:_rows matchDefaultHeight:_matchDefaultHeight hideKeyboardOnActivation:_hideKeyboardOnActivation alreadyActivated:true];
}

@end
