#import "TGSynchronizeContactsActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGTelegraph.h"
#import "TGPhoneUtils.h"

#import <AddressBook/AddressBook.h>

#import "NSObject+TGLock.h"

#import "TGDatabase.h"
#import "TGStringUtils.h"

#import "TGContactListRequestBuilder.h"
#import "TGUserDataRequestBuilder.h"

#import "TGAppDelegate.h"

#import "TGUser+Telegraph.h"

#import "TGAlertView.h"

#include <set>
#include <algorithm>

#import <CommonCrypto/CommonDigest.h>

#if TARGET_IPHONE_SIMULATOR

@interface TGRequestAddressBookAccessWithCompletionProxy : NSObject <UIAlertViewDelegate>

@property (nonatomic, copy) void (^completion)(bool granted);

@end

@implementation TGRequestAddressBookAccessWithCompletionProxy

@synthesize completion = _completion;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex)
    {
        if (_completion)
            _completion(false);
    }
    else
    {
        if (_completion)
            _completion(true);
    }
}

@end

void TGRequestAddressBookAccessWithCompletion(__unused ABAddressBookRef addressBook, ABAddressBookRequestAccessCompletionHandler completion)
{
    if (true && iosMajorVersion() >= 7)
    {
#if TARGET_IPHONE_SIMULATOR && false
        dispatch_async(dispatch_get_main_queue(), ^
        {
            completion(false, NULL);
        });
#else
        ABAddressBookRequestAccessWithCompletion(addressBook, completion);
#endif
    }
    else
    {
        static int forceResult = 1;
        
        static bool alreadyRequested = false;
        static bool cachedGranted = false;
        if (!alreadyRequested)
        {
            alreadyRequested = true;
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                static TGRequestAddressBookAccessWithCompletionProxy *proxy = [[TGRequestAddressBookAccessWithCompletionProxy alloc] init];
                proxy.completion = ^(bool granted)
                {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                    {
                        cachedGranted = granted;
                        completion(granted, NULL);
                    });
                };
                
                if (forceResult != 0)
                {
                    proxy.completion(forceResult == 1);
                }
                else
                {
                    TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:@"Enable phonebook access?" delegate:proxy cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                    [alertView show];
                }
            });
        }
        else
        {
            completion(cachedGranted, NULL);
        }
    }
}
#else
#define TGRequestAddressBookAccessWithCompletion ABAddressBookRequestAccessWithCompletion
#endif

