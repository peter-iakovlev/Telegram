#import "TGNotificationExceptionsController.h"

#import <LegacyComponents/TGModernBarButton.h>

#import "TGAppDelegate.h"
#import "TGLegacyComponentsContext.h"
#import "TGPresentation.h"
#import "TGTelegramNetworking.h"
#import "TGTelegraph.h"
#import "TGDatabase.h"

#import "TGCustomActionSheet.h"
#import "TGNotificationExceptionCell.h"

#import "TGNotificationException.h"

#import "TGForwardTargetController.h"
#import "TGAlertSoundController.h"

@interface TGNotificationExceptionsController () <TGSearchDisplayMixinDelegate, UITableViewDelegate, UITableViewDataSource, ASWatcher, TGAlertSoundControllerDelegate>
{
    UITableView *_tableView;
    TGSearchBar *_searchBar;
    UIView *_searchTopBackgroundView;
    TGSearchDisplayMixin *_searchMixin;
    
    NSString *_filterString;
    
    bool _group;
    NSArray *_items;
    NSArray *_filteredItems;
    NSDictionary *_peers;
    
    UILabel *_placeholderLabel;
    
    NSMutableDictionary *_titlesParts;
    
    NSDictionary *_defaultPrivateNotificationSettings;
    NSDictionary *_defaultGroupNotificationSettings;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGNotificationExceptionsController

- (instancetype)initWithExceptions:(NSArray *)exceptions peers:(NSDictionary *)peers group:(bool)group
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        _group = group;
        
        self.title = TGLocalized(@"Notifications.ExceptionsTitle");
        
        _items = exceptions;
        _peers = peers;
        _titlesParts = [[NSMutableDictionary alloc] init];
        
        _defaultPrivateNotificationSettings = [[NSMutableDictionary alloc] initWithDictionary:@{@"muteUntil": @(0), @"soundId": @(1)}];
        _defaultGroupNotificationSettings = [[NSMutableDictionary alloc] initWithDictionary:@{@"muteUntil": @(0), @"soundId": @(1)}];
        
        [ActionStageInstance() watchForPath:[NSString stringWithFormat:@"/tg/peerSettings/(%" PRId32 ")", INT_MAX - 1] watcher:self];
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/peerSettings/(%d,cachedOnly)", INT_MAX - 1] options:[NSDictionary dictionaryWithObject:[NSNumber numberWithLongLong:INT_MAX - 1] forKey:@"peerId"] watcher:self];
        
        [ActionStageInstance() watchForPath:[NSString stringWithFormat:@"/tg/peerSettings/(%" PRId32 ")", INT_MAX - 2] watcher:self];
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/peerSettings/(%d,cachedOnly)", INT_MAX - 2] options:[NSDictionary dictionaryWithObject:[NSNumber numberWithLongLong:INT_MAX - 2] forKey:@"peerId"] watcher:self];
    }
    return self;
}

