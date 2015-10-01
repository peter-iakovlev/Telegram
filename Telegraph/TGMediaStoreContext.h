#import "TGModernCache.h"

@interface TGMediaStoreContext : NSObject

+ (TGMediaStoreContext *)instance;

- (TGModernCache *)temporaryFilesCache;

- (NSNumber *)mediaImageAverageColor:(NSString *)key;
- (void)setMediaImageAverageColorForKey:(NSString *)key averageColor:(NSNumber *)averageColor;

- (UIImage *)mediaReducedImage:(NSString *)key attributes:(__autoreleasing NSDictionary **)attributes;
- (void)setMediaReducedImageForKey:(NSString *)key reducedImage:(UIImage *)reducedImage attributes:(NSDictionary *)attributes;

- (UIImage *)mediaImage:(NSString *)key attributes:(__autoreleasing NSDictionary **)attributes;
- (void)setMediaImageForKey:(NSString *)key image:(UIImage *)image attributes:(NSDictionary *)attributes;

- (void)inMediaReducedImageCacheGenerationQueue:(dispatch_block_t)block;

@end
