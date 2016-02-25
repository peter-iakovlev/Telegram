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

+ (instancetype)editAdjustmentsWithDictionary:(NSDictionary *)dictionary
{
    if (dictionary.count == 0)
        return nil;
    
    TGVideoEditAdjustments *adjustments = [[[self class] alloc] init];
    if (dictionary[@"cropOrientation"])
        adjustments->_cropOrientation = [dictionary[@"cropOrientation"] integerValue];
    if (dictionary[@"cropRect"])
        adjustments->_cropRect = [dictionary[@"cropRect"] CGRectValue];
    if (dictionary[@"trimStart"] || dictionary[@"trimEnd"])
    {
        adjustments->_trimStartValue = [dictionary[@"trimStart"] doubleValue];
        adjustments->_trimEndValue = [dictionary[@"trimEnd"] doubleValue];
    }
    if (dictionary[@"originalSize"])
        adjustments->_originalSize = [dictionary[@"originalSize"] CGSizeValue];
    
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

- (bool)cropOrRotationAppliedForAvatar:(bool)forAvatar
{
    return [self cropAppliedForAvatar:forAvatar] || [self rotationApplied];
}

- (bool)rotationApplied
{
    return (self.cropOrientation != UIImageOrientationUp);
}

- (bool)trimApplied
{
    return (self.trimStartValue > DBL_EPSILON || self.trimEndValue > DBL_EPSILON);
}

- (bool)isDefaultValuesForAvatar:(bool)forAvatar
{
    return ![self cropAppliedForAvatar:forAvatar];
}

- (NSDictionary *)dictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"cropOrientation"] = @(self.cropOrientation);
    if ([self cropAppliedForAvatar:false])
        dict[@"cropRect"] = [NSValue valueWithCGRect:self.cropRect];
    
    if (self.trimStartValue > DBL_EPSILON || self.trimEndValue > DBL_EPSILON)
    {
        dict[@"trimStart"] = @(self.trimStartValue);
        dict[@"trimEnd"] = @(self.trimEndValue);
    }
    
    dict[@"originalSize"] = [NSValue valueWithCGSize:self.originalSize];
    
    return dict;
}

- (bool)isCropEqualWith:(id<TGMediaEditAdjustments>)adjusments
{
    return (_CGRectEqualToRectWithEpsilon(self.cropRect, adjusments.cropRect, [self _cropRectEpsilon]));
}

- (bool)isCropAndRotationEqualWith:(id<TGMediaEditAdjustments>)adjusments
{
    return (_CGRectEqualToRectWithEpsilon(self.cropRect, adjusments.cropRect, [self _cropRectEpsilon])) && self.cropOrientation == ((TGVideoEditAdjustments *)adjusments).cropOrientation;
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
