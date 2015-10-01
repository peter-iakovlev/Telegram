#import "TGMessage.h"

#import "PSKeyValueCoder.h"
#import "PSKeyValueEncoder.h"
#import "PSKeyValueDecoder.h"

#import "TGTextCheckingResult.h"

#include <tr1/unordered_map>

static std::tr1::unordered_map<int, id<TGMediaAttachmentParser> > mediaAttachmentParsers;

typedef enum {
    TGMessageFlagBroadcast = 1,
    TGMessageFlagLayerMask = 2 | 4 | 8 | 16 | 32,
    TGMessageFlagContainsMention = 64,
    TGMessageFlagForceReply = (1 << 7)
} TGMessageFlags;


@interface TGMessage ()

@property (nonatomic) bool hasNoCheckingResults;

@end

@implementation TGMessage

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    TGMessage *object = [[TGMessage alloc] init];
    
    object->_mid = [coder decodeInt32ForCKey:"i"];
    
    [coder decodeBytesForCKey:"sk" value:object->_sortKey.key length:8 + 1 + 4 + 4];
    
    object->_pts = [coder decodeInt32ForCKey:"pts"];
    
    object->_unread = [coder decodeInt32ForCKey:"unr"] != 0;
    object->_outgoing = [coder decodeInt32ForCKey:"out"] != 0;
    object->_deliveryState = (TGMessageDeliveryState)[coder decodeInt32ForCKey:"ds"];
    object->_fromUid = [coder decodeInt64ForCKey:"fi"];
    object->_toUid = [coder decodeInt64ForCKey:"ti"];
    object->_cid = [coder decodeInt64ForCKey:"ci"];
    
    object->_text = [coder decodeStringForCKey:"t"];
    object->_date = [coder decodeInt32ForCKey:"d"];
    object.mediaAttachments = [TGMessage parseMediaAttachments:[coder decodeDataCorCKey:"md"]];
    
    object->_realDate = [coder decodeInt32ForCKey:"rd"];
    object->_randomId = [coder decodeInt64ForCKey:"ri"];
    
    object->_messageLifetime = [coder decodeInt32ForCKey:"lt"];
    object->_flags = [coder decodeInt64ForCKey:"f"];
    object->_seqIn = [coder decodeInt32ForCKey:"sqi"];
    object->_seqOut = [coder decodeInt32ForCKey:"sqo"];
    
    object->_contentProperties = [TGMessage parseContentProperties:[coder decodeDataCorCKey:"cpr"]];
    
    return object;
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeInt32:_mid forCKey:"i"];
    
    [coder encodeBytes:_sortKey.key length:8 + 1 + 4 + 4 forCKey:"sk"];
    
    [coder encodeInt32:_pts forCKey:"pts"];
    
    [coder encodeInt32:_unread ? 1 : 0 forCKey:"unr"];
    [coder encodeInt32:_outgoing ? 1 : 0 forCKey:"out"];
    [coder encodeInt32:_deliveryState forCKey:"ds"];
    [coder encodeInt64:_fromUid forCKey:"fi"];
    [coder encodeInt64:_toUid forCKey:"ti"];
    [coder encodeInt64:_cid forCKey:"ci"];
    
    [coder encodeString:_text forCKey:"t"];
    [coder encodeInt32:(int32_t)_date forCKey:"d"];
    [coder encodeData:[self serializeMediaAttachments:true] forCKey:"md"];
    
    [coder encodeInt32:(int32_t)_realDate forCKey:"rd"];
    [coder encodeInt64:_randomId forCKey:"ri"];
    
    [coder encodeInt32:_messageLifetime forCKey:"lt"];
    [coder encodeInt64:_flags forCKey:"f"];
    
    [coder encodeInt32:_seqIn forCKey:"sqi"];
    [coder encodeInt32:_seqOut forCKey:"sqo"];
    
    [coder encodeData:[self serializeContentProperties] forCKey:"cpr"];
}

