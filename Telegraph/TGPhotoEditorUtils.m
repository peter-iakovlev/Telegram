#import "TGPhotoEditorUtils.h"
#import "TGImageUtils.h"
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>

const CGSize TGPhotoEditorResultImageMaxSize = { 1280, 1280 };
const CGSize TGPhotoEditorScreenImageHardLimitSize = { 750, 750 };

CGSize TGPhotoEditorScreenImageMaxSize()
{
    CGSize screenSize = TGScreenSize();
    CGFloat maxSide = MIN(TGPhotoEditorScreenImageHardLimitSize.width, TGScreenScaling() * MIN(screenSize.width, screenSize.height));
    
    return CGSizeMake(maxSide, maxSide);
}

CGSize TGPhotoThumbnailSizeForCurrentScreen()
{
    CGSize screenSize = TGScreenSize();
    CGFloat widescreenWidth = MAX(screenSize.width, screenSize.height);
    
    if ([UIScreen mainScreen].scale >= 2.0f - FLT_EPSILON)
    {
        if (widescreenWidth >= 736.0f - FLT_EPSILON)
        {
            return CGSizeMake(103.0f, 103.0f);
        }
        else if (widescreenWidth >= 667.0f - FLT_EPSILON)
        {
            return CGSizeMake(93.0f, 93.5f);
        }
        else
        {
            return CGSizeMake(78.5f, 78.5f);
        }
    }
    
    return CGSizeMake(78.5f, 78.5f);
}

CGSize TGScaleToSize(CGSize size, CGSize maxSize)
{    
    CGSize newSize = size;
    newSize.width = maxSize.width;
    newSize.height = CGFloor(newSize.width * size.height / size.width);
    
    if (newSize.height > maxSize.height)
    {
        newSize.height = maxSize.height;
        newSize.width = CGFloor(newSize.height * size.width / size.height);
    }
    
    return newSize;
}

CGSize TGScaleToFillSize(CGSize size, CGSize maxSize)
{
    if (size.width < 1)
        size.width = 1;
    
    if (size.height < 1)
        size.height = 1;
    
    if (size.height > size.width)
    {
        size.height = CGFloor(maxSize.width * size.height / MAX(1.0f, size.width));
        size.width = maxSize.width;
    }
    else
    {
        size.width = CGFloor(maxSize.height * size.width / MAX(1.0f, size.height));
        size.height = maxSize.height;
    }
    
    return size;
}

CGFloat TGDegreesToRadians(CGFloat degrees)
{
    return degrees * (CGFloat)M_PI / 180.0f;
}

CGFloat TGRadiansToDegrees(CGFloat radians)
{
    return radians * 180.0f / (CGFloat)M_PI;
}

CGImageRef TGPhotoLanczosResize(UIImage *image, CGSize targetSize)
{
    if (TGOrientationIsSideward(image.imageOrientation, NULL))
        targetSize = CGSizeMake(targetSize.height, targetSize.width);
    
    CGImageRef sourceRef = image.CGImage;
    vImage_Buffer srcBuffer;
    vImage_CGImageFormat format =
    {
        .bitsPerComponent = 8,
        .bitsPerPixel = 32,
        .colorSpace = NULL,
        .bitmapInfo = (CGBitmapInfo)kCGImageAlphaFirst,
        .version = 0,
        .decode = NULL,
        .renderingIntent = kCGRenderingIntentDefault,
    };
    vImage_Error ret = vImageBuffer_InitWithCGImage(&srcBuffer, &format, NULL, sourceRef, kvImageNoFlags);
    if (ret != kvImageNoError)
    {
        free(srcBuffer.data);
        return nil;
    }
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger dstBytesPerRow = bytesPerPixel * (NSUInteger)targetSize.width;
    uint8_t *dstData = (uint8_t *)calloc((NSUInteger)targetSize.height * (NSInteger)targetSize.width * bytesPerPixel, sizeof(uint8_t));
    vImage_Buffer dstBuffer =
    {
        .data = dstData,
        .height = (NSUInteger)targetSize.height,
        .width = (NSUInteger)targetSize.width,
        .rowBytes = dstBytesPerRow
    };
    
    ret = vImageScale_ARGB8888(&srcBuffer, &dstBuffer, NULL, kvImageHighQualityResampling);
    free(srcBuffer.data);
    if (ret != kvImageNoError)
    {
        free(dstData);
        return nil;
    }
    
    ret = kvImageNoError;
    CGImageRef destRef = vImageCreateCGImageFromBuffer(&dstBuffer, &format, NULL, NULL, kvImageNoFlags, &ret);
    free(dstData);
    
    return destRef;
}