static NSDictionary *localizedPhoneLabelToNativeLabel()
{
    static NSDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSMutableDictionary *labelMap = [[NSMutableDictionary alloc] init];
        
        [labelMap setObject:(__bridge NSString *)kABPersonPhoneMobileLabel forKey:(__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(kABPersonPhoneMobileLabel)];
        [labelMap setObject:(__bridge NSString *)kABPersonPhoneIPhoneLabel forKey:(__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(kABPersonPhoneIPhoneLabel)];
        [labelMap setObject:@"_$!<Home>!$_" forKey:(__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(CFSTR("_$!<Home>!$_"))];
        [labelMap setObject:@"_$!<Work>!$_" forKey:(__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(CFSTR("_$!<Work>!$_"))];
        [labelMap setObject:(__bridge NSString *)kABPersonPhoneMainLabel forKey:(__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(kABPersonPhoneMainLabel)];
        [labelMap setObject:(__bridge NSString *)kABPersonPhoneHomeFAXLabel forKey:(__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(kABPersonPhoneHomeFAXLabel)];
        [labelMap setObject:(__bridge NSString *)kABPersonPhoneWorkFAXLabel forKey:(__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(kABPersonPhoneWorkFAXLabel)];
        if (kABPersonPhoneOtherFAXLabel != NULL)
        {
            [labelMap setObject:(__bridge NSString *)kABPersonPhoneOtherFAXLabel forKey:(__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(kABPersonPhoneOtherFAXLabel)];
        }
        [labelMap setObject:(__bridge NSString *)kABPersonPhonePagerLabel forKey:(__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(kABPersonPhonePagerLabel)];
        [labelMap setObject:@"_$!<Other>!$_" forKey:(__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(CFSTR("_$!<Other>!$_"))];
        
        dict = labelMap;
    });
    
    return dict;
}

static NSString *nativePhoneLabelForString(NSString *string)
{
    if (string == nil)
        return @"";
    NSString *nativeLabel = [localizedPhoneLabelToNativeLabel() objectForKey:string];
    if (nativeLabel != nil)
        return nativeLabel;
    return string;
}

@class TGSynchronizeContactsManager;
static TGSynchronizeContactsManager *TGSynchronizeContactsManagerInstance = nil;

static const char *addressBookQueueSpecific = "addressBookQueue";

static std::map<int, int> lastPersonModificationDates;

typedef void (^TGAddressBookCreated)(ABAddressBookRef addressBook, bool denied);

@interface TGSynchronizeContactsManager ()
{
    volatile bool _localSynchronizationPending;
    TG_SYNCHRONIZED_DEFINE(_localSynchronizationPending);
    
    std::set<int32_t> _contactPhoneAdditionPending;
    TG_SYNCHRONIZED_DEFINE(_contactPhoneAdditionPending);
}

@property (nonatomic) bool firstTimeSync;

@end

@implementation TGSynchronizeContactsManager

static void TGAddressBookChanged(__unused ABAddressBookRef addressBook, __unused CFDictionaryRef info, __unused void *context)
{
    //TGLog(@"Notify AB %x", (int)addressBook);
    [[TGSynchronizeContactsManager instance] addressBookChanged];
}

static void CreateAddressBookAsync(TGAddressBookCreated createdBlock)
{
    static volatile bool singletonInitialized = false;
    
    static ABAddressBookRef singleton = NULL;
    static bool singletonDenied = false;
    
    static NSMutableArray *resultListeners = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {   
        resultListeners = [[NSMutableArray alloc] init];
    });
    
    [[TGSynchronizeContactsManager instance] dispatchOnAddressBookQueue:^
    {
        if (singletonInitialized)
        {
            if (singleton != NULL)
                ABAddressBookRevert(singleton);
            
            createdBlock(singleton, singletonDenied);
            
            return;
        }
        else
        {
            [resultListeners addObject:createdBlock];
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                [[TGSynchronizeContactsManager instance] dispatchOnAddressBookQueue:^
                {
                    CFErrorRef error = nil;
                    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
                    TGRequestAddressBookAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                    {
                        [[TGSynchronizeContactsManager instance] dispatchOnAddressBookQueue:^
                        {
                            NSMutableArray *listeners = [[NSMutableArray alloc] init];
                            [listeners addObjectsFromArray:resultListeners];
                            [resultListeners removeAllObjects];
                            
                            if (error)
                            {
                                [TGSynchronizeContactsManager instance].phonebookAccessStatus = TGPhonebookAccessStatusUnknown;
                                
                                for (TGAddressBookCreated listener in listeners)
                                    listener(NULL, false);
                            }
                            else if (!granted)
                            {
                                [TGSynchronizeContactsManager instance].phonebookAccessStatus = TGPhonebookAccessStatusDisabled;
                                
                                singletonInitialized = true;
                                singletonDenied = true;
                                singleton = NULL;
                                
                                for (TGAddressBookCreated listener in listeners)
                                    listener(NULL, true);
                            }
                            else
                            {
                                [TGSynchronizeContactsManager instance].phonebookAccessStatus = TGPhonebookAccessStatusEnabled;
                                
                                [[TGSynchronizeContactsManager instance] updateSortOrder];
                                
                                singletonInitialized = true;
                                singletonDenied = false;
                                singleton = addressBook;
                                
                                dispatch_async(dispatch_get_main_queue(), ^
                                {
                                    ABAddressBookRegisterExternalChangeCallback(singleton, &TGAddressBookChanged, NULL);
                                    
                                    [[TGSynchronizeContactsManager instance] dispatchOnAddressBookQueue:^
                                    {
                                        ABAddressBookRevert(singleton);
                                        for (TGAddressBookCreated listener in listeners)
                                            listener(addressBook, false);
                                    }];
                                });
                            }
                        }];
                    });
                }];
            });
        }
    }];
}

+ (TGSynchronizeContactsManager *)instance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        TGSynchronizeContactsManagerInstance = [[TGSynchronizeContactsManager alloc] init];
    });
    
    return TGSynchronizeContactsManagerInstance;
}

+ (NSArray *)phoneLabels
{
    static NSArray *array = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSMutableArray *labels = [[NSMutableArray alloc] init];
        
        [labels addObject:(__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(kABPersonPhoneMobileLabel)];
        [labels addObject:(__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(kABPersonPhoneIPhoneLabel)];
        [labels addObject:(__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(CFSTR("_$!<Home>!$_"))];
        [labels addObject:(__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(CFSTR("_$!<Work>!$_"))];
        [labels addObject:(__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(kABPersonPhoneMainLabel)];
        [labels addObject:(__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(kABPersonPhoneHomeFAXLabel)];
        [labels addObject:(__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(kABPersonPhoneWorkFAXLabel)];
        if (kABPersonPhoneOtherFAXLabel != NULL)
            [labels addObject:(__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(kABPersonPhoneOtherFAXLabel)];
        [labels addObject:(__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(kABPersonPhonePagerLabel)];
        [labels addObject:(__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(CFSTR("_$!<Other>!$_"))];
        
        array = labels;
    });
    
    return array;
}

+ (NSArray *)customPhoneLabels
{
    return nil;
}

- (void)clearState
{
    _firstTimeSync = true;
    [self dispatchOnAddressBookQueue:^
    {
        lastPersonModificationDates.clear();
    }];
    [TGDatabaseInstance() setContactListPreloaded:false];
    
    TG_SYNCHRONIZED_BEGIN(_contactPhoneAdditionPending)
    _contactPhoneAdditionPending.clear();
    TG_SYNCHRONIZED_END(_contactPhoneAdditionPending)
}

- (void)scheduleContactPhoneAddition:(int32_t)userId
{
    TG_SYNCHRONIZED_BEGIN(_contactPhoneAdditionPending)
    _contactPhoneAdditionPending.insert(userId);
    TG_SYNCHRONIZED_END(_contactPhoneAdditionPending)
}

- (void)clearScheduledContactAddition:(int32_t)userId
{
    TG_SYNCHRONIZED_BEGIN(_contactPhoneAdditionPending)
    _contactPhoneAdditionPending.erase(userId);
    TG_SYNCHRONIZED_END(_contactPhoneAdditionPending)
}

- (bool)isContactAdditionScheduled:(int32_t)userId
{
    TG_SYNCHRONIZED_BEGIN(_contactPhoneAdditionPending)
    bool result = _contactPhoneAdditionPending.find(userId) != _contactPhoneAdditionPending.end();
    TG_SYNCHRONIZED_END(_contactPhoneAdditionPending)
    return result;
}

- (void)setContactsSynchronizationStatus:(bool)contactsSynchronizationStatus
{
    if (contactsSynchronizationStatus != _contactsSynchronizationStatus)
    {
        _contactsSynchronizationStatus = contactsSynchronizationStatus;
        
        [ActionStageInstance() dispatchResource:@"/tg/contactListSynchronizationState" resource:[[SGraphObjectNode alloc] initWithObject:[[NSNumber alloc] initWithBool:_contactsSynchronizationStatus]]];
    }
}

- (void)setRemoveAndExportActionsRunning:(bool)removeAndExportActionsRunning
{
    if (removeAndExportActionsRunning != _removeAndExportActionsRunning)
    {
        _removeAndExportActionsRunning = removeAndExportActionsRunning;
        
        [ActionStageInstance() dispatchResource:@"/tg/removeAndExportActionsRunning" resource:[[SGraphObjectNode alloc] initWithObject:[[NSNumber alloc] initWithBool:_removeAndExportActionsRunning]]];
    }
}

- (void)setPhonebookAccessStatus:(TGPhonebookAccessStatus)phonebookAccessStatus
{
    if (_phonebookAccessStatus != phonebookAccessStatus)
    {
        _phonebookAccessStatus = phonebookAccessStatus;
        
        [ActionStageInstance() dispatchResource:@"/tg/phonebookAccessStatus" resource:nil];
    }
}

- (dispatch_queue_t)addressBookQueue
{
    static dispatch_queue_t addressBookQueue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        addressBookQueue = dispatch_queue_create("ph.telegra.addressbook", 0);
        dispatch_queue_set_specific(addressBookQueue, addressBookQueueSpecific, (void *)addressBookQueueSpecific, NULL);
    });
    
    return addressBookQueue;
}

- (bool)isCurrentQueueAddressBookQueue
{
    return dispatch_get_specific(addressBookQueueSpecific) != NULL;
}

- (void)dispatchOnAddressBookQueue:(dispatch_block_t)block
{
    if ([self isCurrentQueueAddressBookQueue])
    {
        block();
    }
    else
    {
        dispatch_async([self addressBookQueue], ^
        {
            block();
        });
    }
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _localSynchronizationPending = false;
        TG_SYNCHRONIZED_INIT(_localSynchronizationPending);
        
        _firstTimeSync = true;
        
        int localSortOrder = 0;
        if (ABPersonGetSortOrdering() == kABPersonSortByFirstName)
            localSortOrder |= TGContactListSortOrderFirst;
        else
            localSortOrder |= TGContactListSortOrderLast;
        
        if (ABPersonGetCompositeNameFormat() == kABPersonCompositeNameFormatFirstNameFirst)
            localSortOrder |= TGContactListSortOrderDisplayFirstFirst;
        else
            localSortOrder |= TGContactListSortOrderDisplayLastFirst;
        
        _sortOrder = localSortOrder;
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        });
    }
    return self;
}

- (void)applicationWillEnterForeground:(NSNotification *)__unused notification
{
    [self updateSortOrder];
}

- (void)updateSortOrder
{
    int localSortOrder = 0;
    if (ABPersonGetSortOrdering() == kABPersonSortByFirstName)
        localSortOrder |= TGContactListSortOrderFirst;
    else
        localSortOrder |= TGContactListSortOrderLast;
    
    if (ABPersonGetCompositeNameFormat() == kABPersonCompositeNameFormatFirstNameFirst)
        localSortOrder |= TGContactListSortOrderDisplayFirstFirst;
    else
        localSortOrder |= TGContactListSortOrderDisplayLastFirst;
    
    if (localSortOrder != _sortOrder)
    {
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            _sortOrder = localSortOrder;
            [TGContactListRequestBuilder dispatchNewContactList];
            [TGContactListRequestBuilder dispatchNewPhonebook];
        }];
    }
}

- (void)addressBookChanged
{
    if (TGTelegraphInstance.clientUserId == 0)
        return;
    
    bool executeSync = false;
    
    TG_SYNCHRONIZED_BEGIN(_localSynchronizationPending);
    if (!_localSynchronizationPending)
    {
        _localSynchronizationPending = true;
        executeSync = true;
    }
    TG_SYNCHRONIZED_END(_localSynchronizationPending);
    
    if (executeSync)
    {
        TGDispatchAfter(0.5, dispatch_get_main_queue(), ^
        {
            static int actionId = 0;
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/synchronizeContacts/(%d,local)", actionId++] options:nil watcher:TGTelegraphInstance];
        });
    }
    else
    {
        TGLog(@"Skipping address book change");
    }
}

- (void)addressBookChangeCommitted
{
    TG_SYNCHRONIZED_BEGIN(_localSynchronizationPending);
    _localSynchronizationPending = false;
    TG_SYNCHRONIZED_END(_localSynchronizationPending);
}

@end

@implementation TGImportedPhone

@end

#pragma mark -

@interface TGSynchronizeContactsActor ()

@property (nonatomic, strong) NSArray *currentActionIds;

@property (nonatomic) bool signalSynchronizationCompleted;

@property (nonatomic) bool hadRemoteContacts;

@end

@implementation TGSynchronizeContactsActor

+ (NSString *)genericPath
{
    return @"/tg/synchronizeContacts/@";
}

- (id)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)cancel
{
    [ActionStageInstance() removeWatcher:self];
    
    [super cancel];
}

- (void)prepare:(NSDictionary *)__unused options
{
    if ([self.path hasSuffix:@"removeAndExport)"] || [self.path hasSuffix:@"loadRemote)"] || [self.path hasSuffix:@"importLink)"] || [self.path hasSuffix:@"breakLink)"] || [self.path hasSuffix:@"appendPhone)"])
        self.requestQueueName = @"contacts";
    else if ([self.path hasSuffix:@"breakLinkLocal)"] || [self.path hasSuffix:@"changeNameLocal)"] || [self.path hasSuffix:@"changePhonesLocal)"] || [self.path hasSuffix:@"addContactLocal)"])
        self.requestQueueName = nil;
    else
        self.requestQueueName = @"contactsSync";
    
    _signalSynchronizationCompleted = [[options objectForKey:@"signalSynchronizationCompleted"] boolValue];
}

- (void)execute:(NSDictionary *)options
{
    TGLog(@"sync contacts %@: execute with %@", self.path, options);
    if ([self.path hasSuffix:@"removeAndExport)"])
    {
        [[TGSynchronizeContactsManager instance] setRemoveAndExportActionsRunning:true];
        
        [self processRemoveAndExportActions];
        
        return;
    }
    else if ([self.path hasSuffix:@"importLink)"])
    {
        TGUser *user = [options objectForKey:@"user"];
        if (user == nil || user.phoneNumber.length == 0)
            [self completeAction:false];
        else
            [self processAddContact:user];
        
        return;
    }
    else if ([self.path hasSuffix:@"breakLink)"])
    {
        int uid = [[options objectForKey:@"uid"] intValue];
        int phoneId = [TGDatabaseInstance() loadCachedPhoneIdByUid:uid];
        
        if (uid != 0 && phoneId != 0)
            [self processRemoveContact:uid byPhoneId:phoneId];
        else
            [self completeAction:false];
        
        return;
    }
    else if ([self.path hasSuffix:@"breakLinkLocal)"])
    {
        int uid = [[options objectForKey:@"uid"] intValue];
        int nativeId = [[options objectForKey:@"nativeId"] intValue];
        
        if (uid != 0 && nativeId != 0)
            [self processRemoveContact:uid byNativeId:nativeId];
        else
            [self completeAction:false];
        
        return;
    }
    else if ([self.path hasSuffix:@"appendPhone)"])
    {
        int uid = [[options objectForKey:@"uid"] intValue];
        int nativeId = [[options objectForKey:@"nativeId"] intValue];
        
        [[TGSynchronizeContactsManager instance] clearScheduledContactAddition:uid];
        
        if (uid != 0 && nativeId != 0)
            [self processAppendContactPhone:uid nativeId:nativeId newPhone:options[@"phoneNumber"]];
        else
            [self completeAction:false];
        
        return;
    }
    else if ([self.path hasSuffix:@"changeNameLocal)"])
    {
        int uid = [[options objectForKey:@"uid"] intValue];
        int nativeId = [[options objectForKey:@"nativeId"] intValue];
        NSString *firstName = [options objectForKey:@"firstName"];
        NSString *lastName = [options objectForKey:@"lastName"];
        
        if (uid != 0 && nativeId != 0)
            [self processChangeContactName:uid nativeId:nativeId changeFirstName:firstName changeLastName:lastName];
        else
            [self completeAction:false];
        
        return;
    }
    else if ([self.path hasSuffix:@"changePhonesLocal)"])
    {
        int uid = [[options objectForKey:@"uid"] intValue];
        int nativeId = [[options objectForKey:@"nativeId"] intValue];
        NSArray *phones = [options objectForKey:@"phones"];
        int addingUid = [[options objectForKey:@"addingUid"] intValue];
        bool removedMainPhone = [[options objectForKey:@"removedMainPhone"] boolValue];
        
        if (nativeId != 0 && phones != nil)
            [self processChangeContactPhones:uid nativeId:nativeId changePhones:phones addingUid:addingUid removedMainPhone:removedMainPhone];
        else
            [self completeAction:false];
        
        return;
    }
    else if ([self.path hasSuffix:@"addContactLocal)"])
    {
        TGPhonebookContact *contact = [options objectForKey:@"contact"];
        if (contact != nil)
        {
            [self processCreateContact:contact uid:[[options objectForKey:@"uid"] intValue]];
        }
        else
            [self completeAction:false];
    }
    else if ([self.path hasSuffix:@"loadRemote)"])
    {
        std::vector<int> contactIds;
        [TGDatabaseInstance() loadRemoteContactUids:contactIds];
        
        NSString *hashString = @"";
        if (!contactIds.empty())
        {
            std::sort(contactIds.begin(), contactIds.end());
            
            NSMutableString *stringToHash = [[NSMutableString alloc] init];
            for (std::vector<int>::iterator it = contactIds.begin(); it != contactIds.end(); it++)
            {
                if (stringToHash.length != 0)
                    [stringToHash appendString:@","];
                [stringToHash appendFormat:@"%d", *it];
            }
        
            NSData *dataToHash = [stringToHash dataUsingEncoding:NSUTF8StringEncoding];
        
            unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
            CC_MD5(dataToHash.bytes, (CC_LONG)dataToHash.length, md5Buffer);
        
            //TGLog(@"%@", stringToHash);
        
            hashString = [[NSString alloc] initWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", md5Buffer[0], md5Buffer[1], md5Buffer[2], md5Buffer[3], md5Buffer[4], md5Buffer[5], md5Buffer[6], md5Buffer[7], md5Buffer[8], md5Buffer[9], md5Buffer[10], md5Buffer[11], md5Buffer[12], md5Buffer[13], md5Buffer[14], md5Buffer[15]];
            //TGLog(@"%@", hashString);
        }
    
        _hadRemoteContacts = !contactIds.empty();
        self.cancelToken = [TGTelegraphInstance doRequestContactList:hashString actor:self];
        
        return;
    }
    
    bool firstTimeSync = [[TGSynchronizeContactsManager instance] firstTimeSync];
    [[TGSynchronizeContactsManager instance] setFirstTimeSync:false];
    
    [[TGSynchronizeContactsManager instance] setContactsSynchronizationStatus:true];
    
    CreateAddressBookAsync(^(ABAddressBookRef addressBook, bool denied)
    {
        if (addressBook == NULL || denied)
        {
            [[TGSynchronizeContactsManager instance] addressBookChangeCommitted];
            
            [TGDatabaseInstance() replaceContactBindings:nil];
            
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                if (firstTimeSync)
                    [TGContactListRequestBuilder dispatchNewContactList];
                [TGContactListRequestBuilder dispatchNewPhonebook];
                
                [ActionStageInstance() requestActor:@"/tg/synchronizeContacts/(removeAndExport)" options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithBool:!firstTimeSync], @"signalSynchronizationCompleted", nil] watcher:TGTelegraphInstance];
                
                if (firstTimeSync)
                    [ActionStageInstance() requestActor:@"/tg/synchronizeContacts/(loadRemote)" options:nil watcher:TGTelegraphInstance];
                else
                    [[TGSynchronizeContactsManager instance] setContactsSynchronizationStatus:false];
                
                [self completeAction:true];
            }];
            
            return;
        }
        
        /*if (false)
        {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                NSArray *alphabet = [@"а б в г д е ж з и к л м н о п р с т у ф х ц ч ш щ ъ ы ь э ю я" componentsSeparatedByString:@" "];
                NSString *label = [[TGSynchronizeContactsManager phoneLabels] firstObject];
                
                CFErrorRef error = NULL;
                
                for (int i = 0; i < 10000; i++)
                {
                    ABRecordRef newPerson = ABPersonCreate();
                    
                    int32_t firstNameLength = 6 + arc4random_uniform(6);
                    int32_t lastNameLength = 7 + arc4random_uniform(6);
                    NSMutableString *firstName = [[NSMutableString alloc] init];
                    NSMutableString *lastName = [[NSMutableString alloc] init];
                    
                    for (int j = 0; j < firstNameLength; j++)
                    {
                        NSString *letter = alphabet[arc4random_uniform((u_int32_t)alphabet.count)];
                        if (j == 0)
                            letter = [letter capitalizedString];
                        [firstName appendString:letter];
                    }
                    
                    for (int j = 0; j < lastNameLength; j++)
                    {
                        NSString *letter = alphabet[arc4random_uniform((u_int32_t)alphabet.count)];
                        if (j == 0)
                            letter = [letter capitalizedString];
                        [lastName appendString:letter];
                    }
                    
                    ABRecordSetValue(newPerson, kABPersonFirstNameProperty, (__bridge CFTypeRef)(firstName), &error);
                    ABRecordSetValue(newPerson, kABPersonLastNameProperty, (__bridge CFTypeRef)(lastName), &error);
                    
                    ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
                    
                    NSMutableString *number = [[NSMutableString alloc] initWithString:@"+7"];
                    for (int j = 0; j < 10; j++)
                    {
                        [number appendFormat:@"%d", (int)arc4random_uniform(10)];
                    }
                    TGPhoneNumber *phoneNumber = [[TGPhoneNumber alloc] initWithLabel:label number:number];
                    NSString *phoneLabel = nativePhoneLabelForString(phoneNumber.label);
                    
                    ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)phoneNumber.number, (__bridge CFStringRef)phoneLabel, NULL);
                    
                    ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone, nil);
                    CFRelease(multiPhone);
                    
                    ABAddressBookAddRecord(addressBook, newPerson, &error);
                    
                    CFRelease(newPerson);
                }
                
                ABAddressBookSave(addressBook, &error);
                if (error != NULL)
                {
                    CFStringRef errorDesc = CFErrorCopyDescription(error);
                    NSLog(@"Contact not saved: %@", errorDesc);
                    CFRelease(errorDesc);
                }
            });
        }*/
        
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        
        CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
        [[TGSynchronizeContactsManager instance] addressBookChangeCommitted];
        
        std::set<int> currentPhonebookPhoneIdsSet;
        std::map<int, TGContactBinding *> currentBindings;
        
        for (TGContactBinding *binding in [TGDatabaseInstance() contactBindings])
        {
            int phoneId = binding.phoneId;
            if (binding.phoneNumber.length != 0)
                currentBindings.insert(std::pair<int, TGContactBinding *>(murMurHash32(binding.phoneNumber), binding));
            currentPhonebookPhoneIdsSet.insert(phoneId);
        }
        
        int count = (int)CFArrayGetCount(people);
        
        NSMutableArray *newBindings = [[NSMutableArray alloc] initWithCapacity:count];
        NSMutableArray *newPhonebookContacts = [[NSMutableArray alloc] initWithCapacity:count];
        
        std::set<int> newPhonebookPhoneIdSet;
        
        std::map<int, TGContactBinding *> changedBindings;
        
        NSMutableData *newPhonebookState = [[NSMutableData alloc] initWithCapacity:count * 4];
        NSMutableData *newExportState = [[NSMutableData alloc] initWithCapacity:count * 4];
        
        std::map<int, int> newExportIdToPhoneId;
        
        NSArray *users = [TGDatabaseInstance() loadContactUsers];
        std::map<int, TGUser *> usersMap;
        for (TGUser *user in users)
        {
            if (user.contactId != 0)
                usersMap.insert(std::pair<int, TGUser *>(user.contactId, user));
        }
        
        std::set<int> explicitExport;
        
        for (CFIndex i = 0; i < count; i++)
        {
            ABRecordRef person = CFArrayGetValueAtIndex(people, i);
            int nativeId = ABRecordGetRecordID(person);
            
            NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
            
            if (firstName == nil)
                firstName = @"";
            if (lastName == nil)
                lastName = @"";
            
            if (firstName.length == 0 && lastName.length == 0)
            {
                lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty);
                if (lastName == nil)
                    lastName = @"";
            }
            
            TGPhonebookContact *phonebookContact = [[TGPhonebookContact alloc] init];
            phonebookContact.nativeId = nativeId;
            phonebookContact.firstName = firstName;
            phonebookContact.lastName = lastName;
            
            ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            
            int phoneCount = phones == NULL ? 0 : (int)ABMultiValueGetCount(phones);
            NSMutableArray *personPhones = [[NSMutableArray alloc] initWithCapacity:phoneCount];
            
            NSMutableArray *phonebookContactPhones = [[NSMutableArray alloc] initWithCapacity:phoneCount];
            
            for (CFIndex j = 0; j < phoneCount; j++)
            {
                NSString *number = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, j);
                NSString *label = nil;
                
                CFStringRef valueLabel = ABMultiValueCopyLabelAtIndex(phones, j);
                if (valueLabel != NULL)
                {
                    label = (__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(valueLabel);
                    CFRelease(valueLabel);
                }
                
                [phonebookContactPhones addObject:[[TGPhoneNumber alloc] initWithLabel:label number:number]];
                
                if (number != nil)
                    number = [TGPhoneUtils cleanPhone:number];
                
                if (number.length != 0)
                    [personPhones addObject:[NSArray arrayWithObjects:label == nil ? @"" : label, number, nil]];
            }
            if (phones != NULL)
                CFRelease(phones);
            
            phonebookContact.phoneNumbers = phonebookContactPhones;
            [newPhonebookContacts addObject:phonebookContact];
            
            if (personPhones.count == 0)
                continue;
            
            int phoneIndex = -1;
            for (NSArray *personPhoneDesc in personPhones)
            {
                phoneIndex++;
                
                NSString *currentPhoneNumber = [personPhoneDesc objectAtIndex:1];
                int phoneId = phoneMatchHash(currentPhoneNumber);
                if (newPhonebookPhoneIdSet.find(phoneId) != newPhonebookPhoneIdSet.end())
                    continue;
                
                newPhonebookPhoneIdSet.insert(phoneId);
                [newPhonebookState appendBytes:&phoneId length:4];
                
                NSString *exportString = [[NSString alloc] initWithFormat:@"%@%@%@", firstName, lastName, currentPhoneNumber];
                int exportId = murMurHash32(exportString);
                [newExportState appendBytes:&exportId length:4];
                
                newExportIdToPhoneId.insert(std::pair<int, int>(exportId, phoneId));
                
                if (usersMap.find(phoneId) == usersMap.end())
                    explicitExport.insert(phoneId);
                
                TGContactBinding *binding = [[TGContactBinding alloc] init];
                binding.phoneId = phoneId;
                
                binding.firstName = firstName;
                binding.lastName = lastName;
                binding.phoneNumber = currentPhoneNumber;
                
                [newBindings addObject:binding];
                
                int bindingHash = murMurHash32(currentPhoneNumber);
                std::map<int, TGContactBinding *>::iterator it = currentBindings.find(bindingHash);
                if (it == currentBindings.end() || ![it->second equalsToContactBinding:binding])
                    changedBindings.insert(std::pair<int, TGContactBinding *>(bindingHash, binding));
            }
        }
        
        for (std::map<int, TGContactBinding *>::iterator it = currentBindings.begin(); it != currentBindings.end(); it++)
        {
            if (newPhonebookPhoneIdSet.find(it->second.phoneId) == newPhonebookPhoneIdSet.end())
                changedBindings.insert(std::pair<int, TGContactBinding *>(it->first, nil));
        }
        
        if (people != NULL)
            CFRelease(people);
        
        std::set<int> contactIdsToLoad;
        for (std::map<int, TGContactBinding *>::iterator it = changedBindings.begin(); it != changedBindings.end(); it++)
        {
            contactIdsToLoad.insert(it->first);
        }
        
        NSMutableArray *userDataToDispatch = [[NSMutableArray alloc] init];
        
        int clientUserId = TGTelegraphInstance.clientUserId;
        
        std::map<int, TGUser *> usersToUpdate;
        [TGDatabaseInstance() loadCachedUsersWithContactIds:contactIdsToLoad resultMap:usersToUpdate];
        for (std::map<int, TGUser *>::iterator it = usersToUpdate.begin(); it != usersToUpdate.end(); it++)
        {
            std::map<int, TGContactBinding *>::iterator contactIt = changedBindings.find(it->first);
            if (contactIt != changedBindings.end())
            {
                TGUser *user = it->second;
                if (user.uid == clientUserId)
                    continue;
                
                TGContactBinding *binding = contactIt->second;
                if (((user.phonebookFirstName != nil) != (binding.firstName != nil) || (user.phonebookFirstName != nil && ![user.phonebookFirstName isEqualToString:binding.firstName])) ||
                    ((user.phonebookLastName != nil) != (binding.lastName != nil) || (user.phonebookLastName != nil && ![user.phonebookLastName isEqualToString:binding.lastName])))
                {
                    user = [it->second copy];
                    user.phonebookFirstName = contactIt->second.firstName;
                    user.phonebookLastName = contactIt->second.lastName;
                    [userDataToDispatch addObject:user];
                }
            }
        }
        
        bool updateContactList = false;
        
        NSData *data = [TGDatabaseInstance() customProperty:@"phonebookState"];
        if (data.length != 0)
        {
            std::set<int> lastPhonebookPhoneIdsSet;
            
            int ptr = 0;
            int length = (int)data.length;
            const uint8_t *dataBytes = (const uint8_t *)data.bytes;
            while (ptr < length)
            {
                int contactId = *((int *)(dataBytes + ptr));
                ptr += 4;
                
                if (contactId != 0)
                    lastPhonebookPhoneIdsSet.insert(contactId);
            }
            
            std::set<int> deletedContactIdsSet;
            std::set_difference(lastPhonebookPhoneIdsSet.begin(), lastPhonebookPhoneIdsSet.end(), newPhonebookPhoneIdSet.begin(), newPhonebookPhoneIdSet.end(), std::inserter(deletedContactIdsSet, deletedContactIdsSet.end()));
            
            bool contactUidToContactIdLoaded = false;
            std::map<int, int> contactUidToContactId;
            
            NSMutableArray *removeContactUids = nil;
            NSMutableArray *newRemoveContactActions = [[NSMutableArray alloc] init];
            
            for (std::set<int>::iterator it = deletedContactIdsSet.begin(); it != deletedContactIdsSet.end(); it++)
            {
                int uid = 0;
                
                std::map<int, TGUser *>::iterator userIt = usersToUpdate.find(*it);
                if (userIt != usersToUpdate.end())
                    uid = userIt->second.uid;
                else
                {
                    if (!contactUidToContactIdLoaded)
                    {
                        contactUidToContactIdLoaded = true;
                        [TGDatabaseInstance() loadRemoteContactUidsContactIds:contactUidToContactId];
                    }
                    
                    std::map<int, int>::iterator contactIdIt = contactUidToContactId.find(*it);
                    if (contactIdIt != contactUidToContactId.end())
                        uid = contactIdIt->second;
                }
                
                if (uid != 0)
                {
                    if (removeContactUids == nil)
                        removeContactUids = [[NSMutableArray alloc] init];
                    
                    [removeContactUids addObject:[[NSNumber alloc] initWithInt:uid]];
                    [newRemoveContactActions addObject:[[TGRemoveContactFutureAction alloc] initWithUid:uid]];
                }
                else
                {
                    TGLog(@"Couldn't resolve deleted contact id %d", *it);
                }
            }
            
            if (newRemoveContactActions.count != 0)
                [TGDatabaseInstance() storeFutureActions:newRemoveContactActions];
            
            if (removeContactUids != nil && removeContactUids.count != 0)
            {
                [TGDatabaseInstance() deleteRemoteContactUids:removeContactUids];
                updateContactList = true;
            }
        }
        [TGDatabaseInstance() setCustomProperty:@"phonebookState" value:newPhonebookState];
        
        std::set<int> lastExportState;
        NSData *lastExportStateData = [TGDatabaseInstance() customProperty:@"exportState"];
        if (lastExportStateData.length != 0)
        {
            const uint8_t *lastExportStateDataBytes = (const uint8_t *)lastExportStateData.bytes;
            int ptr = 0;
            int length = (int)lastExportStateData.length;
            while (ptr < length)
            {
                int exportId = *((int *)(lastExportStateDataBytes + ptr));
                ptr += 4;
                
                if (exportId != 0)
                    lastExportState.insert(exportId);
            }
        }
    
        NSMutableArray *currentExportActions = nil;
        
        for (std::map<int, int>::iterator it = newExportIdToPhoneId.begin(); it != newExportIdToPhoneId.end(); it++)
        {
            if (lastExportState.find(it->first) == lastExportState.end())
            {
                TGLog(@"add contact export action id (%d)", it->second);
                if (currentExportActions == nil)
                    currentExportActions = [[NSMutableArray alloc] init];
                [currentExportActions addObject:[[TGExportContactFutureAction alloc] initWithContactId:it->second]];
                
                explicitExport.erase(it->second);
            }
        }
        
        NSData *completedExplicitExport = [TGDatabaseInstance() customProperty:@"explicitExport"];
        if (completedExplicitExport == nil)
        {
            if (currentExportActions == nil)
                currentExportActions = [[NSMutableArray alloc] init];
            
            for (std::set<int>::iterator it = explicitExport.begin(); it != explicitExport.end(); it++)
            {
                [currentExportActions addObject:[[TGExportContactFutureAction alloc] initWithContactId:*it]];
            }
            
            bool flag = true;
            [TGDatabaseInstance() setCustomProperty:@"explicitExport" value:[NSData dataWithBytes:&flag length:sizeof(bool)]];
        }
        
        if (currentExportActions != nil && currentExportActions.count != 0)
            [TGDatabaseInstance() storeFutureActions:currentExportActions];
        
        [TGDatabaseInstance() setCustomProperty:@"exportState" value:newExportState];
        
        [TGDatabaseInstance() replaceContactBindings:newBindings];
        [TGDatabaseInstance() replacePhonebookContacts:newPhonebookContacts];
        
        TGLog(@"Contacts processed in %f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0);
        
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            if (userDataToDispatch.count != 0)
                [TGContactListRequestBuilder clearCache];
            
            [TGDatabaseInstance() setContactListPreloaded:true];
            [TGUserDataRequestBuilder executeUserObjectsUpdate:userDataToDispatch];
            
            if (updateContactList || firstTimeSync)
                [TGContactListRequestBuilder dispatchNewContactList];
            [TGContactListRequestBuilder dispatchNewPhonebook];
            
            [ActionStageInstance() requestActor:@"/tg/synchronizeContacts/(removeAndExport)" options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithBool:!firstTimeSync], @"signalSynchronizationCompleted", nil] watcher:TGTelegraphInstance];
            
            if (firstTimeSync)
            {
                [ActionStageInstance() requestActor:@"/tg/synchronizeContacts/(loadRemote)" options:nil watcher:TGTelegraphInstance];
                
                [self completeAction:true];
            }
            else
            {
                [self importContacts:^(bool imported)
                {
                    [ActionStageInstance() dispatchOnStageQueue:^
                    {
                        if (imported)
                        {
                            [TGContactListRequestBuilder dispatchNewContactList];
                            [TGContactListRequestBuilder dispatchNewPhonebook];
                        }
                        
                        [[TGSynchronizeContactsManager instance] setContactsSynchronizationStatus:false];
                        
                        [self completeAction:true];
                    }];
                }];
            }
        }];        
    });
}

