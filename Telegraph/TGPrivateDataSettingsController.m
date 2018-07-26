#import "TGPrivateDataSettingsController.h"

#import "TGLegacyComponentsContext.h"

#import "TGTelegraph.h"
#import "TGAppDelegate.h"
#import "TGDatabase.h"
#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"

#import "TGRecentPeersSignals.h"
#import "TGRemoveContactFutureAction.h"
#import "TGGroupManagementSignals.h"

#import "TGHeaderCollectionItem.h"
#import "TGButtonCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGSwitchCollectionItem.h"

#import "TGCustomAlertView.h"
#import "TGCustomActionSheet.h"
#import "TGShareSheetWindow.h"
#import "TGShareSheetButtonItemView.h"
#import "TGAttachmentSheetCheckmarkVariantItemView.h"

@interface TGPrivateDataSettingsController () <ASWatcher>
{
    TGSwitchCollectionItem *_linkPreviewsItem;
    TGButtonCollectionItem *_resetContactsItem;
    TGSwitchCollectionItem *_syncContactsItem;
    
    TGSwitchCollectionItem *_topPeersItem;
    SDisposableSet *_recentPeersDisposables;
    SMetaDisposable *_toggleRecentPeersDisposable;
    
    TGButtonCollectionItem *_deleteDraftsItem;
    SMetaDisposable *_deleteDraftsDisposable;
    
    TGShareSheetWindow *_attachmentSheetWindow;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGPrivateDataSettingsController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        self.title = TGLocalized(@"PrivateDataSettings.Title");
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Back") style:UIBarButtonItemStylePlain target:nil action:nil];
        
        _resetContactsItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Privacy.ContactsReset") action:@selector(resetContactsPressed)];
        _resetContactsItem.deselectAutomatically = true;
        _syncContactsItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Privacy.ContactsSync") isOn:!TGAppDelegateInstance.contactsInhibitSync];
        _syncContactsItem.interfaceHandle = _actionHandle;
        TGCollectionMenuSection *contactsSection = [[TGCollectionMenuSection alloc] initWithItems:@[
                                                                                                    [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Privacy.ContactsTitle")],
                                                                                                    _resetContactsItem,
                                                                                                    _syncContactsItem,
                                                                                                    [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"Privacy.ContactsSyncHelp")]
                                                                                                    ]];
        [self.menuSections addSection:contactsSection];
        
