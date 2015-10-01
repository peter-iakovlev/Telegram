#import "TGMemoryImageCache.h"
#import <SSignalKit/SSignalKit.h>

@interface TGMemoryImageCacheEvent : NSObject

@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, strong, readonly) NSDictionary *attributes;

@end

@interface TGMemoryImageCache (Signals)

- (SSignal *)signalForKey:(NSString *)key;
- (SSignal *)imageSignalForKey:(NSString *)key;

@end
