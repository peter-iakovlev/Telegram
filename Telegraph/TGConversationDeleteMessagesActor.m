#import "TGConversationDeleteMessagesActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGDatabase.h"
#import "TGTelegraph.h"

#import "TGDownloadManager.h"

#import "TGPeerIdAdapter.h"

@interface TGConversationDeleteMessagesActor () {
    int64_t _peerId;
}

@end

@implementation TGConversationDeleteMessagesActor

+ (NSString *)genericPath
{
    return @"/tg/conversation/@/deleteMessages/@";
}

- (instancetype)initWithPath:(NSString *)path {
    self = [super initWithPath:path];
    if (self != nil) {
        NSRange range = [path rangeOfString:@")/deleteMessages/"];
        _peerId = [[path substringWithRange:NSMakeRange(@"/tg/conversation/(".length, range.location - @"/tg/conversation/(".length)] longLongValue];
    }
    return self;
}

- (void)execute:(NSDictionary *)options
{
    NSArray *messageIds = [options objectForKey:@"mids"];
    
    [[TGDownloadManager instance] cancelItemsWithMessageIdsInArray:messageIds groupId:_peerId];
 
    if (TGPeerIdIsChannel(_peerId)) {
        [TGDatabaseInstance() addMessagesToChannel:_peerId messages:nil deleteMessages:messageIds unimportantGroups:nil addedHoles:nil removedHoles:nil removedUnimportantHoles:nil updatedMessageSortKeys:nil returnGroups:false keepUnreadCounters:false changedMessages:nil];
        [TGDatabaseInstance() enqueueDeleteChannelMessages:_peerId messageIds:messageIds];
    } else {
        [TGDatabaseInstance() transactionRemoveMessagesInteractive:@{@(_peerId): messageIds} keepDates:false removeMessagesInteractiveForEveryone:[options[@"forEveryone"] boolValue] updateConversationDatas:nil];
    }

    for (NSNumber *nMid in messageIds)
    {
        int32_t mid = (int32_t)[nMid intValue];
        if (mid >= TGMessageLocalMidBaseline)
        {
            [ActionStageInstance() removeAllWatchersFromPath:[[NSString alloc] initWithFormat:@"/tg/sendCommonMessage/(%lld)/(%d)", _peerId, [nMid intValue]]];
            [ActionStageInstance() removeAllWatchersFromPath:[[NSString alloc] initWithFormat:@"/tg/sendSecretMessage/(%lld)/(%d)", _peerId, [nMid intValue]]];
        }
    }
    
    [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesDeleted", _peerId] resource:[[SGraphObjectNode alloc] initWithObject:messageIds]];
    
    dispatch_async([ActionStageInstance() globalStageDispatchQueue], ^
    {
        [ActionStageInstance() requestActor:@"/tg/service/synchronizeactionqueue/(global)" options:nil watcher:TGTelegraphInstance];
    });
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

@end
