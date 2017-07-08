#import "TGChannelModeratorController.h"

#import "TGCheckCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGHeaderCollectionItem.h"
#import "TGDatabase.h"
#import "TGChannelManagementSignals.h"
#import "TGButtonCollectionItem.h"

#import "TGChannelModeratorCollectionItem.h"

#import "TGSwitchCollectionItem.h"

#import "TGTelegraph.h"

@interface TGChannelModeratorController () {
    TGConversation *_conversation;
    TGUser *_user;
    TGCachedConversationMember *_originalMember;
    
    TGSwitchCollectionItem *_canChangeInfo;
    TGSwitchCollectionItem *_canPostMessages;
    TGSwitchCollectionItem *_canEditMessages;
    TGSwitchCollectionItem *_canDeleteMessages;
    TGSwitchCollectionItem *_canBanUsers;
    TGSwitchCollectionItem *_canInviteUsers;
    TGSwitchCollectionItem *_canPinMessages;
    TGSwitchCollectionItem *_canAddAdmins;
    
    TGCommentCollectionItem *_rightsInfoItem;
    
    id<SDisposable> _disposable;
    UIActivityIndicatorView *_activityIndicator;
    bool _receivedMember;
    
    bool _isPreview;
}

@end

@implementation TGChannelModeratorController

- (instancetype)initWithConversation:(TGConversation *)conversation user:(TGUser *)user currentSignal:(SSignal *)currentSignal {
    self = [super init];
    if (self != nil) {
        _conversation = conversation;
        _user = user;
        
        self.title = TGLocalized(@"Channel.Moderator.Title");
        
        __weak TGChannelModeratorController *weakSelf = self;
        _disposable = [[currentSignal deliverOn:[SQueue mainQueue]] startWithNext:^(TGCachedConversationMember *current) {
            __strong TGChannelModeratorController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf resetSections:current];
            }
        }];
    }
    return self;
}