#pragma mark -

- (void)processRemoveAndExportActions
{
    NSMutableArray *removeUids = [[NSMutableArray alloc] init];
    
    NSArray *removeContactActions = [TGDatabaseInstance() loadFutureActionsWithType:TGRemoveContactFutureActionType];
    for (TGRemoveContactFutureAction *action in removeContactActions)
    {
        [removeUids addObject:[[NSNumber alloc] initWithInt:[action uid]]];
    }
    
    if (removeUids.count != 0)
    {
        _currentActionIds = removeUids;
        
        self.cancelToken = [TGTelegraphInstance doDeleteContacts:removeUids actor:self];
    }
    else
    {
        NSArray *exportContactActions = [TGDatabaseInstance() loadFutureActionsWithType:TGExportContactFutureActionType];
        if (exportContactActions.count == 0)
        {
            [self completeAction:true];
            
            return;
        }
        
        const int maxExportCount = 300;
        
        NSMutableArray *contactsToExport = [[NSMutableArray alloc] init];
        NSMutableArray *exportActionIds = [[NSMutableArray alloc] init];
        
        int currentNumberOfExportActions = 0;
        
        for (TGExportContactFutureAction *action in exportContactActions)
        {
            TGContactBinding *binding = [TGDatabaseInstance() contactBindingWithId:[action contactId]];
            if (binding == nil)
                [TGDatabaseInstance() removeFutureAction:action.uniqueId type:action.type randomId:action.randomId];
            else
            {
                [exportActionIds addObject:[[NSNumber alloc] initWithInt:binding.phoneId]];
                [contactsToExport addObject:binding];
                
                currentNumberOfExportActions++;
                
                if (currentNumberOfExportActions > maxExportCount)
                    break;
            }
        }
        
        _currentActionIds = exportActionIds;
        
        if (contactsToExport.count == 0)
        {
            [self completeAction:true];
            
            return;
        }
        else
        {
            self.cancelToken = [TGTelegraphInstance doExportContacts:contactsToExport requestBuilder:self];
        }
    }
}