- (void)dealloc {
    [_actionHandle reset];
    
    _tableView.delegate = nil;
    
    _searchMixin.delegate = nil;
    [_searchMixin unload];
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    if (_searchMixin != nil)
        [_searchMixin controllerInsetUpdated:self.controllerInset];
    
    [super controllerInsetUpdated:previousInset];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = self.presentation.pallete.backgroundColor;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    if (iosMajorVersion() >= 11)
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.opaque = true;
    _tableView.backgroundColor = self.presentation.pallete.backgroundColor;
    _tableView.separatorColor = self.presentation.pallete.separatorColor;
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (iosMajorVersion() >= 7) {
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = self.presentation.pallete.separatorColor;
        _tableView.separatorInset = UIEdgeInsetsMake(0.0f, 65.0f, 0.0f, 0.0f);
    }
    [self.view addSubview:_tableView];
    
    _placeholderLabel = [[UILabel alloc] init];
    _placeholderLabel.backgroundColor = [UIColor clearColor];
    _placeholderLabel.textColor = _presentation.pallete.collectionMenuCommentColor;
    _placeholderLabel.font = TGSystemFontOfSize(16.0f);
    _placeholderLabel.text = _group ? TGLocalized(@"Notifications.ExceptionsGroupPlaceholder") : TGLocalized(@"Notifications.ExceptionsMessagePlaceholder");
    _placeholderLabel.textAlignment = NSTextAlignmentCenter;
    _placeholderLabel.numberOfLines = 0;
    _placeholderLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.view addSubview:_placeholderLabel];
    
    _searchBar = [[TGSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [TGSearchBar searchBarBaseHeight]) style:TGSearchBarStyleLightPlain];
    _searchBar.pallete = self.presentation.searchBarPallete;
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.safeAreaInset = [self controllerSafeAreaInset];
    _searchBar.placeholder = TGLocalized(@"ChatSearch.SearchPlaceholder");
    
    _searchTopBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320.0f)];
    _searchTopBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_tableView insertSubview:_searchTopBackgroundView atIndex:0];
    
    _searchMixin = [[TGSearchDisplayMixin alloc] init];
    _searchMixin.searchBar = _searchBar;
    _searchMixin.delegate = self;
    
    _tableView.tableHeaderView = _searchBar;
    
    [self updatePlaceholderHidden];
    
    [self setRightBarButtonItem:[self controllerRightBarButtonItem] animated:false];
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)setPresentation:(TGPresentation *)presentation
{
    _presentation = presentation;
    self.view.backgroundColor = _presentation.pallete.backgroundColor;
    _tableView.backgroundColor = _presentation.pallete.backgroundColor;
    _tableView.separatorColor = _presentation.pallete.separatorColor;
    _placeholderLabel.textColor = _presentation.pallete.collectionMenuCommentColor;
    _searchBar.pallete = _presentation.searchBarPallete;
    _searchMixin.searchResultsTableView.backgroundColor = self.presentation.pallete.backgroundColor;
    _searchMixin.searchResultsTableView.separatorColor = self.presentation.pallete.separatorColor;
    
    [self setRightBarButtonItem:[self controllerRightBarButtonItem] animated:false];
}

- (void)updatePlaceholderHidden
{
    _placeholderLabel.hidden = _items.count > 0;
    _searchBar.hidden = _items.count == 0;
}

- (UIBarButtonItem *)controllerRightBarButtonItem
{
    if (iosMajorVersion() < 7)
    {
        TGModernBarButton *addButton = [[TGModernBarButton alloc] initWithImage:TGTintedImage([UIImage imageNamed:@"ModernNavigationAddButtonIcon.png"], self.presentation.pallete.navigationButtonColor)];
        addButton.portraitAdjustment = CGPointMake(-7, -5);
        addButton.landscapeAdjustment = CGPointMake(-7, -4);
        [addButton addTarget:self action:@selector(addButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        return [[UIBarButtonItem alloc] initWithCustomView:addButton];
    }
    else
    {
        return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed)];
    }
}

- (void)addButtonPressed
{
    NSMutableSet *excludedIds = [[NSMutableSet alloc] init];
    for (TGNotificationException *exception in _items)
    {
        [excludedIds addObject:@(exception.peerId)];
    }
    
    TGForwardTargetController *controller = _group ? [[TGForwardTargetController alloc] initWithSelectGroup:excludedIds] : [[TGForwardTargetController alloc] initWithSelectPrivate:excludedIds];
    controller.watcherHandle = self.actionHandle;
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[controller]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
}

static NSArray *breakStringIntoParts(NSString *string)
{
    NSMutableArray *parts = [[NSMutableArray alloc] initWithCapacity:2];
    string = [string stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length) options:NSStringEnumerationByWords usingBlock:^(NSString *substring, __unused NSRange substringRange, __unused NSRange enclosingRange, __unused BOOL *stop)
     {
         if (substring != nil)
             [parts addObject:[substring lowercaseString]];
     }];
    return parts;
}

- (bool)title:(NSString *)title matchesQuery:(NSString *)query withParts:(NSArray *)parts
{
    if (title == nil)
        return false;
    
    if ([title isEqualToString:query])
        return true;
    
    NSArray *nameParts = _titlesParts[title];
    if (nameParts == nil)
    {
        nameParts = breakStringIntoParts(title);
        _titlesParts[title] = nameParts;
    }
    
    bool failed = true;
    
    bool everyPartMatches = true;
    for (NSString *queryPart in parts)
    {
        bool hasMatches = false;
        for (NSString *testPart in nameParts)
        {
            if ([testPart hasPrefix:queryPart])
            {
                hasMatches = true;
                break;
            }
        }
        
        if (!hasMatches)
        {
            everyPartMatches = false;
            break;
        }
    }
    if (everyPartMatches)
        failed = false;
    
    return !failed;
}

