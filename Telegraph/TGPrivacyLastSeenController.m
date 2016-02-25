#import "TGPrivacyLastSeenController.h"

#import "TGNotificationPrivacyAccountSetting.h"

#import "TGCheckCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGVariantCollectionItem.h"
#import "TGHacks.h"

#import "TGPrivacyCustomShareListController.h"

#import "TGStringUtils.h"

#import "TGHeaderCollectionItem.h"

@interface TGPrivacyLastSeenController ()
{
    TGPrivacySettingsMode _mode;
    TGNotificationPrivacyAccountSetting *_savedPrivacySettings;
    TGNotificationPrivacyAccountSetting *_privacySettings;
    bool _settingsModified;
    
    TGCheckCollectionItem *_everybodyItem;
    TGCheckCollectionItem *_contactsItem;
    TGCheckCollectionItem *_nobodyItem;
    
    TGVariantCollectionItem *_alwaysShareWithItem;
    TGVariantCollectionItem *_neverShareWithItem;
    
    TGCollectionMenuSection *_customShareSection;
    
    id _addInterfaceCoordinator;
}

@end

@implementation TGPrivacyLastSeenController

- (instancetype)initWithMode:(TGPrivacySettingsMode)mode privacySettings:(TGNotificationPrivacyAccountSetting *)privacySettings privacySettingsChanged:(void (^)(TGNotificationPrivacyAccountSetting *))privacySettingsChanged
{
    self = [super init];
    if (self != nil)
    {
        _mode = mode;
        
        switch (_mode) {
            case TGPrivacySettingsModeLastSeen:
                self.title = TGLocalized(@"PrivacyLastSeenSettings.Title");
                break;
            case TGPrivacySettingsModeGroupsAndChannels:
                self.title = TGLocalized(@"Privacy.GroupsAndChannels");
                break;
        }
        
        _privacySettingsChanged = [privacySettingsChanged copy];
        
        _everybodyItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"PrivacySettings.LastSeenEverybody") action:@selector(everybodyPressed)];
        _everybodyItem.alignToRight = true;
        _contactsItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"PrivacySettings.LastSeenContacts") action:@selector(contactsPressed)];
        _contactsItem.alignToRight = true;
        _nobodyItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"PrivacySettings.LastSeenNobody") action:@selector(nobodyPressed)];
        _nobodyItem.alignToRight = true;
        NSString *customHelpText = nil;
        NSString *headerString = nil;
        switch (_mode) {
            case TGPrivacySettingsModeLastSeen:
                customHelpText = TGLocalized(@"PrivacyLastSeenSettings.CustomHelp");
                headerString = TGLocalized(@"PrivacyLastSeenSettings.WhoCanSeeMyTimestamp");
                break;
            case TGPrivacySettingsModeGroupsAndChannels:
                customHelpText = TGLocalized(@"Privacy.GroupsAndChannels.CustomHelp");
                headerString = TGLocalized(@"Privacy.GroupsAndChannels.WhoCanAddMe");
                break;
        }
        
        NSMutableArray *topSectionItems = [[NSMutableArray alloc] init];
        [topSectionItems addObject:[[TGHeaderCollectionItem alloc] initWithTitle:headerString]];
        [topSectionItems addObject:_everybodyItem];
        [topSectionItems addObject:_contactsItem];
        if (_mode == TGPrivacySettingsModeLastSeen) {
            [topSectionItems addObject:_nobodyItem];
        }
        [topSectionItems addObject:[[TGCommentCollectionItem alloc] initWithText:customHelpText]];
        TGCollectionMenuSection *topSection = [[TGCollectionMenuSection alloc] initWithItems:topSectionItems];
        UIEdgeInsets topSectionInsets = topSection.insets;
        topSectionInsets.top = 32.0f;
        topSection.insets = topSectionInsets;
        [self.menuSections addSection:topSection];
        
        NSString *alwaysString = nil;
        NSString *neverString = nil;
        NSString *helpText = nil;
        switch (_mode) {
            case TGPrivacySettingsModeLastSeen:
                alwaysString = TGLocalized(@"PrivacyLastSeenSettings.AlwaysShareWith");
                neverString = TGLocalized(@"PrivacyLastSeenSettings.NeverShareWith");
                helpText = TGLocalized(@"PrivacyLastSeenSettings.CustomShareSettingsHelp");
                break;
                
            case TGPrivacySettingsModeGroupsAndChannels:
                alwaysString = TGLocalized(@"Privacy.GroupsAndChannels.AlwaysAllow");
                neverString = TGLocalized(@"Privacy.GroupsAndChannels.NeverAllow");
                helpText = TGLocalized(@"Privacy.GroupsAndChannels.CustomShareHelp");
                break;
        }
        
        _alwaysShareWithItem = [[TGVariantCollectionItem alloc] initWithTitle:alwaysString action:@selector(alwaysShareWithPressed)];
        _neverShareWithItem = [[TGVariantCollectionItem alloc] initWithTitle:neverString action:@selector(neverShareWithPressed)];
        _customShareSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGCommentCollectionItem alloc] initWithText:helpText]
        ]];
        [self.menuSections addSection:_customShareSection];
        
        _savedPrivacySettings = privacySettings;
        [self setPrivacySettings:privacySettings animated:false];
    }
    return self;
}