- (void)deleteContactsSuccess:(NSArray *)__unused uids
{
    [TGDatabaseInstance() removeFutureActionsWithType:TGRemoveContactFutureActionType uniqueIds:_currentActionIds];
    _currentActionIds = nil;
    
    [self processRemoveAndExportActions];
}

- (void)deleteContactsFailed:(NSArray *)uids
{
    [self deleteContactsSuccess:uids];
}

- (void)exportContactsSuccess:(NSArray *)importedPhonesArray popularContacts:(NSArray *)popularContacts users:(NSArray *)users
{
    [TGDatabaseInstance() removeFutureActionsWithType:TGExportContactFutureActionType uniqueIds:_currentActionIds];
    _currentActionIds = nil;
    
    [TGUserDataRequestBuilder executeUserDataUpdate:users];
    std::vector<int> remoteContactUids;
    [TGDatabaseInstance() loadRemoteContactUids:remoteContactUids];
    std::set<int> currentRemoteContactUidsSet;
    for (std::vector<int>::iterator it = remoteContactUids.begin(); it != remoteContactUids.end(); it++)
        currentRemoteContactUidsSet.insert(*it);
    
    NSMutableArray *addedRemoteUids = [[NSMutableArray alloc] init];
    
    for (TGImportedPhone *importedPhone in importedPhonesArray)
    {
        if (currentRemoteContactUidsSet.find(importedPhone.user_id) == currentRemoteContactUidsSet.end())
        {
            [addedRemoteUids addObject:[[NSNumber alloc] initWithInt:importedPhone.user_id]];
        }
    }
    
    [TGDatabaseInstance() replacePopularInvitees:popularContacts];
    
    if (addedRemoteUids.count != 0)
    {
        [TGDatabaseInstance() addRemoteContactUids:addedRemoteUids];
        [TGContactListRequestBuilder dispatchNewContactList];
    }
    
    [self processRemoveAndExportActions];
}

