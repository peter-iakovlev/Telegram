#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EMInMemoryImageCache : NSObject

- (instancetype)initWithMaxResidentSize:(NSUInteger)maxResidentSize;

- (void)setImageDataWithSize:(CGSize)size generator:(void (^)(uint8_t *memory, NSUInteger bytesPerRow))generator forKey:(id<NSCopying>)key;
- (UIImage *)imageForKey:(id<NSCopying>)key;

- (void)_debugPrintStats;

@end