- (id)copyWithZone:(NSZone *)__unused zone
{
    TGMessage *copyMessage = [[TGMessage alloc] init];
    
    copyMessage->_mid = _mid;
    copyMessage->_sortKey = _sortKey;
    copyMessage->_pts = _pts;
    copyMessage->_ptsCount = _ptsCount;
    copyMessage->_unread = _unread;
    copyMessage->_outgoing = _outgoing;
    copyMessage->_deliveryState = _deliveryState;
    copyMessage->_fromUid = _fromUid;
    copyMessage->_toUid = _toUid;
    copyMessage->_cid = _cid;
    
    copyMessage->_text = _text;
    copyMessage->_date = _date;
    copyMessage->_mediaAttachments = [[NSArray alloc] initWithArray:_mediaAttachments];
    
    copyMessage->_realDate = _realDate;
    copyMessage->_randomId = _randomId;
    
    copyMessage->_actionInfo = _actionInfo;
    
    copyMessage->_textCheckingResults = _textCheckingResults;
    
    copyMessage->_messageLifetime = _messageLifetime;
    copyMessage->_flags = _flags;
    
    copyMessage->_seqIn = _seqIn;
    copyMessage->_seqOut = _seqOut;
    
    copyMessage->_contentProperties = [[NSDictionary alloc] initWithDictionary:_contentProperties];
    
    copyMessage->_hideReplyMarkup = _hideReplyMarkup;
    
    copyMessage->_hole = _hole;
    copyMessage->_group = _group;
    
    return copyMessage;
}

- (TGMessageTransparentSortKey)transparentSortKey
{
    return TGMessageTransparentSortKeyMake(TGMessageSortKeyPeerId(_sortKey), TGMessageSortKeyTimestamp(_sortKey), TGMessageSortKeyMid(_sortKey), TGMessageSortKeySpace(_sortKey));
}

- (void)setIsBroadcast:(bool)isBroadcast
{
    if (isBroadcast)
        _flags |= TGMessageFlagBroadcast;
    else
        _flags &= ~TGMessageFlagBroadcast;
}

- (bool)isBroadcast
{
    return _flags & TGMessageFlagBroadcast;
}

- (void)setForceReply:(bool)forceReply
{
    if (forceReply)
        _flags |= TGMessageFlagForceReply;
    else
        _flags &= TGMessageFlagForceReply;
}

- (bool)forceReply
{
    return _flags & TGMessageFlagForceReply;
}

- (void)setLayer:(NSUInteger)layer
{
    _flags = (_flags & ~TGMessageFlagLayerMask) | ((layer & (1 | 2 | 4 | 8 | 16)) << 1);
}

- (NSUInteger)layer
{
    NSUInteger value = (_flags & TGMessageFlagLayerMask) >> 1;
    if (value < 1)
        value = 1;
    return value;
}

- (void)setContainsMention:(bool)containsMention
{
    if (containsMention)
        _flags |= TGMessageFlagContainsMention;
    else
        _flags &= (~TGMessageFlagContainsMention);
}

- (bool)containsMention
{
    return _flags & TGMessageFlagContainsMention;
}

+ (NSUInteger)layerFromFlags:(int64_t)flags
{
    NSUInteger value = (flags & TGMessageFlagLayerMask) >> 1;
    if (value < 1)
        value = 1;
    return value;
}

- (int64_t)forwardPeerId
{
    for (TGMediaAttachment *attachment in _mediaAttachments)
    {
        if (attachment.type == TGForwardedMessageMediaAttachmentType)
        {
            TGForwardedMessageMediaAttachment *forwardedMessageAttachment = (TGForwardedMessageMediaAttachment *)attachment;
            return forwardedMessageAttachment.forwardPeerId;
        }
    }
    
    return 0;
}

- (TGMessageViewCountContentProperty *)viewCount {
    return _contentProperties[@"viewCount"];
}

- (void)setViewCount:(TGMessageViewCountContentProperty *)viewCount {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:_contentProperties];
    if (viewCount != nil) {
        dict[@"viewCount"] = viewCount;
    } else {
        [dict removeObjectForKey:@"viewCount"];
    }
    _contentProperties = dict;
}

- (void)setText:(NSString *)text
{
    _text = text;
    
    _textCheckingResults = nil;
    _hasNoCheckingResults = false;
}

- (bool)local
{
    return _mid >= TGMessageLocalMidBaseline;
}

