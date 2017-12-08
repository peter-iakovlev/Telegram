#import "TGChannelGroupHistoryController.h"

#import "TGHeaderCollectionItem.h"
#import "TGCheckCollectionItem.h"
#import "TGCommentCollectionItem.h"

#import "TGDatabase.h"
#import "TGChannelManagementSignals.h"

@interface TGChannelGroupHistoryController ()
{
    bool _initialValue;
    bool _isHidden;
    TGConversation *_conversation;
    
    TGCollectionMenuSection *_typeSection;
    TGCheckCollectionItem *_publicItem;
    TGCheckCollectionItem *_privateItem;
    TGCommentCollectionItem *_typeHelpItem;
    
    UIBarButtonItem *_nextItem;
}
@end

@implementation TGChannelGroupHistoryController

- (instancetype)initWithConversation:(TGConversation *)conversation {
    self = [super init];
    if (self != nil) {
        self.title = TGLocalized(@"Group.Setup.HistoryTitle");
        
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)] animated:false];
        _nextItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(nextPressed)];
        [self setRightBarButtonItem:_nextItem animated:false];
        
        _conversation = conversation;
    
        TGHeaderCollectionItem *typeItem = [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Group.Setup.HistoryHeader")];
        _publicItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"Group.Setup.HistoryVisible") action:@selector(visiblePressed)];
        _privateItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"Group.Setup.HistoryHidden") action:@selector(hiddenPressed)];
        _typeHelpItem = [[TGCommentCollectionItem alloc] initWithFormattedText:@""];
        
        _typeSection =  [[TGCollectionMenuSection alloc] initWithItems:@[typeItem, _publicItem, _privateItem, _typeHelpItem]];
        UIEdgeInsets topSectionInsets = _typeSection.insets;
        topSectionInsets.top = 32.0f;
        _typeSection.insets = topSectionInsets;
        [self.menuSections addSection:_typeSection];
        
        TGCommentCollectionItem *publicCommentItem = [[TGCommentCollectionItem alloc] initWithFormattedText:_conversation.isChannelGroup ? TGLocalized(@"Group.Username.CreatePublicLinkHelp") : TGLocalized(@"Channel.Username.CreatePublicLinkHelp")];
        publicCommentItem.topInset = 1.0f;
        
        TGCommentCollectionItem *privateCommentItem = [[TGCommentCollectionItem alloc] initWithFormattedText:_conversation.isChannelGroup ? TGLocalized(@"Group.Username.CreatePrivateLinkHelp") : TGLocalized(@"Channel.Username.CreatePrivateLinkHelp")];
        privateCommentItem.topInset = 1.0f;
        
        __weak TGChannelGroupHistoryController *weakSelf = self;
        [[[TGDatabaseInstance() channelCachedData:_conversation.conversationId] take:1] startWithNext:^(TGCachedConversationData *next) {
            __strong TGChannelGroupHistoryController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                strongSelf->_initialValue = next.preHistory;
                strongSelf->_isHidden = next.preHistory;
                [strongSelf updateIsHidden];
            }
        }];
    }
    return self;
}

- (void)visiblePressed
{
    _isHidden = false;
    [self updateIsHidden];
}

- (void)hiddenPressed
{
    _isHidden = true;
    [self updateIsHidden];
}

- (void)updateIsHidden {
    if (_isHidden) {
        [_privateItem setIsChecked:true];
        [_publicItem setIsChecked:false];
        
        _typeHelpItem.text = TGLocalized(@"Group.Setup.HistoryHiddenHelp");
    } else {
        [_privateItem setIsChecked:false];
        [_publicItem setIsChecked:true];
        
        _typeHelpItem.text = TGLocalized(@"Group.Setup.HistoryVisibleHelp");
    }
}

- (void)cancelPressed {
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)nextPressed {
    if (_isHidden == _initialValue)
    {
        [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
        return;
    }
    
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [progressWindow show:true];
    
    SSignal *signal = [TGChannelManagementSignals togglePreHistoryHidden:_conversation.conversationId accessHash:_conversation.accessHash enabled:_isHidden];
    
    __weak TGChannelGroupHistoryController *weakSelf = self;
    [[[signal deliverOn:[SQueue mainQueue]] onDispose:^{
        TGDispatchOnMainThread(^{
            [progressWindow dismiss:true];
        });
    }] startWithNext:nil completed:^{
        __strong TGChannelGroupHistoryController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf.presentingViewController dismissViewControllerAnimated:true completion:nil];
        }
    }];

}

@end