- (void)exportContactsFailed
{
    TGDispatchAfter(1.0, [ActionStageInstance() globalStageDispatchQueue], ^
    {
        [self processRemoveAndExportActions];
    });
}

#pragma mark -

- (void)processCreateContact:(TGPhonebookContact *)phonebookContact uid:(int)uid
{
    CreateAddressBookAsync(^(ABAddressBookRef addressBook, bool denied)
    {
        if (addressBook == NULL || denied)
        {
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                [self completeAction:false];
            }];
            
            return;
        }
        
        CFErrorRef error = NULL;
        ABRecordRef newPerson = ABPersonCreate();
        
        TGPhonebookContact *newPhonebookContact = [phonebookContact copy];
        
        if (phonebookContact.firstName != nil)
            ABRecordSetValue(newPerson, kABPersonFirstNameProperty, (__bridge CFTypeRef)(phonebookContact.firstName), &error);
        if (phonebookContact.lastName != nil)
            ABRecordSetValue(newPerson, kABPersonLastNameProperty, (__bridge CFTypeRef)(phonebookContact.lastName), &error);
        
        ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        
        for (TGPhoneNumber *phoneNumber in phonebookContact.phoneNumbers)
        {
            NSString *phoneLabel = nativePhoneLabelForString(phoneNumber.label);
            
            ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)phoneNumber.number, (__bridge CFStringRef)phoneLabel, NULL);
        }
        
        ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone, nil);
        CFRelease(multiPhone);
        
        ABAddressBookAddRecord(addressBook, newPerson, &error);
        ABAddressBookSave(addressBook, &error);
        
        newPhonebookContact.nativeId = ABRecordGetRecordID(newPerson);
        
        CFRelease(newPerson);
        
        if (error != NULL)
        {
            CFStringRef errorDesc = CFErrorCopyDescription(error);
            NSLog(@"Contact not saved: %@", errorDesc);
            CFRelease(errorDesc);
        }
        
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            if (uid != 0)
            {
                TGUser *newUser = [[TGDatabaseInstance() loadUser:uid] copy];
                newUser.phonebookFirstName = phonebookContact.firstName;
                newUser.phonebookLastName = phonebookContact.lastName;
                [TGUserDataRequestBuilder executeUserObjectsUpdate:[[NSArray alloc] initWithObjects:newUser, nil]];
            }
            
            [TGDatabaseInstance() replacePhonebookContact:0 phonebookContact:newPhonebookContact generateContactBindings:true];
            if (uid != 0)
            {
                [TGDatabaseInstance() addRemoteContactUids:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:uid], nil]];
                int link = [TGDatabaseInstance() loadUserLink:uid outdated:NULL];
                link &= ~TGUserLinkMyRequested;
                link |= TGUserLinkMyContact;
                [TGUserDataRequestBuilder executeUserLinkUpdates:[NSArray arrayWithObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:uid], [[NSNumber alloc] initWithInt:link], nil]]];
            }
            
            [TGContactListRequestBuilder dispatchNewContactList];
            [TGContactListRequestBuilder dispatchNewPhonebook];
            
            [self completeAction:true];
            
            [[TGSynchronizeContactsManager instance] addressBookChanged];
        }];
    });
}

- (void)processAddContact:(TGUser *)user
{
    int contactId = user.contactId;
    if (contactId == 0)
    {
        [self completeAction:true];
        
        return;
    }
    
    CreateAddressBookAsync(^(ABAddressBookRef addressBook, bool denied)
    {
        if (addressBook == NULL || denied)
        {
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                [TGDatabaseInstance() addRemoteContactUids:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:user.uid], nil]];
                [TGContactListRequestBuilder dispatchNewContactList];
                
                [self completeAction:true];
            }];
            
            return;
        }
        
        bool imported = false;
    
        if (user.phoneNumber.length != 0 && [TGDatabaseInstance() contactBindingWithId:user.contactId] == nil)
        {
            TGLog(@"Importing %@", user.displayName);
            if ([self importContactToPhonebook:addressBook user:user])
            {
                imported = true;
                ABAddressBookSave(addressBook, nil);
            }
        }
        
        NSData *phonebookData = [TGDatabaseInstance() customProperty:@"phonebookState"];
        NSMutableData *newPhonebookData = [[NSMutableData alloc] initWithCapacity:phonebookData.length + 4];
        if (phonebookData != nil)
            [newPhonebookData appendData:phonebookData];
        int newContactId = contactId;
        [newPhonebookData appendBytes:&newContactId length:4];
        [TGDatabaseInstance() setCustomProperty:@"phonebookState" value:newPhonebookData];
        
        NSData *exportData = [TGDatabaseInstance() customProperty:@"exportState"];
        NSMutableData *newExportData = [[NSMutableData alloc] initWithCapacity:exportData.length + 4];
        if (exportData != nil)
            [newExportData appendData:exportData];
        int newExportId = murMurHash32([[NSString alloc] initWithFormat:@"%@%@%@", user.firstName, user.lastName, user.phoneNumber]);
        [newExportData appendBytes:&newExportId length:4];
        [TGDatabaseInstance() setCustomProperty:@"exportState" value:newExportData];
        
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            [TGDatabaseInstance() addRemoteContactUids:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:user.uid], nil]];
            [TGContactListRequestBuilder dispatchNewContactList];
            if (imported)
                [TGContactListRequestBuilder dispatchNewPhonebook];
            
            [self completeAction:true];
        }];
    });
}

