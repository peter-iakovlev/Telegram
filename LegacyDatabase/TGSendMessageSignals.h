#import <Foundation/Foundation.h>

#import <SSignalKit/SSignalKit.h>

#import "TGPeerId.h"
#import "TGShareContext.h"

@interface TGSendMessageSignals : NSObject

+ (SSignal *)sendTextMessageWithContext:(TGShareContext *)context peerId:(TGPeerId)peerId users:(NSArray *)users text:(NSString *)text;
+ (SSignal *)sendMediaWithContext:(TGShareContext *)context peerId:(TGPeerId)peerId users:(NSArray *)users inputMedia:(Api70_InputMedia *)inputMedia;

@end