UIImage *TGPhotoEditorLegacyCrop(UIImage *image, UIImageOrientation orientation, CGFloat rotation, CGRect rect, CGSize maxSize)
{
    CGSize fittedImageSize = TGFitSize(rect.size, maxSize);
    
    CGSize outputImageSize = fittedImageSize;
    outputImageSize.width = CGFloor(outputImageSize.width);
    outputImageSize.height = CGFloor(outputImageSize.height);
    if (orientation == UIImageOrientationLeft || orientation == UIImageOrientationRight)
        outputImageSize = CGSizeMake(outputImageSize.height, outputImageSize.width);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(outputImageSize.width, outputImageSize.height), true, 1.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, outputImageSize.width, outputImageSize.height));
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    CGSize rotatedContentSize = TGRotatedContentSize(image.size, rotation);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, outputImageSize.width / 2, outputImageSize.height / 2);
    
    transform = CGAffineTransformScale(transform, fittedImageSize.width / rect.size.width, fittedImageSize.height / rect.size.height);
    transform = CGAffineTransformRotate(transform, TGRotationForOrientation(orientation));
    transform = CGAffineTransformTranslate(transform, rotatedContentSize.width / 2 - CGRectGetMidX(rect), rotatedContentSize.height / 2 - CGRectGetMidY(rect));
    transform = CGAffineTransformRotate(transform, rotation);
    CGContextConcatCTM(context, transform);
    
    [image drawInRect:CGRectMake(CGCeil(-image.size.width / 2), CGCeil(-image.size.height / 2), image.size.width, image.size.height)];
    
    UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return croppedImage;
}

UIImage *TGPhotoEditorCrop(UIImage *image, UIImageOrientation orientation, CGFloat rotation, CGRect rect, CGSize maxSize, CGSize originalSize)
{
    if (iosMajorVersion() < 7)
        return TGPhotoEditorLegacyCrop(image, orientation, rotation, rect, maxSize);
    
    CGSize fittedImageSize = TGFitSize(rect.size, maxSize);
    
    CGSize outputImageSize = fittedImageSize;
    outputImageSize.width = CGFloor(outputImageSize.width);
    outputImageSize.height = CGFloor(outputImageSize.height);
    if (TGOrientationIsSideward(orientation, NULL))
        outputImageSize = CGSizeMake(outputImageSize.height, outputImageSize.width);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(outputImageSize.width, outputImageSize.height), true, 1.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, outputImageSize.width, outputImageSize.height));
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, outputImageSize.width / 2, outputImageSize.height / 2);
    
    CGSize scales = CGSizeMake(fittedImageSize.width / rect.size.width, fittedImageSize.height / rect.size.height);

    CGSize rotatedContentSize = TGRotatedContentSize(image.size, rotation);
    transform = CGAffineTransformRotate(transform, TGRotationForOrientation(orientation));
    transform = CGAffineTransformTranslate(transform, (rotatedContentSize.width / 2 - CGRectGetMidX(rect)) * scales.width, (rotatedContentSize.height / 2 - CGRectGetMidY(rect)) * scales.height);
    transform = CGAffineTransformRotate(transform, rotation);
    CGContextConcatCTM(context, transform);
    
    CGSize resizedSize = CGSizeMake(originalSize.width * fittedImageSize.width / rect.size.width, originalSize.height * fittedImageSize.height / rect.size.height);
    CGImageRef resizedImage = TGPhotoLanczosResize(image, resizedSize);
    UIImage *uiImage = [UIImage imageWithCGImage:resizedImage scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(resizedImage);
    
    [uiImage drawAtPoint:CGPointMake(-uiImage.size.width / 2, -uiImage.size.height / 2)];

    UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return croppedImage;
}

CGSize TGRotatedContentSize(CGSize contentSize, CGFloat rotation)
{
    CGAffineTransform t = CGAffineTransformMakeTranslation(contentSize.width / 2, contentSize.height / 2);
    t = CGAffineTransformRotate(t, rotation);
    t = CGAffineTransformTranslate(t, -contentSize.width / 2, -contentSize.height / 2);
    
    return CGRectApplyAffineTransform(CGRectMake(0, 0, contentSize.width, contentSize.height), t).size;
}