+ (NSArray *)textCheckingResultsForText:(NSString *)text highlightMentionsAndTags:(bool)highlightMentionsAndTags highlightCommands:(bool)highlightCommands
{
    bool containsSomething = false;
    
    int length = (int)text.length;
    
    int digitsInRow = 0;
    int schemeSequence = 0;
    int dotSequence = 0;
    
    unichar lastChar = 0;
    
    SEL sel = @selector(characterAtIndex:);
    unichar (*characterAtIndexImp)(id, SEL, NSUInteger) = (typeof(characterAtIndexImp))[text methodForSelector:sel];
    
    for (int i = 0; i < length; i++)
    {
        unichar c = characterAtIndexImp(text, sel, i);
        
        if (highlightMentionsAndTags && (c == '@' || c == '#'))
        {
            containsSomething = true;
            break;
        }
        
        if (c >= '0' && c <= '9')
        {
            digitsInRow++;
            if (digitsInRow >= 6)
            {
                containsSomething = true;
                break;
            }
            
            schemeSequence = 0;
            dotSequence = 0;
        }
        else if (!(c != ' ' && digitsInRow > 0))
            digitsInRow = 0;
        
        if (c == ':')
        {
            if (schemeSequence == 0)
                schemeSequence = 1;
            else
                schemeSequence = 0;
        }
        else if (c == '/')
        {
            if (highlightCommands)
            {
                containsSomething = true;
                break;
            }
            
            if (schemeSequence == 2)
            {
                containsSomething = true;
                break;
            }
            
            if (schemeSequence == 1)
                schemeSequence++;
            else
                schemeSequence = 0;
        }
        else if (c == '.')
        {
            if (dotSequence == 0 && lastChar != ' ')
                dotSequence++;
            else
                dotSequence = 0;
        }
        else if (c != ' ' && lastChar == '.' && dotSequence == 1)
        {
            containsSomething = true;
            break;
        }
        else
        {
            dotSequence = 0;
        }
        
        lastChar = c;
    }
    
    if (containsSomething)
    {
        NSError *error = nil;
        static NSDataDetector *dataDetector = nil;
        if (dataDetector == nil)
            dataDetector = [NSDataDetector dataDetectorWithTypes:(int)(NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber) error:&error];
        
        NSMutableArray *results = [[NSMutableArray alloc] init];
        [dataDetector enumerateMatchesInString:text options:0 range:NSMakeRange(0, text.length) usingBlock:^(NSTextCheckingResult *match, __unused NSMatchingFlags flags, __unused BOOL *stop)
        {
            NSTextCheckingType type = [match resultType];
            if (type == NSTextCheckingTypeLink || type == NSTextCheckingTypePhoneNumber)
            {
                [results addObject:match];
            }
        }];
        
        static NSCharacterSet *characterSet = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            characterSet = [NSCharacterSet alphanumericCharacterSet];
        });
        
        if (containsSomething && (highlightMentionsAndTags || highlightCommands))
        {
            int mentionStart = -1;
            int hashtagStart = -1;
            int commandStart = -1;
            
            unichar previous = 0;
            for (int i = 0; i < length; i++)
            {
                unichar c = characterAtIndexImp(text, sel, i);
                if (highlightMentionsAndTags && commandStart == -1)
                {
                    if (mentionStart != -1)
                    {
                        if (!((c >= '0' && c <= '9') || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_'))
                        {
                            if (i > mentionStart + 1)
                            {
                                NSRange range = NSMakeRange(mentionStart + 1, i - mentionStart - 1);
                                NSRange mentionRange = NSMakeRange(range.location - 1, range.length + 1);
                                
                                unichar mentionStartChar = [text characterAtIndex:mentionRange.location + 1];
                                if (!(mentionRange.length <= 5 || (mentionStartChar >= '0' && mentionStartChar <= '9')))
                                {
                                    [results addObject:[[TGTextCheckingResult alloc] initWithRange:mentionRange type:TGTextCheckingResultTypeMention contents:[text substringWithRange:range]]];
                                }
                            }
                            mentionStart = -1;
                        }
                    }
                    else if (hashtagStart != -1)
                    {
                        if (c == ' ' || (![characterSet characterIsMember:c] && c != '_'))
                        {
                            if (i > hashtagStart + 1)
                            {
                                NSRange range = NSMakeRange(hashtagStart + 1, i - hashtagStart - 1);
                                NSRange hashtagRange = NSMakeRange(range.location - 1, range.length + 1);
                                
                                [results addObject:[[TGTextCheckingResult alloc] initWithRange:hashtagRange type:TGTextCheckingResultTypeHashtag contents:[text substringWithRange:range]]];
                            }
                            hashtagStart = -1;
                        }
                    }
                    
                    if (c == '@')
                    {
                        mentionStart = i;
                    }
                    else if (c == '#')
                    {
                        hashtagStart = i;
                    }
                }
                
                if (highlightCommands && mentionStart == -1 && hashtagStart == -1)
                {
                    if (commandStart != -1 && ![characterSet characterIsMember:c] && c != '@' && c != '_')
                    {
                        if (i - commandStart > 1)
                        {
                            NSRange range = NSMakeRange(commandStart, i - commandStart);
                            [results addObject:[[TGTextCheckingResult alloc] initWithRange:range type:TGTextCheckingResultTypeCommand contents:[text substringWithRange:range]]];
                        }
                        
                        commandStart = -1;
                    }
                    else if (c == '/' && (previous == 0 || previous == ' ' || previous == '\n' || previous == '\t'))
                    {
                        commandStart = i;
                    }
                }
                previous = c;
            }
            
            if (mentionStart != -1 && mentionStart + 1 < length - 1)
            {
                NSRange range = NSMakeRange(mentionStart + 1, length - mentionStart - 1);
                NSRange mentionRange = NSMakeRange(range.location - 1, range.length + 1);
                unichar mentionStartChar = [text characterAtIndex:mentionRange.location + 1];
                if (!(mentionRange.length <= 5 || (mentionStartChar >= '0' && mentionStartChar <= '9')))
                {
                    [results addObject:[[TGTextCheckingResult alloc] initWithRange:mentionRange type:TGTextCheckingResultTypeMention contents:[text substringWithRange:range]]];
                }
            }
            
            if (hashtagStart != -1 && hashtagStart + 1 < length - 1)
            {
                NSRange range = NSMakeRange(hashtagStart + 1, length - hashtagStart - 1);
                NSRange hashtagRange = NSMakeRange(range.location - 1, range.length + 1);
                [results addObject:[[TGTextCheckingResult alloc] initWithRange:hashtagRange type:TGTextCheckingResultTypeHashtag contents:[text substringWithRange:range]]];
            }
            
            if (commandStart != -1 && commandStart + 1 < length)
            {
                NSRange range = NSMakeRange(commandStart, length - commandStart);
                [results addObject:[[TGTextCheckingResult alloc] initWithRange:range type:TGTextCheckingResultTypeCommand contents:[text substringWithRange:range]]];
            }
        }
        
        return results;
    }
    
    return nil;
}

