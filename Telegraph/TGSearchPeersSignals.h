#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

@interface TGSearchPeersSignals : NSObject

+ (SSignal *)searchPeersWithQuery:(NSString *)query;

@end