UIImageOrientation TGNextCCWOrientationForOrientation(UIImageOrientation orientation)
{
    switch (orientation)
    {
        case UIImageOrientationUp:
            return UIImageOrientationLeft;
            
        case UIImageOrientationLeft:
            return UIImageOrientationDown;
            
        case UIImageOrientationDown:
            return UIImageOrientationRight;
            
        case UIImageOrientationRight:
            return UIImageOrientationUp;
            
        default:
            break;
    }
    
    return UIImageOrientationUp;
}

CGFloat TGRotationForOrientation(UIImageOrientation orientation)
{
    switch (orientation)
    {
        case UIImageOrientationDown:
            return (CGFloat)-M_PI;
            
        case UIImageOrientationLeft:
            return (CGFloat)-M_PI_2;
            
        case UIImageOrientationRight:
            return (CGFloat)M_PI_2;
            
        default:
            break;
    }
    
    return 0.0f;
}

CGFloat TGRotationForInterfaceOrientation(UIInterfaceOrientation orientation)
{
    switch (orientation)
    {
        case UIInterfaceOrientationPortraitUpsideDown:
            return (CGFloat)-M_PI;
            
        case UIInterfaceOrientationLandscapeLeft:
            return (CGFloat)-M_PI_2;
            
        case UIInterfaceOrientationLandscapeRight:
            return (CGFloat)M_PI_2;
            
        default:
            break;
    }
    
    return 0.0f;
}

CGAffineTransform TGTransformForVideoOrientation(AVCaptureVideoOrientation orientation, bool mirrored)
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (orientation)
    {
        case UIDeviceOrientationLandscapeRight:
        {
            transform = CGAffineTransformMakeRotation((CGFloat)M_PI);
        }
            break;
            
        case UIDeviceOrientationPortrait:
        {
            transform = CGAffineTransformMakeRotation((CGFloat)M_PI_2);
        }
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
        {
            transform = CGAffineTransformMakeRotation((CGFloat)M_PI_2 * 3);
        }
            break;
            
        default:
            break;
    }
    
    if (mirrored)
        transform = CGAffineTransformScale(transform, 1, -1);
    
    return transform;
}

bool TGOrientationIsSideward(UIImageOrientation orientation, bool *mirrored)
{
    if (orientation == UIImageOrientationLeft || orientation == UIImageOrientationRight)
    {
        if (mirrored != NULL)
            *mirrored = false;
        
        return true;
    }
    else if (orientation == UIImageOrientationLeftMirrored || orientation == UIImageOrientationRightMirrored)
    {
        if (mirrored != NULL)
            *mirrored = true;
        
        return true;
    }
    
    return false;
}

UIImageOrientation TGVideoOrientationForAsset(AVAsset *asset, bool *mirrored)
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGAffineTransform t = videoTrack.preferredTransform;
    double videoRotation = atan2((float)t.b, (float)t.a);
    
    if (mirrored != NULL)
    {
        UIView *tempView = [[UIView alloc] init];
        tempView.transform = t;
        CGSize scale = CGSizeMake([[tempView.layer valueForKeyPath: @"transform.scale.x"] floatValue],
                                  [[tempView.layer valueForKeyPath: @"transform.scale.y"] floatValue]);
        
        *mirrored = (scale.width < 0);
    }
    
    if (fabs(videoRotation - M_PI) < FLT_EPSILON)
        return UIImageOrientationLeft;
    else if (fabs(videoRotation - M_PI_2) < FLT_EPSILON)
        return UIImageOrientationUp;
    else if (fabs(videoRotation + M_PI_2) < FLT_EPSILON)
        return UIImageOrientationDown;
    else
        return UIImageOrientationRight;
}

UIImageOrientation TGVideoFinalOrientationForOrientation(UIImageOrientation videoOrientation, UIImageOrientation cropOrientation)
{
    switch (videoOrientation)
    {
        case UIImageOrientationUp:
            return cropOrientation;
            
        case UIImageOrientationDown:
        {
            switch (cropOrientation)
            {
                case UIImageOrientationDown:
                    return UIImageOrientationUp;
                    
                case UIImageOrientationLeft:
                    return UIImageOrientationRight;
                    
                case UIImageOrientationRight:
                    return UIImageOrientationLeft;
                    
                default:
                    return videoOrientation;
            }
        }
            break;
            
        case UIImageOrientationLeft:
        {
            switch (cropOrientation)
            {
                case UIImageOrientationDown:
                    return UIImageOrientationRight;
                    
                case UIImageOrientationLeft:
                    return UIImageOrientationDown;
                    
                case UIImageOrientationRight:
                    return UIImageOrientationUp;
                    
                default:
                    return videoOrientation;
            }
        }
            break;
            
        case UIImageOrientationRight:
        {
            switch (cropOrientation)
            {
                case UIImageOrientationDown:
                    return UIImageOrientationLeft;
                    
                case UIImageOrientationLeft:
                    return UIImageOrientationUp;

                case UIImageOrientationRight:
                    return UIImageOrientationDown;

                default:
                    return videoOrientation;
            }
        }
            break;
            
        default:
            return videoOrientation;
    }
}

