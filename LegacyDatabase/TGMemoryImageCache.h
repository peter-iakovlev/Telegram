/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@interface TGMemoryImageCache : NSObject

- (instancetype)initWithSoftMemoryLimit:(NSUInteger)softMemoryLimit hardMemoryLimit:(NSUInteger)hardMemoryLimit;

- (void)setImage:(UIImage *)image forKey:(NSString *)key attributes:(NSDictionary *)attributes;
- (UIImage *)imageForKey:(NSString *)key attributes:(__autoreleasing NSDictionary **)attributes;
- (void)setAverageColor:(uint32_t)color forKey:(NSString *)key;
- (bool)averageColorForKey:(NSString *)key color:(uint32_t *)color;

@end
