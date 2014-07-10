#import "TGContactsContext.h"

//#import <ReactiveCocoa/ReactiveCocoa.h>

#import "PSLMDBKeyValueStore.h"

#import "TGPhonebook.h"

#import "ATQueue.h"

@interface TGContactsContext ()
{
    //RACScheduler *_scheduler;
    
    //PSLMDBKeyValueStore *_persistentStore;
    
    //TGPhonebook *_phonebook;
}

@end

@implementation TGContactsContext

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        //_scheduler = [[ATQueue alloc] init].scheduler;
        
        NSString *storePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0] stringByAppendingPathComponent:@"persistent"];
        
        //_persistentStore = [PSLMDBKeyValueStore storeWithPath:storePath];
        
        /*_phonebook = [[TGPhonebook alloc] init];
        
        [_phonebook requestEntries:^(__unused NSArray *phonebookEntriesUnused)
        {
            TGDispatchAfter(10.0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
            {
                CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
                TGLog(@"begin subscribing");
                
                if (false)
                {
                    [_phonebook requestEntries:^(NSArray *phonebookEntries)
                    {
                        TGLog(@"request time: %f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0);
                        TGLog(@"%@#%p entries 1", phonebookEntries.firstObject, phonebookEntries);
                    }];
                }
                else
                {
                    [[_phonebook entries] subscribeNext:^(NSArray *phonebookEntries)
                    {
                        TGLog(@"signal time: %f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0);
                        TGLog(@"%@#%p entries 1", phonebookEntries.firstObject, phonebookEntries);
                    }];
                }
            });
        }];*/
    }
    return self;
}

- (NSString *)contactsPath
{
    return @"contacts";
}

@end
