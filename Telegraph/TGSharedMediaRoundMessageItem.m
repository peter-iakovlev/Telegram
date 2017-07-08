#import "TGSharedMediaRoundMessageItem.h"

#import "TGSharedMediaDirectionFilter.h"

@interface TGSharedMediaRoundMessageItem ()
{
    TGMessage *_message;
    int32_t _messageId;
    NSTimeInterval _date;
    bool _incoming;
}
@end

@implementation TGSharedMediaRoundMessageItem

- (instancetype)initWithMessage:(TGMessage *)message messageId:(int32_t)messageId date:(NSTimeInterval)date incoming:(bool)incoming videoMediaAttachment:(TGVideoMediaAttachment *)videoMediaAttachment
{
    self = [super init];
    if (self != nil)
    {
        _message = message;
        _messageId = messageId;
        _date = date;
        _incoming = incoming;
        _videoMediaAttachment = videoMediaAttachment;
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)__unused zone
{
    return [[TGSharedMediaRoundMessageItem alloc] initWithMessage:_message messageId:_messageId date:_date incoming:_incoming videoMediaAttachment:_videoMediaAttachment];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGSharedMediaRoundMessageItem class]] && ((TGSharedMediaRoundMessageItem *)object)->_messageId == _messageId && ((TGSharedMediaRoundMessageItem *)object)->_incoming == _incoming;
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
