#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#ifdef __cplusplus
extern "C" {
#endif
    
CGSize TGScaleToSize(CGSize size, CGSize maxSize);
CGSize TGScaleToFillSize(CGSize size, CGSize maxSize);
    
CGFloat TGDegreesToRadians(CGFloat degrees);
CGFloat TGRadiansToDegrees(CGFloat radians);
    
UIImage *TGPhotoEditorCrop(UIImage *image, UIImageOrientation orientation, CGFloat rotation, CGRect rect, CGSize maxSize, CGSize originalSize);
CGSize TGRotatedContentSize(CGSize contentSize, CGFloat rotation);
    
UIImageOrientation TGNextCCWOrientationForOrientation(UIImageOrientation orientation);
CGFloat TGRotationForOrientation(UIImageOrientation orientation);
CGFloat TGRotationForInterfaceOrientation(UIInterfaceOrientation orientation);
CGAffineTransform TGTransformForVideoOrientation(AVCaptureVideoOrientation orientation, bool mirrored);
    
bool TGOrientationIsSideward(UIImageOrientation orientation, bool *mirrored);
    
UIImageOrientation TGVideoOrientationForAsset(AVAsset *asset, bool *mirrored);
CGAffineTransform TGVideoTransformForOrientation(UIImageOrientation orientation, CGSize size, CGRect cropRect, bool mirror);
CGAffineTransform TGVideoCropTransformForOrientation(UIImageOrientation orientation, CGSize size, bool rotateSize);
    
CGSize TGTransformDimensionsWithTransform(CGSize dimensions, CGAffineTransform transform);
    
CGFloat TGRubberBandDistance(CGFloat offset, CGFloat dimension);
    
bool _CGPointEqualToPointWithEpsilon(CGPoint point1, CGPoint point2, CGFloat epsilon);
bool _CGRectEqualToRectWithEpsilon(CGRect rect1, CGRect rect2, CGFloat epsilon);
    
CGSize TGPhotoThumbnailSizeForCurrentScreen();
CGSize TGPhotoEditorScreenImageMaxSize();
    
extern const CGSize TGPhotoEditorResultImageMaxSize;
    
#ifdef __cplusplus
}
#endif
