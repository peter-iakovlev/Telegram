#import <SSignalKit/SSignalKit.h>

@interface TGServiceSignals : NSObject

+ (SSignal *)appChangelog;
+ (SSignal *)reportSpam:(int64_t)peerId accessHash:(int64_t)accessHash;

@end