- (void)filterItems
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    NSArray *parts = breakStringIntoParts(_filterString);
    if (parts.count == 0)
    {
        _filteredItems = @[];
        return;
    }
    
    for (TGNotificationException *item in _items) {
        NSString *title = @"";
        id peer = _peers[@(item.peerId)];
        if ([peer isKindOfClass:[TGUser class]])
            title = ((TGUser *)peer).displayName;
        else if ([peer isKindOfClass:[TGConversation class]])
            title = ((TGConversation *)peer).chatTitle;
        
        if (_filterString.length == 0 || [self title:title matchesQuery:_filterString withParts:parts]) {
            [items addObject:item];
        }
    }
    _filteredItems = items;
}

- (UITableView *)createTableViewForSearchMixin:(TGSearchDisplayMixin *)__unused searchMixin
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    tableView.backgroundColor = self.presentation.pallete.backgroundColor;
    tableView.separatorColor = self.presentation.pallete.separatorColor;
    
    return tableView;
}

- (UIView *)referenceViewForSearchResults
{
    return _tableView;
}

- (void)searchMixin:(TGSearchDisplayMixin *)searchMixin hasChangedSearchQuery:(NSString *)searchQuery withScope:(int)__unused scope
{
    _filterString = [searchQuery lowercaseString];
    [self filterItems];
    
    [searchMixin reloadSearchResults];
    [searchMixin setSearchResultsTableViewHidden:searchQuery.length == 0];
}

- (void)searchMixinWillActivate:(bool)animated
{
    _tableView.scrollEnabled = false;
    [self setNavigationBarHidden:true animated:animated];
}

- (void)searchMixinWillDeactivate:(bool)animated
{
    _tableView.scrollEnabled = true;
    [self setNavigationBarHidden:false animated:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)__unused tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)__unused section {
    if (tableView == _tableView)
        return (NSInteger)_items.count;
    else
        return (NSInteger)_filteredItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TGNotificationException *exception = nil;
    if (tableView == _tableView)
        exception = _items[indexPath.row];
    else
        exception = _filteredItems[indexPath.row];
    
    TGNotificationExceptionCell *cell = (TGNotificationExceptionCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[TGNotificationExceptionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    cell.presentation = self.presentation;
    [cell setException:exception peers:_peers];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForRowAtIndexPath:(NSIndexPath *)__unused indexPath
{
    return 56.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    TGNotificationException *exception = nil;
    if (tableView == _tableView)
        exception = _items[indexPath.row];
    else
        exception = _filteredItems[indexPath.row];
    
    [self presentActionsForPeerId:exception.peerId add:false soundId:exception.notificationType];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGSize boundsSize = CGSizeMake(self.view.bounds.size.width - 20.0f, CGFLOAT_MAX);
    
    CGSize textSize = [_placeholderLabel sizeThatFits:boundsSize];
    _placeholderLabel.frame = CGRectMake(CGFloor((self.view.bounds.size.width - textSize.width) / 2.0f), _tableView.contentInset.top + CGFloor((self.view.bounds.size.height - _tableView.contentInset.top - textSize.height) / 2.0f), textSize.width, textSize.height);
}

- (void)presentActionsForPeerId:(int64_t)peerId add:(bool)add soundId:(NSNumber *)soundId
{
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    bool isGroup = !TGPeerIdIsUser(peerId);
    
    NSDictionary *defaultNotificationSettings = isGroup ? _defaultGroupNotificationSettings : _defaultPrivateNotificationSettings;
    
    bool defaultEnabled = [defaultNotificationSettings[@"muteUntil"] intValue] <= [[TGTelegramNetworking instance] approximateRemoteTime];
    NSString *defaultTitle = defaultEnabled ? TGLocalized(@"UserInfo.NotificationsDefaultEnabled") : TGLocalized(@"UserInfo.NotificationsDefaultDisabled");
    NSNumber *defaultSoundId = defaultNotificationSettings[@"soundId"];
    
    NSString *soundName = soundId != nil ? [TGAlertSoundController soundNameFromId:soundId.intValue] : TGLocalized(@"Notifications.ExceptionsDefaultSound");
    
    if (!add)
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:defaultTitle action:@"default"]];
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"UserInfo.NotificationsEnable") action:@"enable"]];
    
    NSArray *muteIntervals = @[
                               @(1 * 60 * 60),
                               @(2 * 24 * 60 * 60),
                               ];
    
    for (NSNumber *nMuteInterval in muteIntervals)
    {
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:[TGStringUtils stringForMuteInterval:[nMuteInterval intValue]] action:[[NSString alloc] initWithFormat:@"%@", nMuteInterval]]];
    }
    
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"UserInfo.NotificationsDisable") action:@"disable"]];
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:[NSString stringWithFormat:TGLocalized(@"Notifications.ExceptionsChangeSound"), soundName] action:@"sound" type:TGActionSheetActionTypeLined]];
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
    
    UIView *parentView = self.presentedViewController != nil ? self.presentedViewController.view : self.view;
    [[[TGCustomActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(TGNotificationExceptionsController *controller, NSString *action)
    {
        if (controller.presentedViewController != nil)
            [controller dismissViewControllerAnimated:true completion:nil];
        
        if ([action isEqualToString:@"enable"])
            [controller _commitEnableNotificationsForPeerId:peerId enable:@true orMuteFor:0];
        else if ([action isEqualToString:@"default"])
            [controller _commitEnableNotificationsForPeerId:peerId enable:nil orMuteFor:0];
        else if ([action isEqualToString:@"disable"])
            [controller _commitEnableNotificationsForPeerId:peerId enable:@false orMuteFor:0];
        else if ([action isEqualToString:@"sound"])
            [controller _presentSoundPickerForPeerId:peerId soundId:soundId defaultSoundId:defaultSoundId];
        else if (![action isEqualToString:@"cancel"])
            [controller _commitEnableNotificationsForPeerId:peerId enable:@false orMuteFor:[action intValue]];
    } target:self] showInView:parentView];
}

