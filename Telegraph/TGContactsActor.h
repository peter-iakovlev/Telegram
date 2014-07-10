#import "ATActor.h"

#import "PSKeyValueStore.h"

extern NSString *TGContactsActorMessageBeginSync;

@interface TGContactsActor : ATActor

- (instancetype)initWithActorSystem:(ATActorSystem *)actorSystem path:(NSString *)path persistentStore:(id<PSKeyValueStore>)persistentStore;

@end
