#import "TGSharedMediaImageItem.h"

#import "TGSharedMediaDirectionFilter.h"

@interface TGSharedMediaImageItem ()
{
    TGMessage *_message;
    int32_t _messageId;
    NSTimeInterval _date;
    bool _incoming;
}

@end

@implementation TGSharedMediaImageItem

- (instancetype)initWithMessage:(TGMessage *)message messageId:(int32_t)messageId date:(NSTimeInterval)date incoming:(bool)incoming imageMediaAttachment:(TGImageMediaAttachment *)imageMediaAttachment
{
    self = [super init];
    if (self != nil)
    {
        _message = message;
        _messageId = messageId;
        _date = date;
        _incoming = incoming;
        _imageMediaAttachment = imageMediaAttachment;
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)__unused zone
{
    return [[TGSharedMediaImageItem alloc] initWithMessage:_message messageId:_messageId date:_date incoming:_incoming imageMediaAttachment:_imageMediaAttachment];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGSharedMediaImageItem class]] && ((TGSharedMediaImageItem *)object)->_messageId == _messageId && ((TGSharedMediaImageItem *)object)->_incoming == _incoming;
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
