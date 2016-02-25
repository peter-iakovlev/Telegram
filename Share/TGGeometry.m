#import "TGGeometry.h"

CGSize TGFitSize(CGSize size, CGSize maxSize)
{
    if (size.width < 1.0f)
        return CGSizeZero;
    if (size.height < 1.0f)
        return CGSizeZero;
    
    if (size.width > maxSize.width)
    {
        size.height = (CGFloat)floor((size.height * maxSize.width / size.width));
        size.width = maxSize.width;
    }
    if (size.height > maxSize.height)
    {
        size.width = (CGFloat)floor((size.width * maxSize.height / size.height));
        size.height = maxSize.height;
    }
    return size;
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