- (NSArray *)textCheckingResults
{
    if (_text.length < 2 || _text.length > 1024 * 20)
        return nil;
    
    if (_textCheckingResults == nil && !_hasNoCheckingResults)
    {
        _textCheckingResults = [TGMessage textCheckingResultsForText:_text highlightMentionsAndTags:true highlightCommands:true];
        _hasNoCheckingResults = _textCheckingResults == nil;
    }
    
    return _textCheckingResults;
}

- (void)setReplyMarkup:(TGBotReplyMarkup *)replyMarkup
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:_mediaAttachments];
    NSUInteger index = 0;
    for (TGMediaAttachment *attachment in array)
    {
        if (attachment.type == TGReplyMarkupAttachmentType)
        {
            [array removeObjectAtIndex:index];
            break;
        }
        index++;
    }
    TGReplyMarkupAttachment *attachment = [[TGReplyMarkupAttachment alloc] init];
    attachment.replyMarkup = replyMarkup;
    [array addObject:attachment];
    _mediaAttachments = array;
}

- (TGBotReplyMarkup *)replyMarkup
{
    for (TGMediaAttachment *attachment in _mediaAttachments)
    {
        if (attachment.type == TGReplyMarkupAttachmentType)
        {
            return ((TGReplyMarkupAttachment *)attachment).replyMarkup;
        }
    }
    
    return nil;
}

- (void)setEntities:(NSArray *)entities
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:_mediaAttachments];
    NSUInteger index = 0;
    for (TGMediaAttachment *attachment in array)
    {
        if (attachment.type == TGMessageEntitiesAttachmentType)
        {
            [array removeObjectAtIndex:index];
            break;
        }
        index++;
    }
    TGMessageEntitiesAttachment *attachment = [[TGMessageEntitiesAttachment alloc] init];
    attachment.entities = entities;
    [array addObject:attachment];
    _mediaAttachments = array;
}

- (NSArray *)entities
{
    for (TGMediaAttachment *attachment in _mediaAttachments)
    {
        if (attachment.type == TGMessageEntitiesAttachmentType)
        {
            return ((TGMessageEntitiesAttachment *)attachment).entities;
        }
    }
    
    return nil;
}

+ (void)registerMediaAttachmentParser:(int)type parser:(id<TGMediaAttachmentParser>)parser
{
    mediaAttachmentParsers.insert(std::pair<int, id<TGMediaAttachmentParser> >(type, parser));
}

- (NSData *)serializeMediaAttachments:(bool)includeMeta
{
    if (_mediaAttachments == nil || _mediaAttachments.count == 0)
        return [NSData data];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    int count = 0;
    NSRange countRange = NSMakeRange(data.length, 4);
    [data appendBytes:&count length:4];
    
    for (TGMediaAttachment *attachment in _mediaAttachments)
    {
        if (!includeMeta && attachment.isMeta)
            continue;
        
        int type = attachment.type;
        [data appendBytes:&type length:4];
        
        [attachment serialize:data];
        
        count++;
    }
    
    [data replaceBytesInRange:countRange withBytes:&count];
    
    return data;
}

