#import "TGFeedGroupingController.h"

#import "TGDatabase.h"
#import "TGChannelManagementSignals.h"
#import "TGFeedManagementSignals.h"

#import "TGHeaderCollectionItem.h"
#import "TGSwitchCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGButtonCollectionItem.h"
#import "TGConversationSwitchCollectionItem.h"

#import <LegacyComponents/ASWatcher.h>

#import "TGPresentation.h"

@interface TGFeedGroupingController () <ASWatcher>
{
    TGFeed *_feed;
    
    UIBarButtonItem *_doneItem;
    NSMutableArray *_switchItems;
    TGSwitchCollectionItem *_groupNew;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGFeedGroupingController

- (instancetype)initWithFeed:(TGFeed *)feed
{
    self = [super init];
    if (self != nil)
    {
        _feed = feed;
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        self.title = TGLocalized(@"Feed.Grouping.Title");
        
        TGCollectionMenuSection *newSection = [[TGCollectionMenuSection alloc] initWithItems:@
        [
         _groupNew = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Feed.Grouping.GroupNew") isOn:_feed.addsJoinedChannels],
         [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"Feed.Grouping.GroupNewHelp")]
        ]];
        
        UIEdgeInsets topSectionInsets = newSection.insets;
        topSectionInsets.top = 32.0f;
        newSection.insets = topSectionInsets;
        [self.menuSections addSection:newSection];
        
        __weak TGFeedGroupingController *weakSelf = self;
        [[TGDatabaseInstance() channelList] startWithNext:^(id next) {
            __strong TGFeedGroupingController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf setChannels:next];
        }];
        
        _doneItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)];
        [self setRightBarButtonItem:_doneItem];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)update
{
    NSMutableSet *channelIds = [[NSMutableSet alloc] init];
    for (TGConversationSwitchCollectionItem *item in _switchItems)
    {
        if (item.isOn)
            [channelIds addObject:@(item.conversation.conversationId)];
    }
    
    if (![_feed.channelIds isEqual:channelIds] || _feed.addsJoinedChannels != _groupNew.isOn)
    {
        [[TGFeedManagementSignals updateFeedChannels:_feed.fid peerIds:channelIds alsoNewlyJoined:_groupNew.isOn] startWithNext:nil completed:^
        {
            
        }];
    }
}

- (void)donePressed
{
    [self update];
    
    [self.navigationController popViewControllerAnimated:true];
}

- (void)setChannels:(NSArray *)channels
{
    NSMutableArray *feedChannels = [[NSMutableArray alloc] init];
    NSMutableArray *otherChannels = [[NSMutableArray alloc] init];
    for (TGConversation *channel in channels)
    {
        if (channel.kind == TGConversationKindPersistentChannel && !channel.isChannelGroup && !channel.restrictionReason)
        {
            if ([_feed.channelIds containsObject:@(channel.conversationId)])
                [feedChannels addObject:channel];
            else
                [otherChannels addObject:channel];
        }
    }

    [feedChannels sortUsingComparator:^NSComparisonResult(TGConversation *obj1, TGConversation *obj2)
    {
        return [obj1.chatTitle compare:obj2.chatTitle];
    }];
    
    [otherChannels sortUsingComparator:^NSComparisonResult(TGConversation *obj1, TGConversation *obj2)
    {
        return [obj1.chatTitle compare:obj2.chatTitle];
    }];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Feed.Grouping.GroupChannels")]];
    
    NSMutableArray *switchItems = [[NSMutableArray alloc] init];
    void (^addItem)(TGConversation *, bool) = ^(TGConversation *channel, bool grouped)
    {
        TGConversationSwitchCollectionItem *item = [[TGConversationSwitchCollectionItem alloc] initWithConversation:channel isOn:grouped];
        item.interfaceHandle = _actionHandle;
        [items addObject:item];
        [switchItems addObject:item];
    };
    for (TGConversation *channel in feedChannels)
    {
        addItem(channel, true);
    }
    for (TGConversation *channel in otherChannels)
    {
        addItem(channel, false);
    }
    _switchItems = switchItems;
    
    TGCollectionMenuSection *channelsSection = [[TGCollectionMenuSection alloc] initWithItems:items];
    [self.menuSections addSection:channelsSection];
    
    TGButtonCollectionItem *ungroupAll = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Feed.Grouping.UngroupAllChannels") action:@selector(ungroupAllPressed)];
    ungroupAll.titleColor = self.presentation.pallete.collectionMenuDestructiveColor;
    
    TGCollectionMenuSection *ungroupSection = [[TGCollectionMenuSection alloc] initWithItems:@
    [
     ungroupAll
    ]];
    [self.menuSections addSection:ungroupSection];
}

- (void)actionStageActionRequested:(NSString *)action options:(id)__unused options
{
    if ([action isEqualToString:@"switchItemChanged"])
    {
        NSInteger checkedCount = 0;
        for (TGConversationSwitchCollectionItem *item in _switchItems)
        {
            if (item.isOn)
                checkedCount++;
        }
        
        _doneItem.enabled = checkedCount >= 4;
    }
}

- (void)ungroupAllPressed
{
    [[TGFeedManagementSignals updateFeedChannels:_feed.fid peerIds:[NSSet set] alsoNewlyJoined:false] startWithNext:nil];
    
    [self.navigationController popToRootViewControllerAnimated:true];
}
         
@end
