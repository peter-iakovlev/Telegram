#import <Foundation/Foundation.h>

#import "TGMemoryImageCache.h"
#import <SSignalKit/SSignalKit.h>
#import "TGModernCache.h"
#import <Elements/Elements.h>

@interface TGSharedMediaUtils : NSObject

+ (TGMemoryImageCache *)sharedMediaMemoryImageCache;
+ (EMInMemoryImageCache *)inMemoryImageCache;
+ (SThreadPool *)sharedMediaImageProcessingThreadPool;
+ (TGModernCache *)sharedMediaTemporaryPersistentCache;

@end
