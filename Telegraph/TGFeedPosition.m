#import "TGFeedPosition.h"

#import <LegacyComponents/TGPeerIdAdapter.h>

#import "TLFeedPosition.h"
#import "TLPeer.h"

@implementation TGFeedPosition

- (instancetype)initWithDate:(int32_t)date mid:(int32_t)mid peerId:(int64_t)peerId
{
    self = [super init];
    if (self != nil)
    {
        _date = date;
        _mid = mid;
        _peerId = peerId;
    }
    return self;
}

- (instancetype)initWithTelegraphDesc:(TLFeedPosition *)desc
{
    if ([desc isKindOfClass:[TLFeedPosition$feedPosition class]]) {
        TLFeedPosition$feedPosition *feedPosition = (TLFeedPosition$feedPosition *)desc;
        
        int64_t peerId = 0;
        if ([feedPosition.peer isKindOfClass:[TLPeer$peerChat class]]) {
            peerId = TGPeerIdFromGroupId(((TLPeer$peerChat *)feedPosition.peer).chat_id);
        } else if ([feedPosition.peer isKindOfClass:[TLPeer$peerUser class]]) {
            peerId = ((TLPeer$peerUser *)feedPosition.peer).user_id;
        } else if ([feedPosition.peer isKindOfClass:[TLPeer$peerChannel class]]) {
            peerId = TGPeerIdFromChannelId(((TLPeer$peerChannel *)feedPosition.peer).channel_id);
        }
        
        return [self initWithDate:feedPosition.date mid:feedPosition.n_id peerId:peerId];
    } else {
        return nil;
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithDate:[aDecoder decodeInt32ForKey:@"d"] mid:[aDecoder decodeInt32ForKey:@"m"] peerId:[aDecoder decodeInt64ForKey:@"p"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt32:_date forKey:@"d"];
    [aCoder encodeInt32:_mid forKey:@"m"];
    [aCoder encodeInt64:_peerId forKey:@"p"];
}


- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    self = [super init];
    if (self != nil)
    {
        _date = [coder decodeInt32ForCKey:"d"];
        _mid = [coder decodeInt32ForCKey:"m"];
        _peerId = [coder decodeInt64ForCKey:"p"];
    }
    return self;
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeInt32:_date forCKey:"d"];
    [coder encodeInt32:_mid forCKey:"m"];
    [coder encodeInt64:_peerId forCKey:"p"];
}
@end
