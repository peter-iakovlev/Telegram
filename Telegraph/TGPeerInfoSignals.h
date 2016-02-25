#import <Foundation/Foundation.h>

#import <SSignalKit/SSignalKit.h>

@interface TGPeerInfoSignals : NSObject

+ (SSignal *)resolveBotDomain:(NSString *)query;

@end