- (void)setPrivacySettings:(TGNotificationPrivacyAccountSetting *)privacySettings animated:(bool)__unused animated
{
    _privacySettings = privacySettings;
    
    _everybodyItem.isChecked = privacySettings.lastSeenPrimarySetting == TGPrivacySettingsLastSeenPrimarySettingEverybody;
    _contactsItem.isChecked = privacySettings.lastSeenPrimarySetting == TGPrivacySettingsLastSeenPrimarySettingContacts;
    _nobodyItem.isChecked = privacySettings.lastSeenPrimarySetting == TGPrivacySettingsLastSeenPrimarySettingNobody;
    
    if (_privacySettings.alwaysShareWithUserIds.count == 0)
        _alwaysShareWithItem.variant = TGLocalized(@"PrivacyLastSeenSettings.EmpryUsersPlaceholder");
    else
        _alwaysShareWithItem.variant = [TGStringUtils stringForUserCount:_privacySettings.alwaysShareWithUserIds.count];
    
    if (_privacySettings.neverShareWithUserIds.count == 0)
        _neverShareWithItem.variant = TGLocalized(@"PrivacyLastSeenSettings.EmpryUsersPlaceholder");
    else
        _neverShareWithItem.variant = [TGStringUtils stringForUserCount:_privacySettings.neverShareWithUserIds.count];
    
    NSUInteger sectionIndex = [self indexForSection:_customShareSection];
    while (_customShareSection.items.count > 1)
    {
        /*if (animated)
        {
            TGCollectionItem *item = _customShareSection.items[0];
            if (item.boundView != nil)
            {
                UIView *copyView = [item.boundView snapshotViewAfterScreenUpdates:false];
                copyView.frame = item.boundView.frame;
                [item.boundView.superview insertSubview:copyView aboveSubview:item.boundView];
                [UIView animateWithDuration:0.15 animations:^
                {
                    copyView.alpha = 0.0f;
                } completion:^(__unused BOOL finished)
                {
                    [copyView removeFromSuperview];
                }];
            }
        }*/
        
        [self.menuSections deleteItemFromSection:sectionIndex atIndex:0];
    }
    switch (privacySettings.lastSeenPrimarySetting)
    {
        case TGPrivacySettingsLastSeenPrimarySettingEverybody:
            [self.menuSections insertItem:_neverShareWithItem toSection:sectionIndex atIndex:0];
            break;
        case TGPrivacySettingsLastSeenPrimarySettingContacts:
            [self.menuSections insertItem:_neverShareWithItem toSection:sectionIndex atIndex:0];
            [self.menuSections insertItem:_alwaysShareWithItem toSection:sectionIndex atIndex:1];
            break;
        case TGPrivacySettingsLastSeenPrimarySettingNobody:
            [self.menuSections insertItem:_alwaysShareWithItem toSection:sectionIndex atIndex:0];
            break;
        default:
            break;
    }
    //[TGHacks setAnimationDurationFactor:0.01f];
    //[self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
    //[self.collectionView layoutSubviews];
    //[TGHacks setAnimationDurationFactor:1.0f];
    NSIndexPath *indexPath = [self.collectionView indexPathsForSelectedItems].firstObject;
    [self.collectionView reloadData];
    [self.collectionView selectItemAtIndexPath:indexPath animated:false scrollPosition:UICollectionViewScrollPositionNone];
    [self.collectionView deselectItemAtIndexPath:indexPath animated:true];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (![[self.navigationController viewControllers] containsObject:self])
    {
        if (_settingsModified)
        {
            if (_privacySettingsChanged)
                _privacySettingsChanged(_privacySettings);
        }
    }
}

