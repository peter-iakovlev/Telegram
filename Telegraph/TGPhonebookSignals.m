#import "TGPhonebookSignals.h"

#import <AddressBook/AddressBook.h>
#import <libkern/OSAtomic.h>

#import "TGPhonebookRecord.h"

static NSMutableDictionary *addressBookChangeBlockById()
{
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        dict = [[NSMutableDictionary alloc] init];
    });
    return dict;
}
static OSSpinLock addressBookChangeBlockByIdLock = 0;

static void TGAddressBook_Changed(__unused ABAddressBookRef addressBook, __unused CFDictionaryRef info, void *context)
{
    int32_t key = (int32_t)(intptr_t)context;
    void (^block)() = nil;
    OSSpinLockLock(&addressBookChangeBlockByIdLock);
    block = addressBookChangeBlockById()[@(key)];
    OSSpinLockUnlock(&addressBookChangeBlockByIdLock);
    if (block)
        block();
}

@interface TGAddressBook : NSObject
{
    ABAddressBookRef _addressBook;
    int32_t _changeKey;
    void (^_changed)(TGAddressBook *);
}

@end

@implementation TGAddressBook

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        
        __weak TGAddressBook *weakSelf = self;
        static int32_t nextChangeKey = 0;
        OSSpinLockLock(&addressBookChangeBlockByIdLock);
        _changeKey = nextChangeKey++;
        addressBookChangeBlockById()[@(_changeKey)] = [^
        {
            __strong TGAddressBook *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if (strongSelf->_changed)
                    strongSelf->_changed(strongSelf);
            }
        } copy];
        OSSpinLockUnlock(&addressBookChangeBlockByIdLock);
    }
    return self;
}

- (void)requestAccess:(void (^)(bool))completion
{
    ABAddressBookRequestAccessWithCompletion(_addressBook, ^(bool granted, __unused CFErrorRef error)
    {
        if (completion)
            completion(granted);
    });
}

- (void)setChanged:(void (^)(TGAddressBook *))changed
{
    if (_changed == nil)
    {
        _changed = [changed copy];
        ABAddressBookRegisterExternalChangeCallback(_addressBook, &TGAddressBook_Changed, (void *)(intptr_t)_changeKey);
    }
    else
        _changed = [changed copy];
}

- (void)dealloc
{
    OSSpinLockLock(&addressBookChangeBlockByIdLock);
    [addressBookChangeBlockById() removeObjectForKey:@(_changeKey)];
    OSSpinLockUnlock(&addressBookChangeBlockByIdLock);

    if (_addressBook != NULL)
    {
        ABAddressBookUnregisterExternalChangeCallback(_addressBook, &TGAddressBook_Changed, (void *)(intptr_t)_changeKey);
        CFRelease(_addressBook);
    }
}

- (NSArray *)records
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(_addressBook);
    if (people != NULL)
    {
        CFIndex count = CFArrayGetCount(people);
        for (CFIndex i = 0; i < count; i++)
        {
            ABRecordRef person = CFArrayGetValueAtIndex(people, i);
            NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
            NSString *middleName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
            
            NSMutableArray *numbers = [[NSMutableArray alloc] init];
            
            ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            if (phones != NULL)
            {
                CFIndex phoneCount = ABMultiValueGetCount(phones);
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
                    
                    [numbers addObject:[[TGPhonebookNumber alloc] initWithPhone:number label:label]];
                }
                
                CFRelease(phones);
            }
            
            [array addObject:[[TGPhonebookRecord alloc] initWithFirstName:firstName lastName:lastName middleName:middleName phoneNumbers:numbers]];
        }
        
        CFRelease(people);
    }
    
    return array;
}

@end

@implementation TGPhonebookSignals

+ (SSignal *)authorizedAddressBook
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGAddressBook *addressBook = [[TGAddressBook alloc] init];
        __weak TGAddressBook *weakAddressBook = addressBook;
        [addressBook requestAccess:^(bool success)
        {
            if (success)
            {
                __strong TGAddressBook *strongAddressBook = weakAddressBook;
                if (strongAddressBook != nil)
                    [subscriber putNext:strongAddressBook];
                else
                    TGLog(@"(TGAddressBook instance deallocated before returning to subscriber)");
                [subscriber putCompletion];
            }
            else
                [subscriber putError:nil];
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [addressBook description]; // hold reference
        }];
    }];
}

+ (SSignal *)phonebookRecords
{
    return [[self authorizedAddressBook] mapToSignal:^SSignal *(TGAddressBook *addressBook)
    {
        SSignal *changedSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
        {
            [addressBook setChanged:^(TGAddressBook *addressBook)
            {
                [subscriber putNext:[addressBook records]];
            }];
            return nil;
        }];
        return [[SSignal single:[addressBook records]] then:changedSignal];
    }];
}

@end
