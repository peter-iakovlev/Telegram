#import "TGGroupInfoShareLinkController.h"

#import "TGGroupManagementSignals.h"

#import "TGHeaderCollectionItem.h"
#import "TGGroupInfoShareLinkLinkItem.h"
#import "TGCommentCollectionItem.h"
#import "TGButtonCollectionItem.h"

#import "TGAlertView.h"
#import "TGProgressWindow.h"

#import "TGPeerIdAdapter.h"

#import "TGChannelManagementSignals.h"

#import "TGShareMenu.h"
#import "TGSendMessageSignals.h"

@interface TGGroupInfoShareLinkController ()
{
    SMetaDisposable *_disposable;
    
    int64_t _peerId;
    int64_t _accessHash;
    
    TGGroupInfoShareLinkLinkItem *_linkItem;
    TGButtonCollectionItem *_shareItem;
    UIActivityIndicatorView *_activityIndicator;
}

@end

@implementation TGGroupInfoShareLinkController

static NSString *updatedLink(NSString *link) {
    return [link stringByReplacingOccurrencesOfString:@"https://telegram.me/" withString:@"https://t.me/"];
}

- (instancetype)initWithPeerId:(int64_t)peerId accessHash:(int64_t)accessHash currentLink:(NSString *)currentLink
{
    self = [super init];
    if (self != nil)
    {
        _peerId = peerId;
        _accessHash = accessHash;
        
        self.title = TGLocalized(@"GroupInfo.InviteLink.Title");
        
        _linkItem = [[TGGroupInfoShareLinkLinkItem alloc] init];
        _linkItem.text = updatedLink(currentLink);
        TGCollectionMenuSection *linkSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.InviteLink.LinkSection")],
            _linkItem,
            [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"GroupInfo.InviteLink.Help")]
        ]];
        linkSection.insets = UIEdgeInsetsMake(32.0f, 0.0f, 0.0f, 0.0f);
        [self.menuSections addSection:linkSection];
        
        TGButtonCollectionItem *copyItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.InviteLink.CopyLink") action:@selector(copyPressed)];
        copyItem.deselectAutomatically = true;
        TGButtonCollectionItem *revokeItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.InviteLink.RevokeLink") action:@selector(revokePressed)];
        revokeItem.deselectAutomatically = true;
        _shareItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.InviteLink.ShareLink") action:@selector(sharePressed)];
        _shareItem.deselectAutomatically = true;
        
        TGCollectionMenuSection *actionSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            copyItem,
            revokeItem,
            _shareItem
        ]];
        actionSection.insets = UIEdgeInsetsMake(27.0f, 0.0f, 32.0f, 0.0f);
        [self.menuSections addSection:actionSection];
        
        if (currentLink.length == 0)
        {
            if (_disposable == nil)
                _disposable = [[SMetaDisposable alloc] init];
            __weak TGGroupInfoShareLinkController *weakSelf = self;
            
            if (TGPeerIdIsChannel(_peerId)) {
                [_disposable setDisposable:[[[TGChannelManagementSignals exportChannelInvitationLink:_peerId accessHash:_accessHash] deliverOn:[SQueue mainQueue]] startWithNext:^(NSString *link)
                {
                    __strong TGGroupInfoShareLinkController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        [strongSelf _setLink:link];
                        [strongSelf->_activityIndicator stopAnimating];
                        [strongSelf->_activityIndicator removeFromSuperview];
                        strongSelf.collectionView.alpha = 1.0f;
                    }
                }]];
            } else {
                [_disposable setDisposable:[[[TGGroupManagementSignals exportGroupInvitationLink:TGGroupIdFromPeerId(_peerId)] deliverOn:[SQueue mainQueue]] startWithNext:^(NSString *link)
                {
                    __strong TGGroupInfoShareLinkController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        [strongSelf _setLink:link];
                        [strongSelf->_activityIndicator stopAnimating];
                        [strongSelf->_activityIndicator removeFromSuperview];
                        strongSelf.collectionView.alpha = 1.0f;
                    }
                }]];
            }
        }
    }
    return self;
}

