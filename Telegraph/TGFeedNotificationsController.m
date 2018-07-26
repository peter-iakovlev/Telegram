#import "TGFeedNotificationsController.h"

#import "TGDatabase.h"
#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"

#import "TGHeaderCollectionItem.h"
#import "TGSwitchCollectionItem.h"
#import "TGConversationSwitchCollectionItem.h"

#import <LegacyComponents/ASWatcher.h>

@interface TGFeedNotificationsController () <ASWatcher>
{
    TGSwitchCollectionItem *_allItem;
    
    NSMutableDictionary *_items;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGFeedNotificationsController

- (instancetype)initWithFeed:(TGFeed *)feed
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        self.title = TGLocalized(@"Feed.Notifications.Title");
        
        _allItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Feed.Notifications.MuteAll") isOn:false];
//        TGCollectionMenuSection *allSection = [[TGCollectionMenuSection alloc] initWithItems:@[_allItem]];
    
//        UIEdgeInsets topSectionInsets = allSection.insets;
//        topSectionInsets.top = 32.0f;
//        allSection.insets = topSectionInsets;
//        [self.menuSections addSection:allSection];
        
        NSArray *channels = [[TGDatabaseInstance() loadChannels:[feed.channelIds allObjects]] allValues];
        channels = [channels sortedArrayUsingComparator:^NSComparisonResult(TGConversation *obj1, TGConversation *obj2)
        {
            return [obj1.chatTitle compare:obj2.chatTitle];
        }];
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        [items addObject:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Feed.Notifications.Notifications")]];
        
        NSMutableDictionary *conversationItems = [[NSMutableDictionary alloc] init];
        for (TGConversation *channel in channels)
        {
            TGConversationSwitchCollectionItem *item = [[TGConversationSwitchCollectionItem alloc] initWithConversation:channel isOn:true];
            item.interfaceHandle = _actionHandle;
            conversationItems[@(channel.conversationId)] = item;
            [items addObject:item];
            
            [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/peerSettings/(%" PRId64 ",cachedOnly)", channel.conversationId] options:@{@"peerId": @(channel.conversationId), @"accessHash": @(channel.accessHash)} watcher:self];
        }
        _items = conversationItems;
        
        TGCollectionMenuSection *channelsSection = [[TGCollectionMenuSection alloc] initWithItems:items];
    
        UIEdgeInsets topSectionInsets = channelsSection.insets;
        topSectionInsets.top = 32.0f;
        channelsSection.insets = topSectionInsets;
        [self.menuSections addSection:channelsSection];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)actionStageActionRequested:(NSString *)action options:(id)__unused options
{
    if ([action isEqualToString:@"switchItemChanged"])
    {
        id item = options[@"item"];
        
        if (item == _allItem)
        {
            TGSwitchCollectionItem *switchItem = (TGSwitchCollectionItem *)item;
        }
        else
        {
            TGConversationSwitchCollectionItem *conversationItem = (TGConversationSwitchCollectionItem *)item;
            TGConversation *conversation = conversationItem.conversation;
            
            bool enable = conversationItem.isOn;
            int32_t muteUntil = 0;
            if (!enable)
                muteUntil = INT_MAX;
            
            static int actionId = 0;
            [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/changePeerSettings/(%" PRId64 ")/(userInfoControllerMute%d)", conversation.conversationId, actionId++] options:@{@"peerId": @(conversation.conversationId), @"accessHash": @(conversation.accessHash), @"muteUntil": @(muteUntil)} watcher:TGTelegraphInstance];
        }
    }
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path hasPrefix:@"/tg/peerSettings/"])
    {
        [self actorCompleted:ASStatusSuccess path:path result:resource];
    }
}

- (void)actorCompleted:(int)__unused status path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:@"/tg/peerSettings/"])
    {
        NSString *peerIdString = [path substringFromIndex:@"/tg/peerSettings/(".length];
        NSRange commaRange = [peerIdString rangeOfString:@","];
        peerIdString = [peerIdString substringToIndex:commaRange.location];
        
        int64_t peerId = [peerIdString longLongValue];
        NSDictionary *notificationSettings = ((SGraphObjectNode *)result).object;
        
        TGDispatchOnMainThread(^
        {
            TGConversationSwitchCollectionItem *item = _items[@(peerId)];
            bool enabled = false;
            
            int muteUntil = [notificationSettings[@"muteUntil"] intValue];
            enabled = (muteUntil <= [[TGTelegramNetworking instance] approximateRemoteTime]);
            
            item.isOn = enabled;
        });
    }
}
@end