- (void)_commitEnableNotificationsForPeerId:(int64_t)peerId enable:(NSNumber *)enable orMuteFor:(int)muteFor
{
    NSNumber *muteUntil = nil;
    if (muteFor == 0)
    {
        if (enable)
            muteUntil = enable.boolValue ? @0: @(INT_MAX);
    }
    else
    {
        muteUntil = @((int)([[TGTelegramNetworking instance] approximateRemoteTime] + muteFor));
    }
    
    [self updateSettingsForPeerId:peerId changingSoundId:false muteUntil:muteUntil soundId:nil];
}

- (void)_presentSoundPickerForPeerId:(int64_t)peerId soundId:(NSNumber *)soundId defaultSoundId:(NSNumber *)defaultSoundId
{
    TGAlertSoundController *alertSoundController = [[TGAlertSoundController alloc] initWithTitle:TGLocalized(@"GroupInfo.Sound") soundInfoList:[self _soundInfoListForSelectedSoundId:soundId] defaultId:defaultSoundId];
    alertSoundController.peerId = peerId;
    alertSoundController.delegate = self;
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[alertSoundController] navigationBarClass:[TGWhiteNavigationBar class]];
    if ([self inPopover])
    {
        navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleChildInPopover;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)alertSoundController:(TGAlertSoundController *)alertSoundController didFinishPickingWithSoundInfo:(NSDictionary *)soundInfo
{
    NSNumber *soundId = soundInfo[@"soundId"];
    int64_t peerId = alertSoundController.peerId;
    
    [self updateSettingsForPeerId:peerId changingSoundId:true muteUntil:nil soundId:soundId];
}

