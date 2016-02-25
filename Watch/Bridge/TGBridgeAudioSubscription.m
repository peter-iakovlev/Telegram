#import "TGBridgeAudioSubscription.h"

NSString *const TGBridgeAudioSubscriptionName = @"media.audio";
NSString *const TGBridgeAudioSubscriptionAttachmentKey = @"attachment";
NSString *const TGBridgeAudioSubscriptionConversationIdKey = @"conversationId";
NSString *const TGBridgeAudioSubscriptionMessageIdKey = @"messageId";

@implementation TGBridgeAudioSubscription

- (instancetype)initWithAttachment:(TGBridgeMediaAttachment *)attachment conversationId:(int64_t)conversationId messageId:(int32_t)messageId
{
    self = [super init];
    if (self != nil)
    {
        _attachment = attachment;
        _conversationId = conversationId;
        _messageId = messageId;
    }
    return self;
}

- (void)_serializeParametersWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.attachment forKey:TGBridgeAudioSubscriptionAttachmentKey];
    [aCoder encodeInt64:self.conversationId forKey:TGBridgeAudioSubscriptionConversationIdKey];
    [aCoder encodeInt32:self.messageId forKey:TGBridgeAudioSubscriptionMessageIdKey];
}

- (void)_unserializeParametersWithCoder:(NSCoder *)aDecoder
{
    _attachment = [aDecoder decodeObjectForKey:TGBridgeAudioSubscriptionAttachmentKey];
    _conversationId = [aDecoder decodeInt64ForKey:TGBridgeAudioSubscriptionConversationIdKey];
    _messageId = [aDecoder decodeInt32ForKey:TGBridgeAudioSubscriptionMessageIdKey];
}

+ (NSString *)subscriptionName
{
    return TGBridgeAudioSubscriptionName;
}

@end


NSString *const TGBridgeAudioSentSubscriptionName = @"media.audioSent";
NSString *const TGBridgeAudioSentSubscriptionConversationIdKey = @"conversationId";

@implementation TGBridgeAudioSentSubscription

- (instancetype)initWithConversationId:(int64_t)conversationId
{
    self = [super init];
    if (self != nil)
    {
        _conversationId = conversationId;
    }
    return self;
}

- (void)_serializeParametersWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.conversationId forKey:TGBridgeAudioSentSubscriptionConversationIdKey];
}

- (void)_unserializeParametersWithCoder:(NSCoder *)aDecoder
{
    _conversationId = [aDecoder decodeInt64ForKey:TGBridgeAudioSentSubscriptionConversationIdKey];
}

+ (NSString *)subscriptionName
{
    return TGBridgeAudioSentSubscriptionName;
}

@end
