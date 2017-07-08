#import "TGChannelBanController.h"

#import "TGCheckCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGHeaderCollectionItem.h"
#import "TGDatabase.h"
#import "TGChannelManagementSignals.h"
#import "TGButtonCollectionItem.h"
#import "TGVariantCollectionItem.h"

#import "TGChannelModeratorCollectionItem.h"

#import "TGSwitchCollectionItem.h"

#import "TGChannelBannedRights.h"

#import "TGStringUtils.h"
#import "TGActionSheet.h"

#import "TGTelegramNetworking.h"

#import "TGPickerSheet.h"
#import "TGAppDelegate.h"

static NSArray *timeoutValues() {
    NSArray *values = @[@(1 * 60 * 60 * 24),
                        @(1 * 60 * 60 * 24 * 7),
                        @(INT32_MAX)];
    return values;
}

static NSString *stringForBanTimeout(int32_t value) {
    if (value == INT32_MAX || value == 0) {
        return TGLocalized(@"MessageTimer.Forever");
    } else {
        return [TGStringUtils stringForMessageTimerSeconds:value];
    }
}

@interface TGChannelBanController () {
    UIActivityIndicatorView *_activityIndicator;
    bool _receivedMember;
    TGCachedConversationMember *_member;
    
    TGConversation *_conversation;
    TGUser *_user;
    TGCachedConversationMember *_originalMember;
    
    TGSwitchCollectionItem *_canReadMessages;
    TGSwitchCollectionItem *_canSendMessages;
    TGSwitchCollectionItem *_canSendMedia;
    TGSwitchCollectionItem *_canSendStickers;
    TGSwitchCollectionItem *_canEmbedLinks;
    
    TGVariantCollectionItem *_blockTimeout;
    int32_t _banTimeout;
    
    TGButtonCollectionItem *_unbanItem;
    
    id<SDisposable> _memberDisposable;
    
    TGPickerSheet *_pickerSheet;
    
    bool _isPreview;
}

@end

@implementation TGChannelBanController

- (instancetype)initWithConversation:(TGConversation *)conversation user:(TGUser *)user current:(TGCachedConversationMember *)current member:(SSignal *)member {
    self = [super init];
    if (self != nil) {
        _conversation = conversation;
        _user = user;
        _originalMember = current;
        
        _member = [[TGCachedConversationMember alloc] initWithUid:user.uid isCreator:false adminRights:nil bannedRights:[[TGChannelBannedRights alloc] initWithBanReadMessages:true banSendMessages:true banSendMedia:true banSendStickers:true banSendGifs:true banSendGames:true banSendInline:true banEmbedLinks:true timeout:INT32_MAX] timestamp:0 inviterId:0 adminInviterId:0 kickedById:0 adminCanManage:false];
        
        self.title = TGLocalized(@"Channel.BanUser.Title");
        
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
        
        __weak TGChannelBanController *weakSelf = self;
        _memberDisposable = [[member deliverOn:[SQueue mainQueue]] startWithNext:^(TGCachedConversationMember *next) {
            __strong TGChannelBanController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (next != nil) {
                    if (current == nil) {
                        if (next.bannedRights == nil) {
                            next = [next withUpdatedBannedRights:[[TGChannelBannedRights alloc] initWithBanReadMessages:true banSendMessages:true banSendMedia:true banSendStickers:true banSendGifs:true banSendGames:true banSendInline:true banEmbedLinks:true timeout:INT32_MAX]];
                        }
                    }
                    strongSelf->_member = next;
                }
                strongSelf->_receivedMember = true;
                [strongSelf resetSections];
            }
        }];
    }
    return self;
}

- (void)dealloc {
    [_memberDisposable dispose];
}

