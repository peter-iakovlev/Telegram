#import "TGChannelList.h"

#import "TGConversation.h"

#import "TGChannelStateSignals.h"
#import "TGUpdateStateRequestBuilder.h"

#import "ActionStage.h"

@interface TGChannelList () {
    NSMutableArray *_channels;
    
    NSMutableDictionary *_channelStateDisposables;
    
    NSMutableArray *_uncommitedPeerIds;
}

@end

@implementation TGChannelList

- (instancetype)initWithChannels:(NSArray *)channels {
    self = [super init];
    if (self != nil) {
        _channelStateDisposables = [[NSMutableDictionary alloc] init];
        _uncommitedPeerIds = [[NSMutableArray alloc] init];
        
        _channels = [[NSMutableArray alloc] initWithArray:channels];
        [_channels sortUsingComparator:^NSComparisonResult(TGConversation *lhs, TGConversation *rhs) {
            int result = TGConversationSortKeyCompare(lhs.variantSortKey, rhs.variantSortKey);
            if (result > 0) {
                return NSOrderedAscending;
            } else if (result < 0) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }];
    }
    return self;
}

- (void)dealloc {
    for (id<SDisposable> disposable in _channelStateDisposables.allValues) {
        [disposable dispose];
    }
}

- (NSArray *)channels {
    return [[NSArray alloc] initWithArray:_channels];
}

- (bool)updateChannel:(TGConversation *)conversation {
    for (NSUInteger i = 0; i < _channels.count; i++) {
        TGConversation *currentChannel = _channels[i];
        if (currentChannel.conversationId == conversation.conversationId) {
            [_channels removeObjectAtIndex:i];
            break;
        }
    }
    
    bool inserted = false;
    for (NSUInteger i = 0; i < _channels.count; i++) {
        TGConversation *currentChannel = _channels[i];
        if (TGConversationSortKeyCompare(conversation.variantSortKey, currentChannel.variantSortKey) > 0) {
            [_channels insertObject:conversation atIndex:i];
            inserted = true;
            break;
        }
    }
    
    if (!inserted) {
        [_channels addObject:conversation];
    }
    
    if (![_uncommitedPeerIds containsObject:@(conversation.conversationId)]) {
        [_uncommitedPeerIds addObject:@(conversation.conversationId)];
    }
    
    return true;
}

- (void)commitUpdatedChannels {
    NSMutableArray *channels = [[NSMutableArray alloc] init];
    for (NSNumber *nPeerId in _uncommitedPeerIds) {
        for (TGConversation *conversation in _channels) {
            if (conversation.conversationId == [nPeerId longLongValue]) {
                [channels addObject:conversation];
                break;
            }
        }
    }
    
    [_uncommitedPeerIds removeAllObjects];

    if (channels.count != 0) {
        [ActionStageInstance() dispatchResource:@"/tg/conversations" resource:[[SGraphObjectNode alloc] initWithObject:channels]];
    }
}

@end