        _topPeersItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Privacy.TopPeers") isOn:true];
        _topPeersItem.interfaceHandle = _actionHandle;
        TGCollectionMenuSection *topPeersSection = [[TGCollectionMenuSection alloc] initWithItems:@[
                                                                                                    _topPeersItem,
                                                                                                    [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"Privacy.TopPeersHelp")]
                                                                                                    ]];
        [self.menuSections addSection:topPeersSection];
        
        _deleteDraftsItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Privacy.DeleteDrafts") action:@selector(deleteDraftsPressed)];
        _deleteDraftsItem.deselectAutomatically = true;
        TGCollectionMenuSection *draftsSection = [[TGCollectionMenuSection alloc] initWithItems:@[ [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Privacy.ChatsTitle")], _deleteDraftsItem ]];
        [self.menuSections addSection:draftsSection];
        
        TGButtonCollectionItem *clearPaymentInfoItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Privacy.PaymentsClearInfo") action:@selector(clearPaymentsPressed)];
        clearPaymentInfoItem.deselectAutomatically = true;
        TGCollectionMenuSection *paymentsSection = [[TGCollectionMenuSection alloc] initWithItems:@[
                                                                                                    [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Privacy.PaymentsTitle")],
                                                                                                    clearPaymentInfoItem,
                                                                                                    [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"Privacy.PaymentsClearInfoHelp")]
                                                                                                    ]];
        [self.menuSections addSection:paymentsSection];
        
        bool linkPreviewsValue = TGAppDelegateInstance.allowSecretWebpagesInitialized ? TGAppDelegateInstance.allowSecretWebpages : false;
        _linkPreviewsItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Privacy.SecretChatsLinkPreviews") isOn:linkPreviewsValue];
        _linkPreviewsItem.interfaceHandle = _actionHandle;
        TGCollectionMenuSection *secretChatsSection = [[TGCollectionMenuSection alloc] initWithItems:@[
                                                                                                       [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Privacy.SecretChatsTitle")],
                                                                                                       _linkPreviewsItem,
                                                                                                       [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"Privacy.SecretChatsLinkPreviewsHelp")]
                                                                                                       ]];
        [self.menuSections addSection:secretChatsSection];
        
        _recentPeersDisposables = [[SDisposableSet alloc] init];
        SSignal *updatedRecentPeers = [[TGRecentPeersSignals updateRecentPeers] mapToSignal:^SSignal *(__unused id next) {
            return [SSignal complete];
        }];
        [_recentPeersDisposables add:[updatedRecentPeers startWithNext:nil]];
        
        __weak TGPrivateDataSettingsController *weakSelf = self;
        [_recentPeersDisposables add:[[[TGRecentPeersSignals recentPeers] deliverOn:[SQueue mainQueue]] startWithNext:^(TGRemoteRecentPeerCategories *next)
                                      {
                                          __strong TGPrivateDataSettingsController *strongSelf = weakSelf;
                                          if (strongSelf != nil)
                                              strongSelf->_topPeersItem.isOn = !next.disabled;
                                      }]];
        
        if (self.menuSections.sections.count != 0) {
            UIEdgeInsets topSectionInsets = ((TGCollectionMenuSection *)self.menuSections.sections[0]).insets;
            topSectionInsets.top = 32.0f;
            ((TGCollectionMenuSection *)self.menuSections.sections[0]).insets = topSectionInsets;
        }
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    
    [_recentPeersDisposables dispose];
    [_toggleRecentPeersDisposable dispose];
    [_deleteDraftsDisposable dispose];
}

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"switchItemChanged"])
    {
        TGSwitchCollectionItem *switchItem = options[@"item"];
        
        if (switchItem == _syncContactsItem)
        {
            TGAppDelegateInstance.contactsInhibitSync = !switchItem.isOn;
            [TGAppDelegateInstance saveSettings];
            
            if (switchItem.isOn)
                [ActionStageInstance() requestActor:@"/tg/synchronizeContacts/(sync)" options:@{@"forceFirstTime": @(true)} watcher:self];
        }
        else if (switchItem == _linkPreviewsItem)
        {
            TGAppDelegateInstance.allowSecretWebpagesInitialized = true;
            TGAppDelegateInstance.allowSecretWebpages = _linkPreviewsItem.isOn;
            [TGAppDelegateInstance saveSettings];
        }
        else if (switchItem == _topPeersItem)
        {
            if (_toggleRecentPeersDisposable == nil)
                _toggleRecentPeersDisposable = [[SMetaDisposable alloc] init];
            
            if (!switchItem.isOn) {
                [switchItem setIsOn:true animated:true];
                
                TGActionSheetAction *proceedAction = [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Privacy.TopPeersDelete") action:@"proceed" type:TGActionSheetActionTypeDestructive];
                TGActionSheetAction *cancelAction = [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel];
                [[[TGCustomActionSheet alloc] initWithTitle:TGLocalized(@"Privacy.TopPeersWarning") actions:@[proceedAction, cancelAction] actionBlock:^(TGPrivateDataSettingsController *target, NSString *action)
                  {
                      if ([action isEqualToString:@"proceed"]) {
                          [target->_topPeersItem setIsOn:false animated:true];
                          [target->_toggleRecentPeersDisposable setDisposable:[[TGRecentPeersSignals toggleRecentPeersEnabled:false] startWithNext:nil]];
                      }
                  } target:self] showInView:self.view];
            } else {
                [_toggleRecentPeersDisposable setDisposable:[[TGRecentPeersSignals toggleRecentPeersEnabled:true] startWithNext:nil]];
            }
        }
    }
}

