/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "ActionStage.h"

#import "TGViewController.h"

#import "TGUser.h"

typedef enum {
    TGContactsModeRegistered = 1,
    TGContactsModePhonebook = 2,
    TGContactsModeSearchDisabled = 4,
    TGContactsModeMainContacts = 8,
    TGContactsModeInvite = 16 | 2,
    TGContactsModeSelectModal = 32,
    TGContactsModeShowSelf = 64,
    TGContactsModeClearSelectionImmediately = 128,
    TGContactsModeCompose = 256 | 1 | 4,
    TGContactsModeModalInvite = 512 | 16 | 2,
    TGContactsModeModalInviteWithBack = 1024 | 512 | 16 | 2,
    TGContactsModeCreateGroupOption = 2048,
    TGContactsModeCombineSections = 4096,
    TGContactsModeManualFirstSection = 8192,
    TGContactsModeCreateGroupLink = (2 << 14),
    TGContactsModeSortByLastSeen = (2 << 15),
    TGContactsModeIgnorePrivateBots = (2 << 16),
    TGContactsModeSearchGlobal = (2 << 17),
    TGContactsModeIgnoreBots = (2 << 18),
    TGContactsModeCalls = (2 << 19),
    TGContactsModeSortByImporters = (2 << 20)
} TGContactsMode;

@interface TGContactsController : TGViewController <TGViewControllerNavigationBarAppearance, ASWatcher>

@property (nonatomic) bool loginStyle;

@property (nonatomic, strong, readonly) ASHandle *actionHandle;
@property (nonatomic, strong) ASHandle *watcherHandle;

@property (nonatomic) int contactListVersion;
@property (nonatomic) int phonebookVersion;

@property (nonatomic) bool drawFakeNavigationBar;

@property (nonatomic, strong) NSString *customTitle;

@property (nonatomic, readonly) int contactsMode;
@property (nonatomic) int usersSelectedLimit;
@property (nonatomic, strong) NSString *usersSelectedLimitAlert;

@property (nonatomic, strong) NSArray *disabledUsers;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSString *composePlaceholder;

@property (nonatomic) bool deselectAutomatically;
@property (nonatomic) bool ignoreBots;

@property (nonatomic, assign) bool shouldOpenSearch;

- (id)initWithContactsMode:(int)contactsMode;

- (void)clearData;

- (void)deselectRow;

- (int)selectedContactsCount;
- (NSArray *)selectedComposeUsers;
- (NSArray *)selectedContactsList;
- (void)setUsersSelected:(NSArray *)users selected:(NSArray *)selected callback:(bool)callback;
- (void)contactSelected:(TGUser *)user;
- (void)contactDeselected:(TGUser *)user;
- (void)actionItemSelected;
- (void)encryptionItemSelected;
- (void)channelsItemSelected;
- (void)channelGroupItemSelected;
- (void)singleUserSelected:(TGUser *)user;

- (void)contactActionButtonPressed:(TGUser *)user;

- (void)deleteUserFromList:(int)uid;

- (CGFloat)itemHeightForFirstSection;
- (NSInteger)numberOfRowsInFirstSection;
- (UITableViewCell *)cellForRowInFirstSection:(NSInteger)row;
- (void)didSelectRowInFirstSection:(NSInteger)row;
- (bool)shouldDisplaySectionIndices;
- (void)commitDeleteItemInFirstSection:(NSInteger)row;

@end
