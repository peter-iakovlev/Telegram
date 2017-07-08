#import "TGSharedMediaVoiceMessageItem.h"

#import "TGSharedMediaDirectionFilter.h"

@interface TGSharedMediaVoiceMessageItem ()
{
    TGMessage *_message;
    int32_t _messageId;
    NSTimeInterval _date;
    bool _incoming;
}
@end

@implementation TGSharedMediaVoiceMessageItem

- (instancetype)initWithMessage:(TGMessage *)message messageId:(int32_t)messageId date:(NSTimeInterval)date incoming:(bool)incoming documentMediaAttachment:(TGDocumentMediaAttachment *)documentMediaAttachment
{
    self = [super init];
    if (self != nil)
    {
        _message = message;
        _messageId = messageId;
        _date = date;
        _incoming = incoming;
        _documentMediaAttachment = documentMediaAttachment;
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)__unused zone
{
    return [[TGSharedMediaVoiceMessageItem alloc] initWithMessage:_message messageId:_messageId date:_date incoming:_incoming documentMediaAttachment:_documentMediaAttachment];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGSharedMediaVoiceMessageItem class]] && ((TGSharedMediaVoiceMessageItem *)object)->_messageId == _messageId && ((TGSharedMediaVoiceMessageItem *)object)->_incoming == _incoming;
}

- (NSUInteger)hash
{
    return _messageId;
}

- (TGMessage *)message
{
    return _message;
}

- (int32_t)messageId
{
    return _messageId;
}

- (NSTimeInterval)date
{
    return _date;
}

- (bool)passesFilter:(id<TGSharedMediaFilter>)filter
{
    if ([filter isKindOfClass:[TGSharedMediaDirectionFilter class]])
    {
        switch (((TGSharedMediaDirectionFilter *)filter).direction)
        {
            case TGSharedMediaDirectionBoth:
                return true;
            case TGSharedMediaDirectionIncoming:
                return _incoming;
            case TGSharedMediaDirectionOutgoing:
                return !_incoming;
        }
    }
    return false;
}

@end
