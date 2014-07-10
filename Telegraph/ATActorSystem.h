#import <Foundation/Foundation.h>

#import "ATMessageReceiver.h"

@class ATQueue;
@class ATActor;

@interface ATActorSystem : NSObject

- (instancetype)init;
- (instancetype)initWithQueue:(ATQueue *)queue;

- (ATQueue *)queue;

- (bool)addActor:(ATActor *)actor;
- (void)_removeActor:(ATActor *)actor;

- (void)sendMessage:(id)message toPath:(NSString *)path sender:(id<ATMessageReceiver>)sender;

@end
