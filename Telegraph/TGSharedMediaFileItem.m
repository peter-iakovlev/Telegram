#import "TGSharedMediaFileItem.h"

#import "TGSharedMediaDirectionFilter.h"

@interface TGSharedMediaFileItem ()
{
    TGMessage *_message;
    int32_t _messageId;
    NSTimeInterval _date;
    bool _incoming;
}

@end

@implementation TGSharedMediaFileItem

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
    return [[TGSharedMediaFileItem alloc] initWithMessage:_message messageId:_messageId date:_date incoming:_incoming documentMediaAttachment:_documentMediaAttachment];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGSharedMediaFileItem class]] && ((TGSharedMediaFileItem *)object)->_messageId == _messageId;
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