- (void)processChangeContactName:(int)uid nativeId:(int)nativeId changeFirstName:(NSString *)changeFirstName changeLastName:(NSString *)changeLastName
{
    if (![TGDatabaseInstance() uidIsRemoteContact:uid])
    {
        [self completeAction:false];
        return;
    }
    
    TGUser *user = [TGDatabaseInstance() loadUser:uid];
    if (user == nil || nativeId == 0)
    {
        [self completeAction:false];
        return;
    }
    
    CreateAddressBookAsync(^(ABAddressBookRef addressBook, bool denied)
    {
        if (addressBook == NULL || denied)
        {
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                [self completeAction:false];
            }];
            
            return;
        }
        
        ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, nativeId);
        if (person != NULL)
        {
            ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFStringRef)changeFirstName, NULL);
            ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge CFStringRef)changeLastName, NULL);
            
            ABAddressBookSave(addressBook, NULL);
        }
        
        [ActionStageInstance() dispatchOnStageQueue:^
        {   
            TGPhonebookContact *phonebookContact = [TGDatabaseInstance() phonebookContactByNativeId:nativeId];
            phonebookContact = [phonebookContact copy];
            phonebookContact.firstName = changeFirstName;
            phonebookContact.lastName = changeLastName;
            [TGDatabaseInstance() replacePhonebookContact:nativeId phonebookContact:phonebookContact generateContactBindings:true];
            
            TGUser *newUser = [user copy];
            newUser.phonebookFirstName = changeFirstName;
            newUser.phonebookLastName = changeLastName;
            [TGUserDataRequestBuilder executeUserObjectsUpdate:[[NSArray alloc] initWithObjects:newUser, nil]];
            
            [TGContactListRequestBuilder dispatchNewContactList];
            [TGContactListRequestBuilder dispatchNewPhonebook];
            
            /*NSMutableArray *exportActions = [[NSMutableArray alloc] init];
            
            for (TGPhoneNumber *phoneNumber in phonebookContact.phoneNumbers)
            {
                int phoneId = phoneNumber.phoneId;
                if (phoneId != 0)
                    [exportActions addObject:[[TGExportContactFutureAction alloc] initWithContactId:phoneId]];
            }
            
            if (exportActions.count != 0)
                [TGDatabaseInstance() storeFutureActions:exportActions];
            [ActionStageInstance() requestActor:@"/tg/synchronizeContacts/(removeAndExport)" options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithBool:false], @"signalSynchronizationCompleted", nil] watcher:TGTelegraphInstance];*/
            
            [self completeAction:true];
            
            [[TGSynchronizeContactsManager instance] addressBookChanged];
        }];
    });
}

- (void)processAppendContactPhone:(int)uid nativeId:(int)nativeId newPhone:(NSString *)newPhone
{
    if (![TGDatabaseInstance() uidIsRemoteContact:uid] || newPhone.length == 0)
    {
        [self completeAction:false];
        return;
    }
    
    TGUser *user = [TGDatabaseInstance() loadUser:uid];
    if (user == nil || nativeId == 0)
    {
        [self completeAction:false];
        return;
    }
    
    CreateAddressBookAsync(^(ABAddressBookRef addressBook, bool denied)
    {
        if (addressBook == NULL || denied)
        {
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                [self completeAction:false];
            }];
            
            return;
        }
        
        NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
        
        bool found = false;
        ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, nativeId);
        if (person != NULL)
        {
            ABMutableMultiValueRef mutablePhones = ABMultiValueCreateMutable(kABMultiStringPropertyType);
            
            ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            if (phones != NULL)
            {
                int phoneCount = (int)ABMultiValueGetCount(phones);
                for (CFIndex j = 0; j < phoneCount; j++)
                {
                    NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, j);
                    NSString *label = (__bridge_transfer NSString *)ABMultiValueCopyLabelAtIndex(phones, j);
                    if (label != nil)
                    {
                        label = (__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel((__bridge CFStringRef)label);
                    }
                    
                    if (phone.length != 0)
                    {
                        if (TGStringCompare([TGPhoneUtils cleanPhone:phone], [TGPhoneUtils cleanPhone:newPhone]))
                            found = true;
                        
                        ABMultiValueAddValueAndLabel(mutablePhones, (__bridge CFStringRef)phone, (__bridge CFStringRef)nativePhoneLabelForString(label), NULL);
                    }
                    
                    [phoneNumbers addObject:[[TGPhoneNumber alloc] initWithLabel:label == nil ? @"" : label number:phone == nil ? @"" : phone]];
                }
                CFRelease(phones);
            }
            
            if (!found)
            {
                NSString *label = [[TGSynchronizeContactsManager phoneLabels] firstObject];
                
                ABMultiValueInsertValueAndLabelAtIndex(mutablePhones, (__bridge CFStringRef)newPhone, (__bridge CFStringRef)label, 0, NULL);
                
                [phoneNumbers insertObject:[[TGPhoneNumber alloc] initWithLabel:label number:newPhone] atIndex:0];

                ABRecordSetValue(person, kABPersonPhoneProperty, mutablePhones, NULL);
                ABAddressBookSave(addressBook, NULL);
            }
            
            CFRelease(mutablePhones);
        }
        
        if (!found)
        {
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                TGPhonebookContact *phonebookContact = [TGDatabaseInstance() phonebookContactByNativeId:nativeId];
                phonebookContact = [phonebookContact copy];
                phonebookContact.phoneNumbers = phoneNumbers;
                [TGDatabaseInstance() replacePhonebookContact:nativeId phonebookContact:phonebookContact generateContactBindings:true];
                
                [TGContactListRequestBuilder dispatchNewContactList];
                [TGContactListRequestBuilder dispatchNewPhonebook];
                
                [self completeAction:true];
                
                [[TGSynchronizeContactsManager instance] addressBookChanged];
            }];
        }
    });
}


- (void)processChangeContactPhones:(int)uid nativeId:(int)nativeId changePhones:(NSArray *)changePhones addingUid:(int)addingUid removedMainPhone:(bool)removedMainPhone
{
    CreateAddressBookAsync(^(ABAddressBookRef addressBook, bool denied)
    {
        if (addressBook == NULL || denied)
        {
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                [self completeAction:false];
            }];
            
            return;
        }
        
        ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, nativeId);
        
        if (person != NULL)
        {
            ABMutableMultiValueRef mutablePhones = ABMultiValueCreateMutable(kABMultiStringPropertyType);
            
            for (TGPhoneNumber *phoneNumber in changePhones)
            {
                NSString *label = nativePhoneLabelForString(phoneNumber.label);
                
                ABMultiValueAddValueAndLabel(mutablePhones, (__bridge CFStringRef)phoneNumber.number, (__bridge CFStringRef)label, NULL);
            }
            
            ABRecordSetValue(person, kABPersonPhoneProperty, mutablePhones, NULL);
            
            CFRelease(mutablePhones);
            
            ABAddressBookSave(addressBook, NULL);
        }
        
        [ActionStageInstance() dispatchOnStageQueue:^
        {   
            TGPhonebookContact *phonebookContact = [TGDatabaseInstance() phonebookContactByNativeId:nativeId];
            phonebookContact = [phonebookContact copy];
            phonebookContact.phoneNumbers = changePhones;
            [TGDatabaseInstance() replacePhonebookContact:phonebookContact.nativeId phonebookContact:phonebookContact generateContactBindings:true];
            
            if (addingUid != 0)
            {
                TGUser *newUser = [[TGDatabaseInstance() loadUser:addingUid] copy];
                newUser.phonebookFirstName = phonebookContact.firstName;
                newUser.phonebookLastName = phonebookContact.lastName;
                [TGUserDataRequestBuilder executeUserObjectsUpdate:[[NSArray alloc] initWithObjects:newUser, nil]];
                
                [TGDatabaseInstance() addRemoteContactUids:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:addingUid], nil]];
                int link = [TGDatabaseInstance() loadUserLink:addingUid outdated:NULL];
                link &= ~TGUserLinkMyRequested;
                link |= TGUserLinkMyContact;
                [TGUserDataRequestBuilder executeUserLinkUpdates:[NSArray arrayWithObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:addingUid], [[NSNumber alloc] initWithInt:link], nil]]];
            }
            
            if (removedMainPhone && uid != 0)
            {
                TGUser *newUser = [[TGDatabaseInstance() loadUser:uid] copy];
                newUser.phonebookFirstName = nil;
                newUser.phonebookLastName = nil;
                [TGUserDataRequestBuilder executeUserObjectsUpdate:[[NSArray alloc] initWithObjects:newUser, nil]];
                
                int link = [TGDatabaseInstance() loadUserLink:uid outdated:NULL];
                link &= ~TGUserLinkMyContact;
                if (link & TGUserLinkForeignMutual)
                    link &= ~TGUserLinkForeignMutual;
                link |= TGUserLinkForeignRequested;
                link |= TGUserLinkMyRequested;
                link |= TGUserLinkForeignHasPhone;
                [TGUserDataRequestBuilder executeUserLinkUpdates:[NSArray arrayWithObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:uid], [[NSNumber alloc] initWithInt:link], nil]]];
                
                [TGDatabaseInstance() deleteRemoteContactUids:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:uid], nil]];
                
                [TGDatabaseInstance() storeFutureActions:[[NSArray alloc] initWithObjects:[[TGRemoveContactFutureAction alloc] initWithUid:uid], nil]];
            }
            
            [TGContactListRequestBuilder dispatchNewContactList];
            [TGContactListRequestBuilder dispatchNewPhonebook];
            
            [self completeAction:true];
            
            [[TGSynchronizeContactsManager instance] addressBookChanged];
            
            if (removedMainPhone && uid != 0)
            {
                [ActionStageInstance() requestActor:@"/tg/synchronizeContacts/(removeAndExport)" options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithBool:false], @"signalSynchronizationCompleted", nil] watcher:TGTelegraphInstance];
            }
        }];
    });
}

