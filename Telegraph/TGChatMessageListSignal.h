#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

#import "TGChatMessageListView.h"

@interface TGChatMessageListSignal : NSObject

+ (SSignal *)chatMessageListViewWithPeerId:(int64_t)peerId atMessageId:(int32_t)messageId rangeMessageCount:(NSUInteger)rangeMessageCount;
+ (SSignal *)readChatMessageListWithPeerId:(int64_t)peerId;

@end