- (void)resetSections {
    while (self.menuSections.sections.count != 0) {
        [self.menuSections deleteSection:0];
    }
    
    _isPreview = (_conversation.channelRole != TGChannelRoleCreator) && !_conversation.channelAdminRights.canBanUsers;
    
    if (!_isPreview) {
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)]];
    }
    
    TGChannelModeratorCollectionItem *userItem = [[TGChannelModeratorCollectionItem alloc] init];
    userItem.user = _user;
    TGCollectionMenuSection *userSection = [[TGCollectionMenuSection alloc] initWithItems:@[userItem]];
    UIEdgeInsets insets = userSection.insets;
    insets.top = 35.0f;
    userSection.insets = insets;
    [self.menuSections addSection:userSection];
    
    TGHeaderCollectionItem *accessLevelHeader = [[TGHeaderCollectionItem alloc] initWithTitle:[TGLocalized(@"Channel.BanUser.PermissionsHeader") uppercaseString]];
    
    __weak TGChannelBanController *weakSelf = self;
    
    _canReadMessages = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.BanUser.PermissionReadMessages") isOn:!_member.bannedRights.banReadMessages];
    _canReadMessages.isPermission = true;
    
    _canSendMessages = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.BanUser.PermissionSendMessages") isOn:!_member.bannedRights.banSendMessages];
    _canSendMessages.isPermission = true;
    
    _canSendMedia = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.BanUser.PermissionSendMedia") isOn:!_member.bannedRights.banSendMedia];
    _canSendMedia.isPermission = true;
    
    _canSendStickers = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.BanUser.PermissionSendStickersAndGifs") isOn:!_member.bannedRights.banSendStickers || !_member.bannedRights.banSendGifs || !_member.bannedRights.banSendGames || !_member.bannedRights.banSendInline];
    _canSendStickers.isPermission = true;
    
    _canEmbedLinks = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.BanUser.PermissionEmbedLinks") isOn:!_member.bannedRights.banEmbedLinks];
    _canEmbedLinks.isPermission = true;
    
    NSMutableArray *rightsItems = [[NSMutableArray alloc] init];
    [rightsItems addObject:accessLevelHeader];
    
    [rightsItems addObject:_canReadMessages];
    [rightsItems addObject:_canSendMessages];
    [rightsItems addObject:_canSendMedia];
    [rightsItems addObject:_canSendStickers];
    [rightsItems addObject:_canEmbedLinks];
    
    for (TGSwitchCollectionItem *item in rightsItems) {
        if ([item isKindOfClass:[TGSwitchCollectionItem class]]) {
            item.toggled = ^(__unused bool value, TGSwitchCollectionItem *item) {
                __strong TGChannelBanController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf toggleItem:item];
                }
            };
        }
    }
    
    TGCollectionMenuSection *rightsSection = [[TGCollectionMenuSection alloc] initWithItems:rightsItems];
    [self.menuSections addSection:rightsSection];
    
    if (_isPreview) {
        for (id item in rightsItems) {
            if ([item isKindOfClass:[TGSwitchCollectionItem class]]) {
                ((TGSwitchCollectionItem *)item).isEnabled = false;
            }
        }
    }
    
    _banTimeout = _member.bannedRights.timeout;
    int32_t timestamp = (int32_t)[[TGTelegramNetworking instance] approximateRemoteTime];
    _blockTimeout = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.BanUser.BlockFor") variant:stringForBanTimeout(_banTimeout == INT32_MAX ? _banTimeout : (_banTimeout - timestamp)) action:@selector(timeoutPressed)];
    _blockTimeout.deselectAutomatically = true;
    if (_isPreview) {
        _blockTimeout.enabled = false;
        _blockTimeout.hideArrow = true;
    }
    TGCollectionMenuSection *timeoutSection = [[TGCollectionMenuSection alloc] initWithItems:@[_blockTimeout]];
    [self.menuSections addSection:timeoutSection];
    
    _unbanItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.BanUser.Unban") action:@selector(unbanPressed)];
    _unbanItem.deselectAutomatically = true;
    _unbanItem.titleColor = TGDestructiveAccentColor();
    TGCollectionMenuSection *unbanSection = [[TGCollectionMenuSection alloc] initWithItems:@[_unbanItem]];
    if (!_isPreview) {
        [self.menuSections addSection:unbanSection];
    }
    
    if (self.isViewLoaded) {
        [_activityIndicator removeFromSuperview];
        self.collectionView.alpha = 1.0f;
        [self.collectionView reloadData];
    }
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

- (void)unbanPressed {
    if (_done) {
        TGChannelBannedRights *rights = [[TGChannelBannedRights alloc] initWithBanReadMessages:false banSendMessages:false banSendMedia:false banSendStickers:false banSendGifs:false banSendGames:false banSendInline:false banEmbedLinks:false timeout:0];
        _done(rights);
    }
}

