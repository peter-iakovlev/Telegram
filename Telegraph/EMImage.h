#import <UIKit/UIKit.h>

@interface EMImage : UIImage

- (instancetype)initWithCGImage:(CGImageRef)image data:(NSPurgeableData *)data;

@end
