#import <Foundation/Foundation.h>

#import "ATMessageReceiver.h"

@class ATActorSystem;
@class ATQueue;

extern id ATActorMessageStart;
extern id ATActorMessageStop;

@interface ATActor : NSObject <ATMessageReceiver>

- (instancetype)initWithActorSystem:(ATActorSystem *)actorSystem path:(NSString *)path;

- (bool)executesOnDedicatedQueue;

- (NSString *)path;
- (ATActorSystem *)actorSystem;
- (ATQueue *)queue;
- (bool)isRunning;

- (void)processMessage:(id)message sender:(id<ATMessageReceiver>)sender;

- (void)onStart;
- (void)onStop;
- (void)onTerminate;

@end