CGAffineTransform TGVideoTransformForOrientation(UIImageOrientation orientation, CGSize size, CGRect cropRect, bool mirror)
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    if (mirror)
    {
        if (TGOrientationIsSideward(orientation, NULL))
        {
            cropRect.origin.y *= - 1;
            transform = CGAffineTransformTranslate(transform, 0, size.height);
            transform = CGAffineTransformScale(transform, 1.0f, -1.0f);
        }
        else
        {
            cropRect.origin.x = size.height - cropRect.origin.x;
            transform = CGAffineTransformScale(transform, -1.0f, 1.0f);
        }
    }
    
    switch (orientation)
    {
        case UIImageOrientationUp:
        {
            transform = CGAffineTransformRotate(CGAffineTransformTranslate(transform, size.height - cropRect.origin.x, 0 - cropRect.origin.y), (CGFloat)M_PI_2);
        }
            break;
            
        case UIImageOrientationDown:
        {
            transform = CGAffineTransformRotate(CGAffineTransformTranslate(transform, 0 - cropRect.origin.x, size.width - cropRect.origin.y), (CGFloat)-M_PI_2);
        }
            break;
            
        case UIImageOrientationRight:
        {
            transform = CGAffineTransformRotate(CGAffineTransformTranslate(transform, 0 - cropRect.origin.x, 0 - cropRect.origin.y), 0);
        }
            break;
            
        case UIImageOrientationLeft:
        {
            transform = CGAffineTransformRotate(CGAffineTransformTranslate(transform, size.width - cropRect.origin.x, size.height - cropRect.origin.y), (CGFloat)M_PI);
        }
            break;
            
        default:
            break;
    }
    
    return transform;
}

CGAffineTransform TGVideoCropTransformForOrientation(UIImageOrientation orientation, CGSize size, bool rotateSize)
{
    if (rotateSize && TGOrientationIsSideward(orientation, NULL))
        size = CGSizeMake(size.height, size.width);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (orientation)
    {
        case UIImageOrientationDown:
        {
            transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(size.width, size.height), (CGFloat)M_PI);
        }
            break;
            
        case UIImageOrientationRight:
        {
            transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(size.width, 0), (CGFloat)M_PI_2);
        }
            break;
            
        case UIImageOrientationLeft:
        {
            transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(0, size.height), (CGFloat)-M_PI_2);
        }
            break;
            
        default:
            break;
    }
    
    return transform;
}

CGSize TGTransformDimensionsWithTransform(CGSize dimensions, CGAffineTransform transform)
{
    CGRect rect = CGRectMake(0, 0, dimensions.width, dimensions.height);
    rect = CGRectApplyAffineTransform(rect, transform);
    return rect.size;
}

CGFloat TGRubberBandDistance(CGFloat offset, CGFloat dimension)
{
    const CGFloat constant = 0.55f;
    CGFloat result = (constant * ABS(offset) * dimension) / (dimension + constant * ABS(offset));

    return (offset < 0.0f) ? -result : result;
}

bool _CGPointEqualToPointWithEpsilon(CGPoint point1, CGPoint point2, CGFloat epsilon)
{
    CGFloat absEpsilon = ABS(epsilon);
    bool xOK = ABS(point1.x - point2.x) < absEpsilon;
    bool yOK = ABS(point1.y - point2.y) < absEpsilon;
    
    return xOK && yOK;
}

bool _CGRectEqualToRectWithEpsilon(CGRect rect1, CGRect rect2, CGFloat epsilon)
{
    CGFloat absEpsilon = ABS(epsilon);
    bool xOK = ABS(rect1.origin.x - rect2.origin.x) < absEpsilon;
    bool yOK = ABS(rect1.origin.y - rect2.origin.y) < absEpsilon;
    bool wOK = ABS(rect1.size.width - rect2.size.width) < absEpsilon * 2;
    bool hOK = ABS(rect1.size.height - rect2.size.height) < absEpsilon * 2;
    
    return xOK && yOK && wOK && hOK;
}