- (void)donePressed {
    if (_done) {
        TGChannelBannedRights *rights = [[TGChannelBannedRights alloc] initWithBanReadMessages:!_canReadMessages.isOn banSendMessages:!_canSendMessages.isOn banSendMedia:!_canSendMedia.isOn banSendStickers:!_canSendStickers.isOn banSendGifs:!_canSendStickers.isOn banSendGames:!_canSendStickers.isOn banSendInline:!_canSendStickers.isOn banEmbedLinks:!_canEmbedLinks.isOn timeout:_banTimeout];
        if (_originalMember != nil) {
            if ([[_originalMember bannedRights] isEqual:rights]) {
                _done(nil);
                return;
            }
        }
        _done(rights);
    }
}

- (void)timeoutPressed {
    __weak TGChannelBanController *weakSelf = self;
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    for (NSNumber *value in timeoutValues())
    {
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:stringForBanTimeout([value intValue]) action:[[NSString alloc] initWithFormat:@"%@", value]]];
    }
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"MessageTimer.Custom") action:@"custom"]];
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
    
    [[[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(__unused id target, NSString *action) {
        __strong TGChannelBanController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if ([action isEqualToString:@"custom"]) {
                strongSelf->_pickerSheet = [[TGPickerSheet alloc] initWithDateSelection:^(NSTimeInterval item) {
                    __strong TGChannelBanController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        int32_t timestamp = (int32_t)[[TGTelegramNetworking instance] approximateRemoteTime];
                        if (item - timestamp >= 0) {
                            strongSelf->_banTimeout = (int32_t)item;
                            strongSelf->_blockTimeout.variant = stringForBanTimeout(strongSelf->_banTimeout == INT32_MAX ? INT32_MAX : (strongSelf->_banTimeout - timestamp));
                        }
                    }
                } banTimeout:true];
                strongSelf->_pickerSheet.emptyValue = TGLocalized(@"MessageTimer.Forever");
                [strongSelf->_pickerSheet show];
            } else if (![action isEqualToString:@"cancel"]) {
                int32_t timestamp = (int32_t)[[TGTelegramNetworking instance] approximateRemoteTime];
                if ([action intValue] == INT32_MAX) {
                    strongSelf->_banTimeout = INT32_MAX;
                } else {
                    strongSelf->_banTimeout = timestamp + 1 * 60 * 60 + [action intValue];
                }
                strongSelf->_blockTimeout.variant = stringForBanTimeout(strongSelf->_banTimeout == INT32_MAX ? INT32_MAX : (strongSelf->_banTimeout - timestamp));
            }
        }
    } target:self] showInView:self.view];
}

- (void)toggleItem:(TGSwitchCollectionItem *)item {
    if (item == _canReadMessages) {
        if (!_canReadMessages.isOn) {
            [_canSendMessages setIsOn:false animated:true];
            [_canSendMedia setIsOn:false animated:true];
            [_canSendStickers setIsOn:false animated:true];
            [_canEmbedLinks setIsOn:false animated:true];
        }
    } else if (item == _canSendMessages) {
        if (_canSendMessages.isOn) {
            if (!_canReadMessages.isOn) {
                [_canReadMessages setIsOn:true animated:true];
            }
        } else {
            [_canSendMedia setIsOn:false animated:true];
            [_canSendStickers setIsOn:false animated:true];
            [_canEmbedLinks setIsOn:false animated:true];
        }
    } else if (item == _canSendMedia) {
        if (_canSendMedia.isOn) {
            if (!_canReadMessages.isOn) {
                [_canReadMessages setIsOn:true animated:true];
            }
        } else {
            [_canSendMedia setIsOn:false animated:true];
            [_canSendStickers setIsOn:false animated:true];
            [_canEmbedLinks setIsOn:false animated:true];
        }
    } else {
        if (item.isOn) {
            if (!_canReadMessages.isOn) {
                [_canReadMessages setIsOn:true animated:true];
            }
            if (!_canSendMessages.isOn) {
                [_canSendMessages setIsOn:true animated:true];
            }
            if (!_canSendMedia.isOn) {
                [_canSendMedia setIsOn:true animated:true];
            }
        }
    }
}

@end