- (void)dealloc
{
    [_disposable dispose];
}

- (void)loadView
{
    [super loadView];
    
    if (_linkItem.text.length == 0)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.frame = CGRectMake(CGFloor((self.view.frame.size.width - _activityIndicator.frame.size.width) / 2.0f), CGFloor((self.view.frame.size.height - _activityIndicator.frame.size.height) / 2.0f), _activityIndicator.frame.size.width, _activityIndicator.frame.size.height);
        [_activityIndicator startAnimating];
        [self.view addSubview:_activityIndicator];
        self.collectionView.alpha = 0.0f;
    }
}

- (void)_setLink:(NSString *)link
{
    _linkItem.text = updatedLink(link);
    if (self.linkChanged != nil)
        self.linkChanged(_linkItem.text);
    
    [self.collectionLayout invalidateLayout];
    [self.collectionView layoutSubviews];
}

- (void)copyPressed
{
    [[UIPasteboard generalPasteboard] setString:_linkItem.text];
    
    [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"GroupInfo.InviteLink.CopyAlert.Success") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
}

- (void)revokePressed
{
    __weak TGGroupInfoShareLinkController *weakSelf = self;
    [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"GroupInfo.InviteLink.RevokeAlert.Text") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"GroupInfo.InviteLink.RevokeAlert.Revoke") completionBlock:^(bool okButtonPressed)
    {
        __strong TGGroupInfoShareLinkController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (okButtonPressed)
                [strongSelf _revokeLink];
        }
    }] show];
}

- (void)_revokeLink
{
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [progressWindow show:true];
    
    if (_disposable == nil)
        _disposable = [[SMetaDisposable alloc] init];
    
    if (TGPeerIdIsChannel(_peerId)) {
        __weak TGGroupInfoShareLinkController *weakSelf = self;
        [_disposable setDisposable:[[[[TGChannelManagementSignals exportChannelInvitationLink:_peerId accessHash:_accessHash] deliverOn:[SQueue mainQueue]] onDispose:^
        {
            TGDispatchOnMainThread(^
            {
                [progressWindow dismiss:true];
            });
        }] startWithNext:^(NSString *link)
        {
            __strong TGGroupInfoShareLinkController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf _setLink:link];
            
            [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"GroupInfo.InviteLink.RevokeAlert.Success") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
        }]];
    } else {
        __weak TGGroupInfoShareLinkController *weakSelf = self;
        [_disposable setDisposable:[[[[TGGroupManagementSignals exportGroupInvitationLink:TGGroupIdFromPeerId(_peerId)] deliverOn:[SQueue mainQueue]] onDispose:^
        {
            TGDispatchOnMainThread(^
            {
                [progressWindow dismiss:true];
            });
        }] startWithNext:^(NSString *link)
        {
            __strong TGGroupInfoShareLinkController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf _setLink:link];
            
            [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"GroupInfo.InviteLink.RevokeAlert.Success") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
        }]];
    }
}

- (void)sharePressed
{
    NSString *linkString = _linkItem.text;
    NSString *shareString = linkString;
    
    __weak TGGroupInfoShareLinkController *weakSelf = self;
    CGRect (^sourceRect)(void) = ^CGRect
    {
        __strong TGGroupInfoShareLinkController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return CGRectZero;
        
        return [strongSelf->_shareItem.view convertRect:strongSelf->_shareItem.view.bounds toView:strongSelf.view];
    };
    
    [TGShareMenu presentInParentController:self menuController:nil buttonTitle:TGLocalized(@"ShareMenu.CopyShareLink") buttonAction:^
    {
        [[UIPasteboard generalPasteboard] setString:linkString];
    } shareAction:^(NSArray *peerIds, NSString *caption)
    {
        [[TGShareSignals shareText:shareString toPeerIds:peerIds caption:caption] startWithNext:nil];
    } externalShareItemSignal:[SSignal single:[NSURL URLWithString:shareString]] sourceView:self.view sourceRect:sourceRect barButtonItem:nil];
}

@end