- (void)resetSections:(TGCachedConversationMember *)current {
    _receivedMember = true;
    
    _originalMember = current;
    
    TGCachedConversationMember *sourceMember = [[TGCachedConversationMember alloc] initWithUid:TGTelegraphInstance.clientUserId isCreator:_conversation.channelRole == TGChannelRoleCreator adminRights:_conversation.channelAdminRights bannedRights:nil timestamp:0 inviterId:0 adminInviterId:0 kickedById:0 adminCanManage:false];
    
    TGConversation *conversation = _conversation;
    
    TGChannelAdminRights *adminRights = [[TGChannelAdminRights alloc] initWithCanChangeInfo:sourceMember.isCreator || sourceMember.adminRights.canChangeInfo canPostMessages:!conversation.isChannelGroup && (sourceMember.isCreator || sourceMember.adminRights.canPostMessages) canEditMessages:!conversation.isChannelGroup && (sourceMember.isCreator || sourceMember.adminRights.canEditMessages) canDeleteMessages:sourceMember.isCreator || sourceMember.adminRights.canDeleteMessages canBanUsers:conversation.isChannelGroup && (sourceMember.isCreator || sourceMember.adminRights.canBanUsers) canInviteUsers:conversation.isChannelGroup && (sourceMember.isCreator || sourceMember.adminRights.canInviteUsers) canChangeInviteLink:conversation.isChannelGroup && (sourceMember.isCreator || sourceMember.adminRights.canChangeInviteLink) canPinMessages:conversation.isChannelGroup && (sourceMember.isCreator || sourceMember.adminRights.canPinMessages) canAddAdmins:false];
    if (current.adminRights != nil) {
        adminRights = current.adminRights;
    }
    TGCachedConversationMember *_member = [[TGCachedConversationMember alloc] initWithUid:_user.uid isCreator:false adminRights:adminRights bannedRights:nil timestamp:0 inviterId:0 adminInviterId:0 kickedById:0 adminCanManage:false];
    
    bool isPreview = _originalMember != nil && !sourceMember.isCreator && (current.adminRights != nil && current.adminInviterId != sourceMember.uid);
    _isPreview = isPreview;
    
    if (isPreview) {
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(cancelPressed)]];
    } else {
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
    }
    
    TGChannelModeratorCollectionItem *userItem = [[TGChannelModeratorCollectionItem alloc] init];
    userItem.user = _user;
    TGCollectionMenuSection *userSection = [[TGCollectionMenuSection alloc] initWithItems:@[userItem]];
    UIEdgeInsets insets = userSection.insets;
    insets.top = 35.0f;
    userSection.insets = insets;
    [self.menuSections addSection:userSection];
    
    __weak TGChannelModeratorController *weakSelf = self;
    
    TGHeaderCollectionItem *accessLevelHeader = [[TGHeaderCollectionItem alloc] initWithTitle:[TGLocalized(@"Channel.EditAdmin.PermissionsHeader") uppercaseString]];
    
    _canChangeInfo = [[TGSwitchCollectionItem alloc] initWithTitle:_conversation.isChannelGroup ? TGLocalized(@"Group.EditAdmin.PermissionChangeInfo") : TGLocalized(@"Channel.EditAdmin.PermissionChangeInfo") isOn:_member.adminRights.canChangeInfo];
    _canChangeInfo.isPermission = true;
    
    _canEditMessages = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.EditAdmin.PermissionEditMessages") isOn:_member.adminRights.canEditMessages];
    _canEditMessages.isPermission = true;
    
    _canPostMessages = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.EditAdmin.PermissionPostMessages") isOn:_member.adminRights.canPostMessages];
    _canPostMessages.isPermission = true;
    
    _canDeleteMessages = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.EditAdmin.PermissionDeleteMessages") isOn:_member.adminRights.canDeleteMessages];
    _canDeleteMessages.isPermission = true;
    
    _canBanUsers = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.EditAdmin.PermissionBanUsers") isOn:_member.adminRights.canBanUsers];
    _canBanUsers.isPermission = true;
    
    _canInviteUsers = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.EditAdmin.PermissionInviteUsers") isOn:_member.adminRights.canInviteUsers];
    _canInviteUsers.isPermission = true;
    _canInviteUsers.toggled = ^(__unused bool value, __unused TGSwitchCollectionItem *item) {
        __strong TGChannelModeratorController *strongSelf = weakSelf;
        if (strongSelf && !value) {
            //[strongSelf->_canChangeInviteLink setIsOn:false animated:true];
        }
    };
    
    _canPinMessages = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.EditAdmin.PermissionPinMessages") isOn:_member.adminRights.canPinMessages];
    _canPinMessages.isPermission = true;
    
    _canAddAdmins = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.EditAdmin.PermissionAddAdmins") isOn:_member.adminRights.canAddAdmins];
    _canAddAdmins.toggled = ^(__unused bool value, __unused TGSwitchCollectionItem *item) {
        __strong TGChannelModeratorController *strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf updateAccessLevelHelp];
        }
    };
    _canAddAdmins.isPermission = true;
    
    _rightsInfoItem = [[TGCommentCollectionItem alloc] initWithText:@""];
    
    NSMutableArray *rightsItems = [[NSMutableArray alloc] init];
    [rightsItems addObject:accessLevelHeader];
    
    if (sourceMember.isCreator || sourceMember.adminRights.canChangeInfo) {
        [rightsItems addObject:_canChangeInfo];
    }
    
    if (!conversation.isChannelGroup && (isPreview || sourceMember.isCreator || sourceMember.adminRights.canPostMessages)) {
        [rightsItems addObject:_canPostMessages];
    }
    
    if (!conversation.isChannelGroup && (isPreview || sourceMember.isCreator || sourceMember.adminRights.canEditMessages)) {
        [rightsItems addObject:_canEditMessages];
    }
    
    if (isPreview || sourceMember.isCreator || sourceMember.adminRights.canDeleteMessages) {
        [rightsItems addObject:_canDeleteMessages];
    }
    
    if (isPreview || sourceMember.isCreator || sourceMember.adminRights.canBanUsers) {
        [rightsItems addObject:_canBanUsers];
    }
    
    if (!conversation.everybodyCanAddMembers) {
        if ((isPreview || sourceMember.isCreator || sourceMember.adminRights.canInviteUsers)) {
            [rightsItems addObject:_canInviteUsers];
        }
    }
    
    if (conversation.isChannelGroup && (isPreview || sourceMember.isCreator || sourceMember.adminRights.canChangeInviteLink)) {
        //[rightsItems addObject:_canChangeInviteLink];
    }
    
    if (conversation.isChannelGroup && (isPreview || sourceMember.isCreator || sourceMember.adminRights.canPinMessages)) {
        [rightsItems addObject:_canPinMessages];
    }
    
    if (isPreview || sourceMember.isCreator || sourceMember.adminRights.canAddAdmins) {
        [rightsItems addObject:_canAddAdmins];
        [rightsItems addObject:_rightsInfoItem];
    }
    
    if (isPreview) {
        for (id item in rightsItems) {
            if ([item isKindOfClass:[TGSwitchCollectionItem class]]) {
                ((TGSwitchCollectionItem *)item).isEnabled = false;
            }
        }
    } else {
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)]];
    }
    
    TGCollectionMenuSection *rightsSection = [[TGCollectionMenuSection alloc] initWithItems:rightsItems];
    [self.menuSections addSection:rightsSection];
    
    if (_originalMember != nil && (sourceMember.isCreator || _originalMember.adminCanManage)) {
        TGButtonCollectionItem *dismissItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Moderator.AccessLevelRevoke") action:@selector(dismissPressed)];
        dismissItem.titleColor = TGDestructiveAccentColor();
        TGCollectionMenuSection *dismissModeratorSection = [[TGCollectionMenuSection alloc] initWithItems:@[dismissItem]];
        [self.menuSections addSection:dismissModeratorSection];
    }
    
    [self updateAccessLevelHelp];
    
    if (self.isViewLoaded) {
        [_activityIndicator removeFromSuperview];
        self.collectionView.alpha = 1.0f;
        [self.collectionView reloadData];
    }
}

