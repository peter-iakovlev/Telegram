#import "TGModernCache.h"

#import <SSignalKit/SSignalKit.h>

@interface TGModernCache (SSignal)

- (SSignal *)cachedItemForKey:(NSData *)key;

@end
