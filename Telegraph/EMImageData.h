#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EMImageData : NSObject

@property (nonatomic, readonly) CGSize size;
@property (nonatomic) NSUInteger timestamp;

- (instancetype)initWithSize:(CGSize)size generator:(void (^)(uint8_t *memory, NSUInteger bytesPerRow))generator image:(__autoreleasing UIImage **)image;

- (UIImage *)image;
- (bool)isDiscarded;

@end
