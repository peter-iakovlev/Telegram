#import <Foundation/Foundation.h>

@class TGPaintState;
@class TGPaintPanGestureRecognizer;

@interface TGPaintInput : NSObject

@property (nonatomic, assign) CGAffineTransform transform;

- (void)gestureBegan:(TGPaintPanGestureRecognizer *)recognizer;
- (void)gestureMoved:(TGPaintPanGestureRecognizer *)recognizer;
- (void)gestureEnded:(TGPaintPanGestureRecognizer *)recognizer;
- (void)gestureCanceled:(TGPaintPanGestureRecognizer *)recognizer;

@end
