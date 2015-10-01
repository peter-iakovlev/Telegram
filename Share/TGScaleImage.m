#import "TGScaleImage.h"

UIImage *TGScaleImage(UIImage *sourceImage, CGSize pixelSize)
{
    UIGraphicsBeginImageContextWithOptions(pixelSize, true, 1.0f);
    [sourceImage drawInRect:CGRectMake(0.0f, 0.0f, pixelSize.width, pixelSize.height) blendMode:kCGBlendModeCopy alpha:1.0f];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}
