#import "TGContactsActor.h"

#import "ATQueue.h"
#import "ATActorSystem.h"

#import "TGPhonebookEntry.h"

#import <libphonenumber/libphonenumber.h>

NSString *TGContactsActorMessageBeginSync = @"TGContactsActorMessageBeginSync";

typedef enum {
    TGContactsActorStateIdle = 0,
    TGContactsActorStateWaitingForPhonebook = 1
} TGContactsActorState;

@interface TGContactsActor ()
{
    id<PSKeyValueStore> _persistentStore;
    TGContactsActorState _state;
}

@end

@implementation TGContactsActor

- (instancetype)initWithActorSystem:(ATActorSystem *)actorSystem path:(NSString *)path
{
    return [self initWithActorSystem:actorSystem path:path persistentStore:nil];
}

- (bool)executesOnDedicatedQueue
{
    return true;
}

- (instancetype)initWithActorSystem:(ATActorSystem *)actorSystem path:(NSString *)path persistentStore:(id<PSKeyValueStore>)persistentStore
{
    self = [super initWithActorSystem:actorSystem path:path];
    if (self != nil)
    {
        _persistentStore = persistentStore;
    }
    return self;
}

- (void)onPhonebookEntriesUpdated:(NSArray *)entries
{
    if (_state == TGContactsActorStateWaitingForPhonebook)
        _state = TGContactsActorStateIdle;
    
    [_persistentStore writeToTable:@"phonebook" inTransaction:^(id<PSKeyValueWriter> writer)
    {
        for (TGPhonebookEntry *entry in entries)
        {
            NSString *rawNumber = ((TGPhonebookPhone *)entry.phones.firstObject).number;
            
            if (rawNumber != nil)
            {
                uint64_t internationalPhone = PhoneNumberForComparison(rawNumber);
                [writer writeValueForRawKey:(uint8_t *)&internationalPhone keyLength:8 value:(uint8_t *)&internationalPhone valueLength:8];
            }
        }
    }];
}

@end