- (void)processRemoveContact:(int)uid byNativeId:(int)nativeId
{
    TGUser *user = [TGDatabaseInstance() loadUser:uid];
    if (user == nil || nativeId == 0)
    {
        [self completeAction:true];
        return;
    }
    
    CreateAddressBookAsync(^(ABAddressBookRef addressBook, bool denied)
    {
        if (addressBook == NULL || denied)
        {
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                TGUser *newUser = [user copy];
                newUser.phonebookFirstName = nil;
                newUser.phonebookLastName = nil;
                [TGUserDataRequestBuilder executeUserObjectsUpdate:[[NSArray alloc] initWithObjects:newUser, nil]];
                
                int link = [TGDatabaseInstance() loadUserLink:uid outdated:NULL];
                link &= ~TGUserLinkMyContact;
                if (link & TGUserLinkForeignMutual)
                    link &= ~TGUserLinkForeignMutual;
                link |= TGUserLinkForeignRequested;
                link |= TGUserLinkMyRequested;
                link |= TGUserLinkForeignHasPhone;
                [TGUserDataRequestBuilder executeUserLinkUpdates:[NSArray arrayWithObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:uid], [[NSNumber alloc] initWithInt:link], nil]]];
                
                [TGDatabaseInstance() deleteRemoteContactUids:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:uid], nil]];
                [TGDatabaseInstance() replacePhonebookContact:nativeId phonebookContact:nil generateContactBindings:true];
                [TGContactListRequestBuilder dispatchNewContactList];
                [TGContactListRequestBuilder dispatchNewPhonebook];
                
                [self completeAction:true];
            }];
            
            return;
        }
        
        ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, nativeId);
        
        if (person != NULL)
        {
            ABAddressBookRemoveRecord(addressBook, person, NULL);
            ABAddressBookSave(addressBook, NULL);
        }
        
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            TGUser *newUser = [user copy];
            newUser.phonebookFirstName = nil;
            newUser.phonebookLastName = nil;
            [TGUserDataRequestBuilder executeUserObjectsUpdate:[[NSArray alloc] initWithObjects:newUser, nil]];
            
            int link = [TGDatabaseInstance() loadUserLink:uid outdated:NULL];
            link &= ~TGUserLinkMyContact;
            if (link & TGUserLinkForeignMutual)
                link &= ~TGUserLinkForeignMutual;
            link |= TGUserLinkForeignRequested;
            link |= TGUserLinkMyRequested;
            link |= TGUserLinkForeignHasPhone;
            [TGUserDataRequestBuilder executeUserLinkUpdates:[NSArray arrayWithObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:uid], [[NSNumber alloc] initWithInt:link], nil]]];
            
            [TGDatabaseInstance() deleteRemoteContactUids:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:uid], nil]];
            [TGDatabaseInstance() replacePhonebookContact:nativeId phonebookContact:nil generateContactBindings:true];
            
            [TGContactListRequestBuilder dispatchNewContactList];
            [TGContactListRequestBuilder dispatchNewPhonebook];
            
            [TGDatabaseInstance() storeFutureActions:[[NSArray alloc] initWithObjects:[[TGRemoveContactFutureAction alloc] initWithUid:uid], nil]];
            [ActionStageInstance() requestActor:@"/tg/synchronizeContacts/(removeAndExport)" options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithBool:false], @"signalSynchronizationCompleted", nil] watcher:TGTelegraphInstance];
            
            [self completeAction:true];
            
            [[TGSynchronizeContactsManager instance] addressBookChanged];
        }];
    });
}

- (void)processRemoveContact:(int)uid byPhoneId:(int)phoneIdToRemove
{
    TGUser *user = [TGDatabaseInstance() loadUser:uid];
    if (user == nil || phoneIdToRemove == 0)
    {
        [self completeAction:true];
        return;
    }
    
    CreateAddressBookAsync(^(ABAddressBookRef addressBook, bool denied)
    {
        if (addressBook == NULL || denied)
        {
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                TGUser *newUser = [user copy];
                newUser.phonebookFirstName = nil;
                newUser.phonebookLastName = nil;
                [TGUserDataRequestBuilder executeUserObjectsUpdate:[[NSArray alloc] initWithObjects:newUser, nil]];
                [TGDatabaseInstance() deleteRemoteContactUids:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:uid], nil]];
                [TGDatabaseInstance() deleteContactBinding:phoneIdToRemove];
                [TGContactListRequestBuilder dispatchNewContactList];
                [TGContactListRequestBuilder dispatchNewPhonebook];
                
                [self completeAction:true];
            }];
            
            return;
        }
        
        CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
        int count = (int)CFArrayGetCount(people);
        
        std::set<int> removeExportIdsSet;
        
        bool foundPerson = false;
        
        for (CFIndex i = 0; i < count; i++)
        {
            ABRecordRef person = CFArrayGetValueAtIndex(people, i);
            
            ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            if (phones == NULL)
                continue;
            
            int phoneCount = (int)ABMultiValueGetCount(phones);
            for (CFIndex j = 0; j < phoneCount; j++)
            {
                NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, j);
                int phoneId = phoneMatchHash(phone);
                
                if (phoneId == phoneIdToRemove)
                {
                    foundPerson = true;
                    
                    NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
                    NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
                    
                    if (firstName == nil)
                        firstName = @"";
                    if (lastName == nil)
                        lastName = @"";
                    
                    if (firstName.length == 0 && lastName.length == 0)
                    {
                        lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty);
                        if (lastName == nil)
                            lastName = @"";
                    }
                    
                    if (lastName.length == 0)
                    {
                        lastName = firstName;
                        firstName = @"";
                    }
                    
                    NSString *cleanPhone = [TGPhoneUtils cleanPhone:phone];
                    removeExportIdsSet.insert(murMurHash32([[NSString alloc] initWithFormat:@"%@%@%@", firstName, lastName, cleanPhone]));
                    
                    if (phoneCount == 1)
                    {
                        ABAddressBookRemoveRecord(addressBook, person, NULL);
                        TGLog(@"delete %@ %@", firstName, lastName);
                    }
                    else
                    {
                        ABMultiValueRef currentPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
                        ABMutableMultiValueRef mutablePhones = ABMultiValueCreateMutableCopy(currentPhones);
                        CFRelease(currentPhones);
                        
                        int phoneCount = (int)ABMultiValueGetCount(mutablePhones);
                        for (CFIndex j = 0; j < phoneCount; j++)
                        {
                            NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, j);
                            
                            if (phone.length != 0 && phoneMatchHash(phone) == phoneId)
                            {
                                ABMultiValueRemoveValueAndLabelAtIndex(mutablePhones, j);
                            }
                        }
                        
                        ABRecordSetValue(person, kABPersonPhoneProperty, mutablePhones, NULL);
                        CFRelease(mutablePhones);
                    }
                    
                    break;
                }
            }
            if (phones != NULL)
                CFRelease(phones);
        }
        
        if (foundPerson)
        {
            NSData *phonebookData = [TGDatabaseInstance() customProperty:@"phonebookState"];
            NSMutableData *newPhonebookData = [[NSMutableData alloc] initWithData:phonebookData];
            uint8_t *phonebookStateBytes = (uint8_t *)newPhonebookData.mutableBytes;
            int phonebookStateLength = (int)newPhonebookData.length;
            for (int i = 0; i < phonebookStateLength; i += 4)
            {
                int contactId = *((int *)(phonebookStateBytes + i));
                if (contactId == phoneIdToRemove)
                {
                    *((int *)(phonebookStateBytes + i)) = 0;
                    
                    break;
                }
            }
            [TGDatabaseInstance() setCustomProperty:@"phonebookState" value:newPhonebookData];
            
            if (!removeExportIdsSet.empty())
            {
                NSData *exportData = [TGDatabaseInstance() customProperty:@"exportState"];
                NSMutableData *newExportData = [[NSMutableData alloc] initWithData:exportData];
                uint8_t *exportStateBytes = (uint8_t *)newExportData.mutableBytes;
                int exportStateLength = (int)newExportData.length;
                for (int i = 0; i < exportStateLength; i += 4)
                {
                    int exportId = *((int *)(exportStateBytes + i));
                    if (removeExportIdsSet.find(exportId) != removeExportIdsSet.end())
                    {
                        *((int *)(exportStateBytes + i)) = 0;
                        
                        break;
                    }
                }
                [TGDatabaseInstance() setCustomProperty:@"exportState" value:newExportData];
            }
        }
        
        if (people != NULL)
            CFRelease(people);
        
        ABAddressBookSave(addressBook, NULL);
        
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            TGUser *newUser = [user copy];
            newUser.phonebookFirstName = nil;
            newUser.phonebookLastName = nil;
            
            [TGUserDataRequestBuilder executeUserObjectsUpdate:[[NSArray alloc] initWithObjects:newUser, nil]];
            TGPhonebookContact *phonebookContact = [TGDatabaseInstance() phonebookContactByPhoneId:phoneIdToRemove];
            if (phonebookContact != nil && [phonebookContact containsPhoneId:phoneIdToRemove])
            {
                if (phonebookContact.phoneNumbers.count <= 1)
                    [TGDatabaseInstance() replacePhonebookContact:phonebookContact.nativeId phonebookContact:nil generateContactBindings:true];
                else
                {
                    phonebookContact = [phonebookContact copy];
                    NSMutableArray *newPhoneNumbers = [[NSMutableArray alloc] init];
                    for (TGPhoneNumber *phoneNumber in phonebookContact.phoneNumbers)
                    {
                        if (phoneNumber.phoneId != phoneIdToRemove)
                            [newPhoneNumbers addObject:phoneNumber];
                    }
                    phonebookContact.phoneNumbers = newPhoneNumbers;
                    [TGDatabaseInstance() replacePhonebookContact:phonebookContact.nativeId phonebookContact:phonebookContact generateContactBindings:true];
                }
            }
            else
            {
                [TGDatabaseInstance() deleteContactBinding:phoneIdToRemove];
            }
            
            [TGDatabaseInstance() deleteRemoteContactUids:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:uid], nil]];
            
            [TGContactListRequestBuilder dispatchNewContactList];
            [TGContactListRequestBuilder dispatchNewPhonebook];
            
            [self completeAction:true];
        }];
    });
}