- (void)setSettingsModified:(bool)settingsModified
{
    if (_settingsModified != settingsModified)
    {
        _settingsModified = settingsModified;
        
        if (_settingsModified)
        {
            [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)] animated:true];
        }
        else
        {
            [self setRightBarButtonItem:nil animated:true];
            
            if (false && iosMajorVersion() >= 7)
            {
                UIView *backArrow = _findBackArrow(self.navigationController.navigationBar);
                backArrow.alpha = 0.0f;
                [UIView animateWithDuration:0.3 delay:0.17 options:0 animations:^
                {
                    backArrow.alpha = 1.0f;
                } completion:nil];
            }
        }
    }
}

static UIView *_findBackArrow(UIView *view)
{
    Class backArrowClass = NSClassFromString(TGEncodeText(@"`VJObwjhbujpoCbsCbdlJoejdbupsWjfx", -1));
    
    if ([view isKindOfClass:backArrowClass])
        return view;
    
    for (UIView *subview in view.subviews)
    {
        UIView *result = _findBackArrow(subview);
        if (result != nil)
            return result;
    }
    
    return nil;
}

- (void)cancelPressed
{
    [self setPrivacySettings:_savedPrivacySettings animated:true];
    [self setSettingsModified:false];
}

- (void)donePressed
{
    [self setPrivacySettings:[_privacySettings normalize] animated:false];
    if (_privacySettingsChanged)
        _privacySettingsChanged(_privacySettings);
    _savedPrivacySettings = _privacySettings;
    [self setSettingsModified:false];
}

- (void)updatePrivacySettings:(TGNotificationPrivacyAccountSetting *)privacySettings
{
    if (![TGNotificationPrivacyAccountSetting isEqual:_privacySettings])
    {
        [self setPrivacySettings:privacySettings animated:true];
        [self setSettingsModified:![privacySettings isEqual:_savedPrivacySettings]];
    }
}

- (void)everybodyPressed
{
    [self updatePrivacySettings:[_privacySettings modifyLastSeenPrimarySetting:TGPrivacySettingsLastSeenPrimarySettingEverybody]];
}

- (void)contactsPressed
{
    [self updatePrivacySettings:[_privacySettings modifyLastSeenPrimarySetting:TGPrivacySettingsLastSeenPrimarySettingContacts]];
}

- (void)nobodyPressed
{
    [self updatePrivacySettings:[_privacySettings modifyLastSeenPrimarySetting:TGPrivacySettingsLastSeenPrimarySettingNobody]];
}

