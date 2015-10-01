#import "TGVideoEditAdjustments.h"

#import "TGPhotoEditorUtils.h"

@implementation TGVideoEditAdjustments

@synthesize originalSize = _originalSize;
@synthesize cropRect = _cropRect;
@synthesize cropOrientation = _cropOrientation;
@synthesize cropLockedAspectRatio = _cropLockedAspectRatio;

+ (instancetype)editAdjustmentsWithOriginalSize:(CGSize)originalSize
                                       cropRect:(CGRect)cropRect
                                cropOrientation:(UIImageOrientation)cropOrientation
                          cropLockedAspectRatio:(CGFloat)cropLockedAspectRatio
                                 trimStartValue:(NSTimeInterval)trimStartValue
                                   trimEndValue:(NSTimeInterval)trimEndValue
{
    TGVideoEditAdjustments *adjustments = [[[self class] alloc] init];
    adjustments->_originalSize = originalSize;
    adjustments->_cropRect = cropRect;
    adjustments->_cropOrientation = cropOrientation;
    adjustments->_cropLockedAspectRatio = cropLockedAspectRatio;
    adjustments->_trimStartValue = trimStartValue;
    adjustments->_trimEndValue = trimEndValue;
    
    if (trimStartValue > trimEndValue)
        return nil;
    
    return adjustments;
}

- (bool)cropAppliedForAvatar:(bool)__unused forAvatar
{
    CGRect defaultCropRect = CGRectMake(0, 0, _originalSize.width, _originalSize.height);
    
    if (!_CGRectEqualToRectWithEpsilon(self.cropRect, defaultCropRect, [self _cropRectEpsilon]))
        return true;
        
    if (self.cropLockedAspectRatio > FLT_EPSILON)
        return true;
    
    return false;
}

- (bool)rotationApplied
{
    if (self.cropOrientation != UIImageOrientationUp)
        return true;
    
    return false;
}

- (bool)isDefaultValuesForAvatar:(bool)forAvatar
{
    return ![self cropAppliedForAvatar:forAvatar];
}

- (BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    
    TGVideoEditAdjustments *adjustments = (TGVideoEditAdjustments *)object;
    
    if (!_CGRectEqualToRectWithEpsilon(self.cropRect, adjustments.cropRect, [self _cropRectEpsilon]))
        return NO;
    
    if (self.cropOrientation != adjustments.cropOrientation)
        return NO;
    
    if (ABS(self.cropLockedAspectRatio - adjustments.cropLockedAspectRatio) > FLT_EPSILON)
        return NO;
    
    if (fabs(self.trimStartValue - adjustments.trimStartValue) > FLT_EPSILON)
        return NO;
    
    if (fabs(self.trimEndValue - adjustments.trimEndValue) > FLT_EPSILON)
        return NO;
    
    return YES;
}

- (CGFloat)_cropRectEpsilon
{
    return MAX(_originalSize.width, _originalSize.height) * 0.005f;
}

@end
