#import <SSignalKit/SSignalKit.h>

@interface TGDownloadHistoryForNavigatingToMessageSignal : NSObject

+ (SSignal *)signalForPeerId:(int64_t)peerId messageId:(int32_t)messageId;

@end
