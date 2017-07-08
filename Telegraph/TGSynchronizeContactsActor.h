/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGActor.h"

#import "ASWatcher.h"

#import "TGTelegraphProtocols.h"

typedef enum {
    TGContactListSortOrderFirst = 1,
    TGContactListSortOrderLast = 2,
    TGContactListSortOrderDisplayFirstFirst = 4,
    TGContactListSortOrderDisplayLastFirst = 8
} TGContactListSortOrder;

typedef enum {
    TGPhonebookAccessStatusUnknown = 0,
    TGPhonebookAccessStatusEnabled = 1,
    TGPhonebookAccessStatusDisabled = 2
} TGPhonebookAccessStatus;

@interface TGSynchronizeContactsManager : NSObject

@property (nonatomic) int sortOrder;
@property (nonatomic) TGPhonebookAccessStatus phonebookAccessStatus;
@property (nonatomic) bool contactsSynchronizationStatus;
@property (nonatomic) bool removeAndExportActionsRunning;

+ (TGSynchronizeContactsManager *)instance;

+ (NSArray *)phoneLabels;
+ (NSArray *)customPhoneLabels;

- (void)scheduleContactPhoneAddition:(int32_t)userId;
- (void)clearState;

@end

@interface TGImportedPhone : NSObject

@property (nonatomic, strong) NSString *phone;
@property (nonatomic) int user_id;

@end

@interface TGSynchronizeContactsActor : TGActor <TGContactDeleteActorProtocol, ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

- (void)deleteContactsSuccess:(NSArray *)uids;
- (void)deleteContactsFailed:(NSArray *)uids;

- (void)exportContactsSuccess:(NSArray *)importedPhonesArray popularContacts:(NSArray *)popularContacts users:(NSArray *)users;
- (void)exportContactsFailed;

- (void)contactIdsRequestSuccess:(NSArray *)contactIds;
- (void)contactIdsRequestFailed;

- (void)contactListRequestSuccess:(TLcontacts_Contacts *)result;
- (void)contactListRequestFailed;

@end