- (void)updateAccessLevelHelp {
    if (_user.uid == TGTelegraphInstance.clientUserId) {
        [_rightsInfoItem setFormattedText:@""];
    } else if (_isPreview) {
        [_rightsInfoItem setFormattedText:TGLocalized(@"Channel.EditAdmin.CannotEdit")];
    } else if (_canAddAdmins.isOn) {
        [_rightsInfoItem setFormattedText:TGLocalized(@"Channel.EditAdmin.PermissinAddAdminOn")];
    } else {
        [_rightsInfoItem setFormattedText:TGLocalized(@"Channel.EditAdmin.PermissinAddAdminOff")];
    }
    
    [self.collectionLayout invalidateLayout];
    [self.collectionView layoutSubviews];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_receivedMember) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.frame = CGRectMake(CGFloor((self.view.frame.size.width - _activityIndicator.frame.size.width) / 2.0f), CGFloor((self.view.frame.size.height - _activityIndicator.frame.size.height) / 2.0f), _activityIndicator.frame.size.width, _activityIndicator.frame.size.height);
        _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [_activityIndicator startAnimating];
        [self.view addSubview:_activityIndicator];
        
        self.collectionView.alpha = 0.0f;
    }
}

- (void)cancelPressed {
    if (_done) {
        _done(nil);
    }
}

- (void)donePressed {
    if (_done) {
        TGChannelAdminRights *rights = [[TGChannelAdminRights alloc] initWithCanChangeInfo:_canChangeInfo.isOn canPostMessages:_canPostMessages.isOn canEditMessages:_canEditMessages.isOn canDeleteMessages:_canDeleteMessages.isOn canBanUsers:_canBanUsers.isOn canInviteUsers:_canInviteUsers.isOn canChangeInviteLink:_canInviteUsers.isOn canPinMessages:_canPinMessages.isOn canAddAdmins:_canAddAdmins.isOn];
        if (_originalMember != nil) {
            if ([[_originalMember adminRights] isEqual:rights]) {
                _done(nil);
                return;
            }
        }
        _done(rights);
    }
}

- (void)dismissPressed {
    if (_revoke) {
        _revoke();
    }
}

@end
