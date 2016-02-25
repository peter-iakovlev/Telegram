#import <Foundation/Foundation.h>

@class TGConversation;
@class TGUser;

@interface TGSpotlightIndexItem : NSObject <NSCopying>

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *avatarUrl;

- (instancetype)initWithConversation:(TGConversation *)conversation;
- (instancetype)initWithUser:(TGUser *)user;

@end

@interface TGSpotlightIndexData : NSObject

@property (nonatomic, strong, readonly) NSMutableSet *indexedItems;
@property (nonatomic, strong, readonly) NSMutableDictionary *indexedItemsByPeerId;

@end
