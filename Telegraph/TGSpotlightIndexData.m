#import "TGSpotlightIndexData.h"

#import <LegacyComponents/LegacyComponents.h>

@interface TGSpotlightIndexItem () {
    NSUInteger _hash;
}

@end

@implementation TGSpotlightIndexItem

- (instancetype)initWithConversation:(TGConversation *)conversation {
    self = [super init];
    if (self != nil) {
        _peerId = conversation.conversationId;
        _title = conversation.chatTitle;
        _avatarUrl = conversation.chatPhotoSmall;
        
        NSString *hashString = [[NSString alloc] initWithFormat:@"%lld:%@:%@", _peerId, _title, _avatarUrl];
        _hash = (NSUInteger)murMurHash32(hashString);
    }
    return self;
}

- (instancetype)initWithUser:(TGUser *)user {
    self = [super init];
    if (self != nil) {
        _peerId = user.uid;
        _title = user.displayName;
        _avatarUrl = user.photoUrlSmall;
        
        NSString *hashString = [[NSString alloc] initWithFormat:@"%lld:%@:%@", _peerId, _title, _avatarUrl];
        _hash = (NSUInteger)murMurHash32(hashString);
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)__unused zone {
    TGSpotlightIndexItem *item = [[TGSpotlightIndexItem alloc] init];
    item->_peerId = _peerId;
    item->_title = _title;
    item->_avatarUrl = _avatarUrl;
    item->_hash = _hash;
    
    return item;
}

- (bool)isEqual:(id)object {
    return [object isKindOfClass:[TGSpotlightIndexItem class]] && _peerId == ((TGSpotlightIndexItem *)object)->_peerId && TGStringCompare(_title, ((TGSpotlightIndexItem *)object)->_title) && TGStringCompare(_avatarUrl, ((TGSpotlightIndexItem *)object)->_avatarUrl);
}

- (NSUInteger)hash {
    return _hash;
}

@end

@implementation TGSpotlightIndexData

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _indexedItems = [[NSMutableSet alloc] init];
        _indexedItemsByPeerId = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@end