- (void)clearPaymentsDataWithShipping:(bool)shipping payment:(bool)payment {
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [progressWindow show:true];
    
    TLRPCpayments_clearSavedInfo$payments_clearSavedInfo *clearSavedInfo = [[TLRPCpayments_clearSavedInfo$payments_clearSavedInfo alloc] init];
    if (shipping) {
        clearSavedInfo.flags |= (1 << 1);
    }
    if (payment) {
        clearSavedInfo.flags |= (1 << 0);
    }
    
    [[[[[TGTelegramNetworking instance] requestSignal:clearSavedInfo] deliverOn:[SQueue mainQueue]] onDispose:^ {
        TGDispatchOnMainThread(^{
            [progressWindow dismissWithSuccess];
        });
    }] startWithNext:nil];
}

- (void)clearPaymentsPressed {
    [_attachmentSheetWindow dismissAnimated:true completion:nil];
    
    __weak TGPrivateDataSettingsController *weakSelf = self;
    _attachmentSheetWindow = [[TGShareSheetWindow alloc] init];
    _attachmentSheetWindow.dismissalBlock = ^
    {
        __strong TGPrivateDataSettingsController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_attachmentSheetWindow.rootViewController = nil;
        strongSelf->_attachmentSheetWindow = nil;
    };
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    NSMutableSet *checkedTypes = [[NSMutableSet alloc] initWithArray:@[@(0), @(1)]];
    
    TGShareSheetButtonItemView *clearButtonItem = [[TGShareSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Cache.ClearNone") pressed:^
                                                   {
                                                       __strong TGPrivateDataSettingsController *strongSelf = weakSelf;
                                                       if (strongSelf != nil) {
                                                           [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
                                                           strongSelf->_attachmentSheetWindow = nil;
                                                           
                                                           [strongSelf clearPaymentsDataWithShipping:[checkedTypes containsObject:@1] payment:[checkedTypes containsObject:@0]];
                                                       }
                                                   }];
    
    void (^updateCheckedTypes)() = ^{
        [clearButtonItem setEnabled:checkedTypes.count != 0];
        /*[evaluatedSizeByType enumerateKeysAndObjectsUsingBlock:^(NSNumber *nType, NSNumber *nSize, __unused BOOL *stop) {
         if ([checkedTypes containsObject:nType]) {
         totalSize += [nSize longLongValue];
         }
         }];
         if (totalSize > 0) {
         [clearButtonItem setTitle:[[NSString alloc] initWithFormat:TGLocalized(@"Cache.Clear"), [TGStringUtils stringForFileSize:totalSize]]];
         //[clearButtonItem setDisabled:false];
         } else {
         [clearButtonItem setTitle:TGLocalized(@"Cache.ClearNone")];
         //[clearButtonItem setDisabled:true];
         }*/
    };
    
    updateCheckedTypes();
    
    NSArray *possibleTypes = @[@0, @1];
    NSDictionary *typeTitles = @{@0: TGLocalized(@"Privacy.PaymentsClear.PaymentInfo"), @1: TGLocalized(@"Privacy.PaymentsClear.ShippingInfo")};
    
    for (NSNumber *nType in possibleTypes) {
        TGAttachmentSheetCheckmarkVariantItemView *itemView = [[TGAttachmentSheetCheckmarkVariantItemView alloc] initWithTitle:typeTitles[nType] variant:@"" checked:true];
        itemView.onCheckedChanged = ^(bool value) {
            if (value) {
                [checkedTypes addObject:nType];
            } else {
                [checkedTypes removeObject:nType];
            }
            updateCheckedTypes();
        };
        [items addObject:itemView];
    }
    
    [items addObject:clearButtonItem];
    
    _attachmentSheetWindow.view.cancel = ^{
        __strong TGPrivateDataSettingsController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
            strongSelf->_attachmentSheetWindow = nil;
        }
    };
    
    _attachmentSheetWindow.view.items = items;
    [_attachmentSheetWindow showAnimated:true completion:nil];
}

- (void)resetContactsPressed
{
    [TGCustomAlertView presentAlertWithTitle:TGLocalized(@"Privacy.ContactsReset") message:TGLocalized(@"Privacy.ContactsResetConfirmation") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.Delete") destructive:true completionBlock:^(bool okButtonPressed)
     {
         if (okButtonPressed)
             [self doDeleteContacts];
     } disableKeyboardWorkaround:false];
}

- (void)doDeleteContacts
{
    _syncContactsItem.isOn = false;
    TGAppDelegateInstance.contactsInhibitSync = true;
    [TGAppDelegateInstance saveSettings];
    
    NSArray *contacts = [TGDatabaseInstance() loadContactUsers];
    NSMutableArray *removeActions = [[NSMutableArray alloc] init];
    for (TGUser *user in contacts)
    {
        [removeActions addObject:[[TGRemoveContactFutureAction alloc] initWithUid:user.uid]];
    }
    
    if (removeActions.count > 0)
    {
        [TGDatabaseInstance() storeFutureActions:removeActions];
        [ActionStageInstance() requestActor:@"/tg/synchronizeContacts/(removeAndExport)" options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithBool:false], @"signalSynchronizationCompleted", nil] watcher:TGTelegraphInstance];
    }
    
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow show:true];
    
    [[[[TGTelegramNetworking instance] requestSignal:[[TLRPCcontacts_resetSaved$contacts_resetSaved alloc] init]] deliverOn:[SQueue mainQueue]] startWithNext:nil completed:^
     {
         [progressWindow dismissWithSuccess];
     }];
}

