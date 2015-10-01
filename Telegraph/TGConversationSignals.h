#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

@interface TGConversationSignals : NSObject

+ (SSignal *)conversationWithPeerId:(int64_t)peerId;

@end
