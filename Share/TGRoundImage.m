#import "TGRoundImage.h"

UIImage *TGRoundImage(UIImage *sourceImage, CGSize size)
{
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [sourceImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height) blendMode:kCGBlendModeCopy alpha:1.0f];
    
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0.0f, size.height / 2.0f);
    CGContextAddArcToPoint(context, 0.0f, 0.0f, size.width / 2.0f, 0.0f, size.width / 2.0f);
    CGContextAddLineToPoint(context, 0.0f, 0.0f);
    CGContextAddLineToPoint(context, 0.0f, size.height / 2.0f);
    CGContextFillPath(context);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, size.width / 2.0f, 0.0f);
    CGContextAddArcToPoint(context, size.width, 0.0f, size.width, size.height / 2.0f, size.width / 2.0f);
    CGContextAddLineToPoint(context, size.width, 0.0f);
    CGContextAddLineToPoint(context, size.width / 2.0f, 0.0f);
    CGContextFillPath(context);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, size.width, size.height / 2.0f);
    CGContextAddArcToPoint(context, size.width, size.height, size.width / 2.0f, size.height, size.width / 2.0f);
    CGContextAddLineToPoint(context, size.width, size.height);
    CGContextAddLineToPoint(context, size.width, size.height / 2.0f);
    CGContextFillPath(context);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, size.width / 2.0f, size.height);
    CGContextAddArcToPoint(context, 0.0f, size.height, 0.0f, size.height / 2.0f, size.width / 2.0f);
    CGContextAddLineToPoint(context, 0.0f, size.height);
    CGContextAddLineToPoint(context, size.width / 2.0f, size.height);
    CGContextFillPath(context);
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}
