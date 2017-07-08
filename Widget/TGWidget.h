#import <Foundation/Foundation.h>
#import <LegacyDatabase/LegacyDatabase.h>

@interface TGWidget : NSObject

- (SMulticastSignalManager *)tasksSignalManager;

- (SQueue *)queue;
- (SSignal *)shareContext;
- (SSignal *)database;

+ (instancetype)instance;

@end
