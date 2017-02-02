#import <Foundation/Foundation.h>

@class TGPainting;
@class TGPaintBrush;

@interface TGPaintBrushPreview : NSObject

- (UIImage *)imageForBrush:(TGPaintBrush *)brush size:(CGSize)size;

@end