- (void)updateSettingsForPeerId:(int64_t)peerId changingSoundId:(bool)changingSoundId muteUntil:(NSNumber *)muteUntil soundId:(NSNumber *)soundId
{
    __block bool delete = false;
    __block NSUInteger index = NSNotFound;
    __block TGNotificationException *newException = nil;
    [_items enumerateObjectsUsingBlock:^(TGNotificationException *exception, NSUInteger idx, BOOL * _Nonnull stop)
    {
        if (exception.peerId == peerId)
        {
            NSNumber *finalMuteUntil = changingSoundId ? exception.muteUntil : muteUntil;
            NSNumber *finalSoundId = changingSoundId ? soundId : exception.notificationType;
            if (finalMuteUntil != nil || finalSoundId != nil)
                newException = [[TGNotificationException alloc] initWithPeerId:peerId notificationType:finalSoundId muteUntil:finalMuteUntil];
            else
                delete = true;
            
            index = idx;
            *stop = true;
        }
    }];
    
    NSMutableArray *newItems = [_items mutableCopy];
    if (index != NSNotFound)
    {
        if (delete) {
            [newItems removeObjectAtIndex:index];
        } else {
            [newItems replaceObjectAtIndex:index withObject:newException];
        }
    }
    else
    {
        newException = [[TGNotificationException alloc] initWithPeerId:peerId notificationType:changingSoundId ? soundId : nil muteUntil:changingSoundId ? nil : muteUntil];
        [newItems insertObject:newException atIndex:0];
        
        if (_peers[@(peerId)] == nil)
        {
            id peer = TGPeerIdIsUser(peerId) ? [TGDatabaseInstance() loadUser:(int32_t)peerId] : [TGDatabaseInstance() loadConversationWithId:peerId];
            if (peer != nil)
            {
                NSMutableDictionary *peers = [[NSMutableDictionary alloc] init];
                [peers addEntriesFromDictionary:_peers];
                peers[@(peerId)] = peer;
                _peers = peers;
            }
        }
    }
    
    if (delete || newException != nil)
    {
        NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
        options[@"peerId"] = @(peerId);
        
        TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:peerId];
        options[@"accessHash"] = @(conversation.accessHash);
        
        if (changingSoundId)
            options[@"soundId"] = soundId ?: @(INT32_MIN);
        else
            options[@"muteUntil"] = muteUntil ?: @(INT32_MIN);
        
        static int actionId = 0;
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/changePeerSettings/(%" PRId64 ")/(notificationsExceptions%d)", peerId, actionId++] options:options watcher:TGTelegraphInstance];
    }
    
    _items = newItems;
    if (_filterString.length > 0) {
        [self filterItems];
        [_searchMixin reloadSearchResults];
    }
    
    if (self.updatedExceptions != nil)
        self.updatedExceptions(_items, _peers);
    
    [_tableView reloadData];
    [self updatePlaceholderHidden];
}

- (NSArray *)_soundInfoListForSelectedSoundId:(NSNumber *)selectedSoundId
{
    NSMutableArray *infoList = [[NSMutableArray alloc] init];
    
    int index = -1;
    for (NSString *soundName in [TGAppDelegateInstance modernAlertSoundTitles])
    {
        index++;
        
        int soundId = 0;
        
        if (index == 1)
            soundId = 1;
        else if (index == 0)
            soundId = 0;
        else
            soundId = index + 100 - 1;
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict[@"title"] = soundName;
        if (selectedSoundId != nil)
            dict[@"selected"] = @(selectedSoundId.intValue == soundId);
        dict[@"soundName"] = [[NSString alloc] initWithFormat:@"%d", soundId];
        dict[@"soundId"] = @(soundId);
        dict[@"groupId"] = @(0);
        [infoList addObject:dict];
    }
    
    index = -1;
    for (NSString *soundName in [TGAppDelegateInstance classicAlertSoundTitles])
    {
        index++;
        
        int soundId = index + 2;
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict[@"title"] = soundName;
        if (selectedSoundId != nil)
            dict[@"selected"] = @(selectedSoundId.intValue == soundId);
        dict[@"soundName"] =  [[NSString alloc] initWithFormat:@"%d", soundId];
        dict[@"soundId"] = @(soundId);
        dict[@"groupId"] = @(1);
        [infoList addObject:dict];
    }
    
    return infoList;
}

- (void)actorCompleted:(int)__unused status path:(NSString *)path result:(id)result
{
    TGDispatchOnMainThread(^
    {
        if ([path hasPrefix:[NSString stringWithFormat:@"/tg/peerSettings/(%" PRId32 "", INT_MAX - 1]])
        {
            _defaultPrivateNotificationSettings = [((SGraphObjectNode *)result).object mutableCopy];
        } else if ([path hasPrefix:[NSString stringWithFormat:@"/tg/peerSettings/(%" PRId32 "", INT_MAX - 2]])
        {
            _defaultGroupNotificationSettings = [((SGraphObjectNode *)result).object mutableCopy];
        }
    });
}

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"conversationSelected"])
    {
        TGConversation *conversation = (TGConversation *)options;
        [self presentActionsForPeerId:conversation.conversationId add:true soundId:nil];
    }
    else if ([action isEqualToString:@"userSelected"])
    {
        TGUser *user = (TGUser *)options;
        [self presentActionsForPeerId:user.uid add:true soundId:nil];
    }
}

@end
