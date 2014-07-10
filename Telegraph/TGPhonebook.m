#import "TGPhonebook.h"

#import "ATQueue.h"
#import "TGWeakReference.h"

#import "TGPhonebookEntry.h"

//#import <ReactiveCocoa/ReactiveCocoa.h>
#import <AddressBook/AddressBook.h>
#import <libkern/OSAtomic.h>

static NSMutableDictionary *wrapperByRefId()
{
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        dict = [[NSMutableDictionary alloc] init];
    });
    
    return dict;
}

static void ABAddressBookWrapperExternalChangeCallback(ABAddressBookRef addressBook, CFDictionaryRef info, void *context);

@interface TGPhonebook ()
{
    //RACScheduler *_scheduler;
    ABAddressBookRef _addressBook;
    int32_t _refId;
    
    bool _requestedAccess;
    NSMutableArray *_entriesCompletions;
    
    NSArray *_cachedEntries;
    
    RACSignal *_entriesSignal;
    //RACSubject *_entriesUpdatedSubject;
}

@end

@implementation TGPhonebook

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        static volatile int32_t nextRefId = 0;
        
        _refId = OSAtomicIncrement32Barrier(&nextRefId);
        _scheduler = [[ATQueue alloc] init].scheduler;
        _entriesCompletions = [[NSMutableArray alloc] init];
        
        @synchronized (wrapperByRefId())
        {
            wrapperByRefId()[@(_refId)] = [[TGWeakReference alloc] initWithObject:self];
        }
        
        _entriesUpdatedSubject = [RACSubject subject];
        
        /*__weak typeof(self) weakSelf = self;
        _entriesSignal = [[[RACSignal merge:@[[RACSignal return:nil], _entriesUpdatedSubject]] flattenMap:^RACStream *(__unused id value)
        {
            TGLog(@"[TGPhonebook begin signal]");
            
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber)
            {
                __strong typeof(self) strongSelf = weakSelf;
                
                if (strongSelf != nil)
                {
                    [strongSelf requestEntries:^(NSArray *entries)
                    {
                        [subscriber sendNext:entries];
                    }];
                }
                return nil;
            }];
        }] subscribeOn:[RACScheduler immediateScheduler]];*/
    }
    return self;
}

- (void)dealloc
{
    @synchronized (wrapperByRefId())
    {
        [wrapperByRefId() removeObjectForKey:@(_refId)];
    }
    
    ABAddressBookRef addressBook = _addressBook;
    int32_t refId = _refId;
    
    [_scheduler schedule:^
    {
        if (addressBook != NULL)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                ABAddressBookUnregisterExternalChangeCallback(addressBook, &ABAddressBookWrapperExternalChangeCallback, (void *)refId);
                CFRelease(addressBook);
            });
        }
    }];
}

- (RACSignal *)entries
{
    return _entriesSignal;
}

- (void)requestEntries:(void (^)(NSArray *))completion
{
    if (completion == nil)
        return;
    
    [_scheduler schedule:^
    {
        id completionCopy = [completion copy];
        if (![_entriesCompletions containsObject:completionCopy])
            [_entriesCompletions addObject:completionCopy];
        
        if (_cachedEntries != nil)
            [self _dispatchEntries:_cachedEntries];
        else if (_addressBook == NULL)
        {
            CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
            TGLog(@"[TGPhonebook begin ]", (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0);
            
            _addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
            if (_addressBook != NULL)
            {
                if (!_requestedAccess)
                {
                    _requestedAccess = true;
                    
                    ABAddressBookRequestAccessWithCompletion(_addressBook, ^(bool granted, __unused CFErrorRef error)
                    {
                        [_scheduler schedule:^
                        {
                            TGLog(@"[TGPhonebook received access %f ms]", (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0);
                            
                            if (granted)
                            {
                                dispatch_async(dispatch_get_main_queue(), ^
                                {
                                    ABAddressBookRegisterExternalChangeCallback(_addressBook, &ABAddressBookWrapperExternalChangeCallback, (void *)_refId);
                                });
                                
                                _cachedEntries = [self _readEntries];
                                [self _dispatchEntries:_cachedEntries];
                            }
                            else
                                [self _dispatchEntries:nil];
                        }];
                    });
                }
            }
            else
                [self _dispatchEntries:nil];
        }
        else
        {
            ABAddressBookRevert(_addressBook);
            _cachedEntries = [self _readEntries];
            [self _dispatchEntries:_cachedEntries];
        }
    }];
}

- (NSArray *)_readEntries
{
    TGLog(@"begin reading entries");
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    
    NSMutableArray *entries = [[NSMutableArray alloc] init];
    
    if (_addressBook != NULL)
    {
        NSArray *recordList = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(_addressBook);
        
        for (id rawRecord in recordList)
        {
            ABRecordRef record = (__bridge ABRecordRef)rawRecord;
            
            NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonFirstNameProperty);
            NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonLastNameProperty);
            NSString *middleName = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonMiddleNameProperty);
            NSString *organization = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonOrganizationProperty);
            
            ABMultiValueRef rawPhones = ABRecordCopyValue(record, kABPersonPhoneProperty);
            int phoneCount = rawPhones == NULL ? 0 : ABMultiValueGetCount(rawPhones);
            NSMutableArray *phones = [[NSMutableArray alloc] initWithCapacity:phoneCount];
            
            for (CFIndex j = 0; j < phoneCount; j++)
            {
                NSString *number = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(rawPhones, j);
                NSString *label = nil;
                
                CFStringRef valueLabel = ABMultiValueCopyLabelAtIndex(rawPhones, j);
                if (valueLabel != NULL)
                {
                    label = (__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(valueLabel);
                    CFRelease(valueLabel);
                }
                
                [phones addObject:[[TGPhonebookPhone alloc] initWithLabel:label number:number]];
            }
            if (rawPhones != NULL)
                CFRelease(rawPhones);
            
            [entries addObject:[[TGPhonebookEntry alloc] initWithFirstName:firstName lastName:lastName middleName:middleName organization:organization phones:phones]];
        }
    }
    
    TGLog(@"[TGPhonebook#%p read entries in %f ms]", self, (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0);
    
    return entries;
}

- (void)_dispatchEntries:(NSArray *)entries
{
    TGLog(@"begin dispatching entries");
    
    NSArray *entriesCompletionsCopy = [[NSArray alloc] initWithArray:_entriesCompletions];
    [_entriesCompletions removeAllObjects];
    
    for (void (^completionBlock)(NSArray *) in entriesCompletionsCopy)
    {
        completionBlock(entries);
    }
}

- (void)_addressBookChanged
{
    [_entriesUpdatedSubject sendNext:nil];
}

@end

static void ABAddressBookWrapperExternalChangeCallback(__unused ABAddressBookRef addressBook, __unused CFDictionaryRef info, void *context)
{
    TGWeakReference *ref = nil;
    @synchronized (wrapperByRefId())
    {
        ref = wrapperByRefId()[@((int32_t)context)];
    }
    
    [(TGPhonebook *)[ref object] _addressBookChanged];
}
