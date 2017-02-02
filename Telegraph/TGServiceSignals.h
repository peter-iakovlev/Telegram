#import <SSignalKit/SSignalKit.h>

@interface TGServiceSignals : NSObject

+ (SSignal *)appChangelogMessage;
+ (SSignal *)reportSpam:(int64_t)peerId accessHash:(int64_t)accessHash;

@end
