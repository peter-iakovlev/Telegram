#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

@interface TGChatListSignals : NSObject

+ (SSignal *)chatListWithLimit:(NSUInteger)limit;

@end