+ (NSData *)serializeMediaAttachments:(bool)includeMeta attachments:(NSArray *)attachments
{
    if (attachments == nil || attachments.count == 0)
        return [NSData data];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    int count = 0;
    NSRange countRange = NSMakeRange(data.length, 4);
    [data appendBytes:&count length:4];
    for (TGMediaAttachment *attachment in attachments)
    {
        if (!includeMeta && attachment.isMeta)
            continue;
        
        int type = attachment.type;
        [data appendBytes:&type length:4];
        
        [attachment serialize:data];
        
        count++;
    }
    
    [data replaceBytesInRange:countRange withBytes:&count];
    
    return data;
}

+ (NSData *)serializeAttachment:(TGMediaAttachment *)attachment
{
    if (attachment == nil)
        return [NSData data];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    int count = 1;
    [data appendBytes:&count length:4];

    int type = attachment.type;
    [data appendBytes:&type length:4];
    
    [attachment serialize:data];
    
    return data;
}

- (void)setMediaAttachments:(NSArray *)mediaAttachments
{
    for (TGMediaAttachment *attachment in mediaAttachments)
    {
        if (attachment.type == TGActionMediaAttachmentType) {
            _actionInfo = (TGActionMediaAttachment *)attachment;
        }
    }
    
    _mediaAttachments = mediaAttachments;
}

+ (NSArray *)parseMediaAttachments:(NSData *)data
{
    if (data == nil || data.length == 0)
        return [NSArray array];
    
    NSInputStream *is = [[NSInputStream alloc] initWithData:data];
    [is open];
    
    int count = 0;
    [is read:(uint8_t *)&count maxLength:4];
    NSMutableArray *attachments = [[NSMutableArray alloc] initWithCapacity:count];
    
    for (int i = 0; i < count; i++)
    {
        int type = 0;
        [is read:(uint8_t *)&type maxLength:4];
        
        std::tr1::unordered_map<int, id<TGMediaAttachmentParser> >::iterator it = mediaAttachmentParsers.find(type);
        if (it == mediaAttachmentParsers.end())
        {
            TGLog(@"***** Unknown media attachment type %d", type);
            return [NSArray array];
        }
        
        TGMediaAttachment *attachment = [it->second parseMediaAttachment:is];
        if (attachment != nil)
        {
            [attachments addObject:attachment];
        }
    }
    
    [is close];
    
    return [NSArray arrayWithArray:attachments];
}

- (NSData *)serializeContentProperties
{
    if (_contentProperties.count == 0)
        return nil;
    
    PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
    [_contentProperties enumerateKeysAndObjectsUsingBlock:^(NSString *key, id<PSCoding> value, __unused BOOL *stop)
    {
        [encoder encodeObject:value forKey:key];
    }];
    
    return encoder.data;
}

+ (NSData *)serializeContentProperties:(NSDictionary *)contentProperties
{
    if (contentProperties.count == 0)
        return nil;
    
    PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
    [contentProperties enumerateKeysAndObjectsUsingBlock:^(NSString *key, id<PSCoding> value, __unused BOOL *stop)
    {
        [encoder encodeObject:value forKey:key];
    }];
    
    return encoder.data;
}

+ (NSDictionary *)parseContentProperties:(NSData *)data
{
    if (data.length == 0)
        return nil;
    
    PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] initWithData:data];
    return [decoder decodeObjectsByKeys];
}

@end

@interface TGMediaId ()
{
    int _cachedHash;
}

@end

@implementation TGMediaId

- (id)initWithType:(uint8_t)type itemId:(int64_t)itemId
{
    self = [super init];
    if (self != nil)
    {
        _type = type;
        _itemId = itemId;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)__unused zone
{
    TGMediaId *copyMediaId = [[TGMediaId alloc] initWithType:_type itemId:_itemId];
    return copyMediaId;
}

- (NSUInteger)hash
{
    if (_cachedHash == 0)
        _cachedHash = (int)(((_itemId >> 32) ^ _itemId & 0xffffffff) + (int)_type);
    return _cachedHash;
}

- (BOOL)isEqual:(id)anObject
{
    if (![anObject isKindOfClass:[TGMediaId class]])
        return false;
    
    TGMediaId *other = (TGMediaId *)anObject;
    return other.itemId == _itemId && other.type == _type;
}

@end

