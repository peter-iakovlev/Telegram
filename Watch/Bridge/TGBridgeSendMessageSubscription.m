#import "TGBridgeSendMessageSubscription.h"

#import "TGBridgeLocationMediaAttachment.h"
#import "TGBridgeDocumentMediaAttachment.h"

NSString *const TGBridgeSendTextMessageSubscriptionName = @"sendMessage.text";
NSString *const TGBridgeSendTextMessageSubscriptionPeerIdKey = @"peerId";
NSString *const TGBridgeSendTextMessageSubscriptionTextKey = @"text";
NSString *const TGBridgeSendTextMessageSubscriptionReplyToMidKey = @"replyToMid";

@implementation TGBridgeSendTextMessageSubscription

- (instancetype)initWithPeerId:(int64_t)peerId text:(NSString *)text replyToMid:(int32_t)replyToMid
{
    self = [super init];
    if (self != nil)
    {
        _peerId = peerId;
        _text = text;
        _replyToMid = replyToMid;
    }
    return self;
}

- (bool)renewable
{
    return false;
}

- (void)_serializeParametersWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.peerId forKey:TGBridgeSendTextMessageSubscriptionPeerIdKey];
    [aCoder encodeObject:self.text forKey:TGBridgeSendTextMessageSubscriptionTextKey];
    [aCoder encodeInt32:self.replyToMid forKey:TGBridgeSendTextMessageSubscriptionReplyToMidKey];
}

- (void)_unserializeParametersWithCoder:(NSCoder *)aDecoder
{
    _peerId = [aDecoder decodeInt64ForKey:TGBridgeSendTextMessageSubscriptionPeerIdKey];
    _text = [aDecoder decodeObjectForKey:TGBridgeSendTextMessageSubscriptionTextKey];
    _replyToMid = [aDecoder decodeInt32ForKey:TGBridgeSendTextMessageSubscriptionReplyToMidKey];
}

+ (NSString *)subscriptionName
{
    return TGBridgeSendTextMessageSubscriptionName;
}

@end


NSString *const TGBridgeSendStickerMessageSubscriptionName = @"sendMessage.sticker";
NSString *const TGBridgeSendStickerMessageSubscriptionPeerIdKey = @"peerId";
NSString *const TGBridgeSendStickerMessageSubscriptionDocumentKey = @"document";
NSString *const TGBridgeSendStickerMessageSubscriptionReplyToMidKey = @"replyToMid";

@implementation TGBridgeSendStickerMessageSubscription

- (instancetype)initWithPeerId:(int64_t)peerId document:(TGBridgeDocumentMediaAttachment *)document replyToMid:(int32_t)replyToMid
{
    self = [super init];
    if (self != nil)
    {
        _peerId = peerId;
        _document = document;
        _replyToMid = replyToMid;
    }
    return self;
}

- (bool)renewable
{
    return false;
}

- (void)_serializeParametersWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.peerId forKey:TGBridgeSendStickerMessageSubscriptionPeerIdKey];
    [aCoder encodeObject:self.document forKey:TGBridgeSendStickerMessageSubscriptionDocumentKey];
    [aCoder encodeInt32:self.replyToMid forKey:TGBridgeSendStickerMessageSubscriptionReplyToMidKey];
}


- (void)_unserializeParametersWithCoder:(NSCoder *)aDecoder
{
    _peerId = [aDecoder decodeInt64ForKey:TGBridgeSendStickerMessageSubscriptionPeerIdKey];
    _document = [aDecoder decodeObjectForKey:TGBridgeSendStickerMessageSubscriptionDocumentKey];
    _replyToMid = [aDecoder decodeInt32ForKey:TGBridgeSendStickerMessageSubscriptionReplyToMidKey];
}

+ (NSString *)subscriptionName
{
    return TGBridgeSendStickerMessageSubscriptionName;
}

@end


NSString *const TGBridgeSendLocationMessageSubscriptionName = @"sendMessage.location";
NSString *const TGBridgeSendLocationMessageSubscriptionPeerIdKey = @"peerId";
NSString *const TGBridgeSendLocationMessageSubscriptionLocationKey = @"location";
NSString *const TGBridgeSendLocationMessageSubscriptionReplyToMidKey = @"replyToMid";

@implementation TGBridgeSendLocationMessageSubscription

- (instancetype)initWithPeerId:(int64_t)peerId location:(TGBridgeLocationMediaAttachment *)location replyToMid:(int32_t)replyToMid
{
    self = [super init];
    if (self != nil)
    {
        _peerId = peerId;
        _location = location;
        _replyToMid = replyToMid;
    }
    return self;
}

- (bool)renewable
{
    return false;
}

- (void)_serializeParametersWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.peerId forKey:TGBridgeSendLocationMessageSubscriptionPeerIdKey];
    [aCoder encodeObject:self.location forKey:TGBridgeSendLocationMessageSubscriptionLocationKey];
    [aCoder encodeInt32:self.replyToMid forKey:TGBridgeSendLocationMessageSubscriptionReplyToMidKey];
}

- (void)_unserializeParametersWithCoder:(NSCoder *)aDecoder
{
    _peerId = [aDecoder decodeInt64ForKey:TGBridgeSendLocationMessageSubscriptionPeerIdKey];
    _location = [aDecoder decodeObjectForKey:TGBridgeSendLocationMessageSubscriptionLocationKey];
    _replyToMid = [aDecoder decodeInt32ForKey:TGBridgeSendLocationMessageSubscriptionReplyToMidKey];
}

+ (NSString *)subscriptionName
{
    return TGBridgeSendLocationMessageSubscriptionName;
}

@end


NSString *const TGBridgeSendForwardedMessageSubscriptionName = @"sendMessage.forward";
NSString *const TGBridgeSendForwardedMessageSubscriptionPeerIdKey = @"peerId";
NSString *const TGBridgeSendForwardedMessageSubscriptionMidKey = @"mid";

@implementation TGBridgeSendForwardedMessageSubscription

- (instancetype)initWithPeerId:(int64_t)peerId messageId:(int32_t)messageId
{
    self = [super init];
    if (self != nil)
    {
        _peerId = peerId;
        _messageId = messageId;
    }
    return self;
}

- (bool)renewable
{
    return false;
}

- (void)_serializeParametersWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.peerId forKey:TGBridgeSendForwardedMessageSubscriptionPeerIdKey];
    [aCoder encodeInt32:self.messageId forKey:TGBridgeSendForwardedMessageSubscriptionMidKey];
}

- (void)_unserializeParametersWithCoder:(NSCoder *)aDecoder
{
    _peerId = [aDecoder decodeInt64ForKey:TGBridgeSendForwardedMessageSubscriptionPeerIdKey];
    _messageId = [aDecoder decodeInt32ForKey:TGBridgeSendForwardedMessageSubscriptionMidKey];
}

+ (NSString *)subscriptionName
{
    return TGBridgeSendForwardedMessageSubscriptionName;
}

@end
