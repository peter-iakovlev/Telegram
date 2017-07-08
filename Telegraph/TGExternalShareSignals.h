#import <SSignalKit/SSignalKit.h>

@class TGMessage;

@interface TGExternalShareSignals : NSObject

+ (SSignal *)shareItemsForMessages:(NSArray<TGMessage *> *)messages;

@end