- (void)alwaysShareWithPressed
{
    NSString *titleString = nil;
    NSString *placeholderString = nil;
    switch (_mode) {
        case TGPrivacySettingsModeLastSeen:
            titleString = TGLocalized(@"PrivacyLastSeenSettings.AlwaysShareWith.Title");
            placeholderString = TGLocalized(@"PrivacyLastSeenSettings.AlwaysShareWith.Placeholder");
            break;
        case TGPrivacySettingsModeGroupsAndChannels:
            titleString = TGLocalized(@"Privacy.GroupsAndChannels.AlwaysAllow.Title");
            placeholderString = TGLocalized(@"Privacy.GroupsAndChannels.AlwaysAllow.Placeholder");
            break;
    }
    
    __weak TGPrivacyLastSeenController *weakSelf = self;
    if (_privacySettings.alwaysShareWithUserIds.count == 0)
    {
        _addInterfaceCoordinator = [TGPrivacyCustomShareListController presentAddInterfaceWithTitle:titleString contactSearchPlaceholder:placeholderString onController:self completion:^(NSArray *userIds)
        {
            __strong TGPrivacyLastSeenController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                strongSelf->_addInterfaceCoordinator = nil;
                [strongSelf updatePrivacySettings:[strongSelf->_privacySettings modifyAlwaysShareWithUserIds:userIds]];
                
                if (userIds.count != 0)
                {
                    [strongSelf.navigationController pushViewController:[[TGPrivacyCustomShareListController alloc] initWithTitle:titleString contactSearchPlaceholder:placeholderString userIds:strongSelf->_privacySettings.alwaysShareWithUserIds userIdsChanged:^(NSArray *userIds)
                    {
                        __strong TGPrivacyLastSeenController *strongSelf = weakSelf;
                        if (strongSelf != nil)
                            [strongSelf updatePrivacySettings:[strongSelf->_privacySettings modifyAlwaysShareWithUserIds:userIds]];
                    }] animated:false];
                }
                
                [strongSelf dismissViewControllerAnimated:true completion:nil];
            }
        }];
    }
    else
    {
        [self.navigationController pushViewController:[[TGPrivacyCustomShareListController alloc] initWithTitle:titleString contactSearchPlaceholder:placeholderString userIds:_privacySettings.alwaysShareWithUserIds userIdsChanged:^(NSArray *userIds)
        {
            __strong TGPrivacyLastSeenController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf updatePrivacySettings:[strongSelf->_privacySettings modifyAlwaysShareWithUserIds:userIds]];
        }] animated:true];
    }
}

- (void)neverShareWithPressed
{
    NSString *titleString = nil;
    NSString *placeholderString = nil;
    switch (_mode) {
        case TGPrivacySettingsModeLastSeen:
            titleString = TGLocalized(@"PrivacyLastSeenSettings.NeverShareWith.Title");
            placeholderString = TGLocalized(@"PrivacyLastSeenSettings.NeverShareWith.Placeholder");
            break;
        case TGPrivacySettingsModeGroupsAndChannels:
            titleString = TGLocalized(@"Privacy.GroupsAndChannels.NeverAllow.Title");
            placeholderString = TGLocalized(@"Privacy.GroupsAndChannels.NeverAllow.Placeholder");
            break;
    }
    
    __weak TGPrivacyLastSeenController *weakSelf = self;
    if (_privacySettings.neverShareWithUserIds.count == 0)
    {
        _addInterfaceCoordinator = [TGPrivacyCustomShareListController presentAddInterfaceWithTitle:titleString contactSearchPlaceholder:placeholderString onController:self completion:^(NSArray *userIds)
        {
            __strong TGPrivacyLastSeenController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                strongSelf->_addInterfaceCoordinator = nil;
                [strongSelf updatePrivacySettings:[strongSelf->_privacySettings modifyNeverShareWithUserIds:userIds]];
                
                if (userIds.count != 0)
                {
                    [strongSelf.navigationController pushViewController:[[TGPrivacyCustomShareListController alloc] initWithTitle:titleString contactSearchPlaceholder:placeholderString userIds:strongSelf->_privacySettings.neverShareWithUserIds userIdsChanged:^(NSArray *userIds)
                    {
                        __strong TGPrivacyLastSeenController *strongSelf = weakSelf;
                        if (strongSelf != nil)
                            [strongSelf updatePrivacySettings:[strongSelf->_privacySettings modifyNeverShareWithUserIds:userIds]];
                    }] animated:false];
                }
                
                [strongSelf dismissViewControllerAnimated:true completion:nil];
            }
        }];
    }
    else
    {
        [self.navigationController pushViewController:[[TGPrivacyCustomShareListController alloc] initWithTitle:titleString contactSearchPlaceholder:placeholderString userIds:_privacySettings.neverShareWithUserIds userIdsChanged:^(NSArray *userIds)
        {
            __strong TGPrivacyLastSeenController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf updatePrivacySettings:[strongSelf->_privacySettings modifyNeverShareWithUserIds:userIds]];
        }] animated:true];
    }
}

@end
