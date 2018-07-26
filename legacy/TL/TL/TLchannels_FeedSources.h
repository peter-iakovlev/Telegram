#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@interface TLchannels_FeedSources : NSObject <TLObject>

@end

@interface TLchannels_FeedSources$channels_feedSourcesNotModified : TLchannels_FeedSources

@end

@interface TLchannels_FeedSources$channels_feedSourcesMeta : TLchannels_FeedSources

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t newly_joined_feed;
@property (nonatomic, strong) NSArray *feeds;
@property (nonatomic, strong) NSArray *chats;
@property (nonatomic, strong) NSArray *users;

@end
