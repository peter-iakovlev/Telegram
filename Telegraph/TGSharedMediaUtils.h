#import <Foundation/Foundation.h>

#import <LegacyComponents/TGMemoryImageCache.h>
#import <SSignalKit/SSignalKit.h>
#import <LegacyComponents/TGModernCache.h>
#import "EMInMemoryImageCache.h"

@interface TGSharedMediaUtils : NSObject

+ (TGMemoryImageCache *)sharedMediaMemoryImageCache;
+ (EMInMemoryImageCache *)inMemoryImageCache;
+ (SThreadPool *)sharedMediaImageProcessingThreadPool;
+ (TGModernCache *)sharedMediaTemporaryPersistentCache;

@end
