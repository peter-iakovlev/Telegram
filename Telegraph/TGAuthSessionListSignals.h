#import <SSignalKit/SSignalKit.h>

#import "TGAuthSession.h"
#import "TGAppSession.h"

@interface TGAuthSessionListSignals : NSObject

+ (SSignal *)authSessionList;
+ (SSignal *)removeAllOtherSessions;
+ (SSignal *)removeSession:(TGAuthSession *)session;

+ (SSignal *)loggedAppsSessionList;
+ (SSignal *)removeAllAppSessions;
+ (SSignal *)removeAppSession:(TGAppSession *)session;

@end
