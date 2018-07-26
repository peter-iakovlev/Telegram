#import "TGFeed.h"
#import "TGFeedPosition.h"
#import <LegacyComponents/TGMessage.h>
#import <LegacyComponents/TGConversation.h>
#import <LegacyComponents/TGPeerIdAdapter.h>

@implementation TGFeed

@dynamic pinnedToTop;
@dynamic maxReadDate;

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    self = [super init];
    if (self != nil)
    {
        _fid = [coder decodeInt32ForCKey:"i"];
        _channelIds = [NSSet setWithArray:[self decodeInt64Array:coder key:@"chis"]];
        _cachedChannelsHash = [coder decodeInt32ForCKey:"ch"];
        _addsJoinedChannels = [coder decodeInt32ForCKey:"a"];
        
        _messageDate = [coder decodeInt32ForCKey:"d"];
        _pinnedDate = [coder decodeInt32ForCKey:"pd"];
        
        _text = [coder decodeStringForCKey:"t"];
        _media = [TGMessage parseMediaAttachments:[coder decodeDataCorCKey:"m"]];
        
        _chatIds = [self decodeInt64Array:coder key:@"cis"];
        _chatTitles = [self decodeStringArray:coder key:@"cts"];
        _chatPhotosSmall = [self decodeStringArray:coder key:@"cps"];
        
        _unreadCount = [coder decodeInt32ForCKey:"uc"];
        _maxReadPosition = (TGFeedPosition *)[coder decodeObjectForCKey:"mrp"];
        _serviceUnreadCount = -1;
    }
    return self;
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeInt32:_fid forCKey:"i"];
    [self encodeInt64Array:[_channelIds allObjects] coder:coder key:@"chis"];
    [coder encodeInt32:_cachedChannelsHash forCKey:"ch"];
    [coder encodeInt32:_addsJoinedChannels forCKey:"a"];
    
    [coder encodeInt32:_messageDate forCKey:"d"];
    [coder encodeInt32:_pinnedDate forCKey:"pd"];
    
    [coder encodeString:_text forCKey:"t"];
    [coder encodeData:[TGMessage serializeMediaAttachments:true attachments:_media] forCKey:"m"];
    
    [self encodeInt64Array:_chatIds coder:coder key:@"cis"];
    [self encodeStringArray:_chatTitles coder:coder forKey:@"cts"];
    [self encodeStringArray:_chatPhotosSmall coder:coder forKey:@"cps"];
    
    [coder encodeInt32:_unreadCount forCKey:"uc"];
    [coder encodeObject:_maxReadPosition forCKey:"mrp"];
}

- (id)copyWithZone:(NSZone *)__unused zone
{
    TGFeed *feed = [[TGFeed alloc] init];
    feed->_fid = _fid;
    feed->_channelIds = _channelIds;
    feed->_cachedChannelsHash = _cachedChannelsHash;
    feed->_addsJoinedChannels = _addsJoinedChannels;
    
    feed->_messageDate = _messageDate;
    feed->_pinnedDate = _pinnedDate;
    feed->_text = _text;
    feed->_media = _media;
    feed->_maxKnownMessageId = _maxKnownMessageId;
    
    feed->_isDeleted = _isDeleted;
    
    feed->_chatIds = _chatIds;
    feed->_chatTitles = _chatTitles;
    feed->_chatPhotosSmall = _chatPhotosSmall;
    
    feed->_unreadCount = _unreadCount;
    feed->_serviceUnreadCount = _serviceUnreadCount;
    feed->_maxReadPosition = _maxReadPosition;
    
    return feed;
}

- (int32_t)maxReadDate {
    return _maxReadPosition.date;
}

- (void)setMaxReadDate:(int32_t)__unused maxReadDate {
}

- (int32_t)calculatedChannelsHash
{
    uint32_t acc = 0;
    
    NSArray *channelIds = [[self.channelIds allObjects] sortedArrayUsingSelector:@selector(compare:)];
    for (NSNumber *peerId in channelIds) {
        uint32_t channelId = TGChannelIdFromPeerId(peerId.int64Value);
        acc = (acc * 20261) + channelId;
    }
    return acc % 0x7FFFFFFF;
}

- (bool)isEncrypted
{
    return false;
}

- (bool)isChat
{
    return false;
}

- (bool)pinnedToTop
{
    return _pinnedDate >= TGConversationPinnedDateBase;
}

- (int32_t)date
{
    return MAX(_pinnedDate, MAX(_minMessageDate, _messageDate));
}

- (bool)isBroadcast
{
    return false;
}

- (void)encodeInt64Array:(NSArray *)array coder:(PSKeyValueCoder *)coder key:(NSString *)key
{
    [coder encodeInt32:(int32_t)array.count forKey:[NSString stringWithFormat:@"%@_l", key]];
    NSInteger i = 0;
    for (NSNumber *number in array)
    {
        [coder encodeInt64:number.int64Value forKey:[NSString stringWithFormat:@"%@_%d", key, (int32_t)i]];
        i++;
    }
}

- (NSArray *)decodeInt64Array:(PSKeyValueCoder *)coder key:(NSString *)key
{
    int32_t count = [coder decodeInt32ForKey:[NSString stringWithFormat:@"%@_l", key]];
    if (count == 0)
        return [NSArray array];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < count; i++)
    {
        int64_t value = [coder decodeInt64ForKey:[NSString stringWithFormat:@"%@_%d", key, (int32_t)i]];
        [array addObject:@(value)];
    }
    
    return array;
}

- (void)encodeStringArray:(NSArray *)array coder:(PSKeyValueCoder *)coder forKey:(NSString *)key
{
    [coder encodeInt32:(int32_t)array.count forKey:[NSString stringWithFormat:@"%@_l", key]];
    NSInteger i = 0;
    for (NSString *string in array)
    {
        [coder encodeString:string forKey:[NSString stringWithFormat:@"%@_%d", key, (int32_t)i]];
        i++;
    }
}

- (NSArray *)decodeStringArray:(PSKeyValueCoder *)coder key:(NSString *)key
{
    int32_t count = [coder decodeInt32ForKey:[NSString stringWithFormat:@"%@_l", key]];
    if (count == 0)
        return [NSArray array];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < count; i++)
    {
        NSString *value = [coder decodeStringForKey:[NSString stringWithFormat:@"%@_%d", key, (int32_t)i]];
        [array addObject:value];
    }
    
    return array;
}

- (bool)isAd {
    return false;
}

@end