#pragma mark -

- (TGPhonebookContact *)importContactToPhonebook:(ABAddressBookRef)addressBook user:(TGUser *)user
{
    if (addressBook == NULL)
        return nil;
    
    NSString *mobileLabel = (__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(kABPersonPhoneMobileLabel);
    
    TGPhonebookContact *phonebookContact = [[TGPhonebookContact alloc] init];
    phonebookContact.firstName = user.firstName;
    phonebookContact.lastName = user.lastName;
    phonebookContact.phoneNumbers = [[NSArray alloc] initWithObjects:[[TGPhoneNumber alloc] initWithLabel:mobileLabel number:user.phoneNumber], nil];
    
    CFErrorRef error = NULL;
    ABRecordRef newPerson = ABPersonCreate();
    
    if (user.firstName != nil)
        ABRecordSetValue(newPerson, kABPersonFirstNameProperty, (__bridge CFTypeRef)(user.firstName), &error);
    if (user.lastName != nil)
        ABRecordSetValue(newPerson, kABPersonLastNameProperty, (__bridge CFTypeRef)(user.lastName), &error);
    
    ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    if (user.phoneNumber != nil)
    {
        NSString *formattedNumber = [user.phoneNumber hasPrefix:@"+"] ? user.phoneNumber : [NSString stringWithFormat:@"+%@", user.phoneNumber];
        ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(formattedNumber), kABPersonPhoneMobileLabel, NULL);
    }
    ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone, nil);
    CFRelease(multiPhone);
    
    ABAddressBookAddRecord(addressBook, newPerson, &error);
    
    phonebookContact.nativeId = ABRecordGetRecordID(newPerson);
    [TGDatabaseInstance() replacePhonebookContact:0 phonebookContact:phonebookContact generateContactBindings:false];
    
    CFRelease(newPerson);
    
    if (error == NULL)
        return phonebookContact;
    else
    {
        CFStringRef errorDesc = CFErrorCopyDescription(error);
        NSLog(@"Contact not saved: %@", errorDesc);
        CFRelease(errorDesc);
    }
    
    return nil;
}

#pragma mark -

- (void)importContacts:(void (^)(bool imported))completion
{
    CreateAddressBookAsync(^(ABAddressBookRef addressBook, bool denied)
    {
        if (addressBook == NULL || denied)
        {
            if (completion)
                completion(false);
            return;
        }
        
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        
        bool imported = false;
        
        for (TGUser *user in [TGDatabaseInstance() loadContactUsers])
        {
            if (user.phoneNumber.length != 0 && [TGDatabaseInstance() contactBindingWithId:user.contactId] == nil)
            {
                if (![[TGSynchronizeContactsManager instance] isContactAdditionScheduled:user.uid])
                {
                    TGLog(@"Importing back %@", user.displayName);
                    if ([self importContactToPhonebook:addressBook user:user])
                        imported = true;
                }
            }
        }
        
        if (imported)
        {
            ABAddressBookSave(addressBook, nil);
            
            TGLog(@"Import time: %f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0);
        }
        
        if (completion)
            completion(imported);
    });
}

#pragma mark -

- (void)contactIdsRequestSuccess:(NSArray *)contactIds
{
    std::vector<int> currentUidsVector;
    [TGDatabaseInstance() loadRemoteContactUids:currentUidsVector];
    std::set<int> currentUids;
    for (std::vector<int>::iterator it = currentUidsVector.begin(); it != currentUidsVector.end(); it++)
    {
        currentUids.insert(*it);
    }
    
    std::set<int> remoteUids;
    for (NSNumber *nUid in contactIds)
    {
        remoteUids.insert([nUid intValue]);
    }
    
    if (remoteUids != currentUids)
    {
        _hadRemoteContacts = false;
        self.cancelToken = [TGTelegraphInstance doRequestContactList:nil actor:self];
    }
    else
    {
        [self importContacts:^(bool imported)
        {
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                if (imported)
                {
                    [TGContactListRequestBuilder dispatchNewContactList];
                    [TGContactListRequestBuilder dispatchNewPhonebook];
                }
                
                [[TGSynchronizeContactsManager instance] setContactsSynchronizationStatus:false];
                
                [self completeAction:true];
            }];
        }];
    }
}

- (void)contactIdsRequestFailed
{
    [[TGSynchronizeContactsManager instance] setContactsSynchronizationStatus:false];
    
    [self completeAction:false];
}

#pragma mark -

- (void)contactListRequestSuccess:(TLcontacts_Contacts *)result
{
    if ([result isKindOfClass:[TLcontacts_Contacts$contacts_contacts class]])
    {
        TGLog(@"Reloading contact list from server...");
        
        TLcontacts_Contacts$contacts_contacts *concreteContacts = (TLcontacts_Contacts$contacts_contacts *)result;
        
        [TGUserDataRequestBuilder executeUserDataUpdate:concreteContacts.users];
        NSMutableArray *contactUids = [[NSMutableArray alloc] init];
        
        for (TLContact *contact in concreteContacts.contacts)
        {
            if (contact.user_id != 0)
                [contactUids addObject:[[NSNumber alloc] initWithInt:contact.user_id]];
        }
        
        [[TGSynchronizeContactsManager instance] dispatchOnAddressBookQueue:^
        {
            [TGDatabaseInstance() replaceRemoteContactUids:contactUids];
            
            [self importContacts:^(__unused bool imported)
            {
                [ActionStageInstance() dispatchOnStageQueue:^
                {
                    //if (imported)
                    {
                        [TGContactListRequestBuilder dispatchNewContactList];
                        [TGContactListRequestBuilder dispatchNewPhonebook];
                    }
                    
                    [[TGSynchronizeContactsManager instance] setContactsSynchronizationStatus:false];
                    
                    if (!TGTelegraphInstance.clientIsActivated && contactUids.count != 0)
                    {
                        TGTelegraphInstance.clientIsActivated = true;
                        [TGAppDelegateInstance saveSettings];
                    }
                    
                    [self completeAction:true];
                }];
            }];
        }];
    }
    else
    {
        [[TGSynchronizeContactsManager instance] dispatchOnAddressBookQueue:^
        {
            [self importContacts:^(__unused bool imported)
            {
                [ActionStageInstance() dispatchOnStageQueue:^
                {
                    [[TGSynchronizeContactsManager instance] setContactsSynchronizationStatus:false];
                    
                    if (_hadRemoteContacts && !TGTelegraphInstance.clientIsActivated)
                    {
                        TGTelegraphInstance.clientIsActivated = true;
                        [TGAppDelegateInstance saveSettings];
                    }
                    
                    [self completeAction:true];
                }];
            }];
        }];
    }
}

- (void)contactListRequestFailed
{
    [[TGSynchronizeContactsManager instance] setContactsSynchronizationStatus:false];
    
    [self completeAction:false];
}

- (void)completeAction:(bool)success
{
    if (_signalSynchronizationCompleted)
        [[TGSynchronizeContactsManager instance] setContactsSynchronizationStatus:false];
    
    if ([self.path hasSuffix:@"removeAndExport)"])
    {
        [[TGSynchronizeContactsManager instance] setRemoveAndExportActionsRunning:false];
        
        [ActionStageInstance() requestActor:@"/tg/synchronizeContacts/(loadRemote)" options:nil watcher:TGTelegraphInstance];
    }
    
    if (success)
        [ActionStageInstance() actionCompleted:self.path result:nil];
    else
        [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