- (void)deleteDraftsPressed
{
    __weak TGPrivateDataSettingsController *weakSelf = self;
    TGMenuSheetController *controller = [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
    controller.dismissesByOutsideTap = true;
    controller.hasSwipeGesture = true;
    controller.narrowInLandscape = true;
    controller.permittedArrowDirections = UIPopoverArrowDirectionAny;
    controller.sourceRect = ^CGRect
    {
        __strong TGPrivateDataSettingsController *strongSelf = weakSelf;
        if (strongSelf != nil)
            return [strongSelf->_deleteDraftsItem.view convertRect:strongSelf->_deleteDraftsItem.view.bounds toView:strongSelf.view];
        return CGRectZero;
    };
    
    __weak TGMenuSheetController *weakController = controller;
    TGMenuSheetButtonItemView *deleteItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Delete") type:TGMenuSheetButtonTypeDestructive action:^
                                             {
                                                 __strong TGMenuSheetController *strongController = weakController;
                                                 if (strongController == nil)
                                                     return;
                                                 
                                                 [strongController dismissAnimated:true manual:true];
                                                 
                                                 __strong TGPrivateDataSettingsController *strongSelf = weakSelf;
                                                 if (strongSelf != nil)
                                                     [strongSelf performDeleteDrafts];
                                             }];
    
    TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
                                             {
                                                 __strong TGMenuSheetController *strongController = weakController;
                                                 if (strongController == nil)
                                                     return;
                                                 
                                                 [strongController dismissAnimated:true manual:true];
                                             }];
    
    [controller setItemViews:@[  deleteItem, cancelItem ]];
    
    [controller presentInViewController:self sourceView:self.view animated:true];
}

- (void)performDeleteDrafts
{
    if (_deleteDraftsDisposable == nil)
        _deleteDraftsDisposable = [[SMetaDisposable alloc] init];
    
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [progressWindow show:true];
    
    [_deleteDraftsDisposable setDisposable:[[[[TGGroupManagementSignals clearAllMessageDrafts] deliverOn:[SQueue mainQueue]] onDispose:^{
        TGDispatchOnMainThread(^{
            [progressWindow dismiss:true];
        });
    }] startWithNext:nil]];
}

@end
