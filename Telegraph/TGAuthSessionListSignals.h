#import <SSignalKit/SSignalKit.h>

#import "TGAuthSession.h"

@interface TGAuthSessionListSignals : NSObject

+ (SSignal *)authSessionList;
+ (SSignal *)removeAllOtherSessions;
+ (SSignal *)removeSession:(TGAuthSession *)session;

@end
