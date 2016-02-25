#import <UIKit/UIKit.h>

#import <CoreVideo/CoreVideo.h>

@interface TGVTPlayerView : UIView

- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end
