#import "TGBlurEffect.h"
#import <objc/runtime.h>

@interface TGCropBlur : TGBlurEffect

@end

@implementation TGCropBlur

+ (instancetype)effectWithStyle:(UIBlurEffectStyle)style
{
    id result = [super effectWithStyle:style radius:20.0f];
    object_setClass(result, self);
    
    return result;
}

- (id)effectSettings
{
    id settings = [super effectSettings];
    [settings setValue:@1.0f forKey:@"saturationDeltaFactor"];
    [settings setValue:@false forKey:@"blursWithHardEdges"];
    [settings setValue:@false forKey:@"usesGrayscaleTintView"];
    return settings;
}

- (id)copyWithZone:(NSZone *)zone
{
    id result = [super copyWithZone:zone];
    object_setClass(result, [self class]);
    return result;
}

@end


@interface TGItemPreviewBlur : TGBlurEffect

@end

@implementation TGItemPreviewBlur

+ (instancetype)effectWithStyle:(UIBlurEffectStyle)style
{
    id result = [super effectWithStyle:style radius:10.0f];
    object_setClass(result, self);
    
    return result;
}

- (id)effectSettings
{
    id settings = [super effectSettings];
    [settings setValue:@1.2f forKey:@"saturationDeltaFactor"];
    [settings setValue:@true forKey:@"blursWithHardEdges"];
    return settings;
}

- (id)copyWithZone:(NSZone *)zone
{
    id result = [super copyWithZone:zone];
    object_setClass(result, [self class]);
    return result;
}

@end


@interface TGCallBlur : TGBlurEffect

@end

@implementation TGCallBlur

+ (instancetype)effectWithStyle:(UIBlurEffectStyle)style
{
    id result = [super effectWithStyle:style radius:20.0f];
    object_setClass(result, self);
    
    return result;
}

- (id)effectSettings
{
    id settings = [super effectSettings];
    [settings setValue:@0.8f forKey:@"saturationDeltaFactor"];
    [settings setValue:@false forKey:@"blursWithHardEdges"];
    [settings setValue:@false forKey:@"usesGrayscaleTintView"];
    return settings;
}

- (id)copyWithZone:(NSZone *)zone
{
    id result = [super copyWithZone:zone];
    object_setClass(result, [self class]);
    return result;
}

@end


@interface TGBlurEffect ()
{
    CGFloat _radius;
}
@end

@implementation TGBlurEffect

+ (instancetype)effectWithStyle:(UIBlurEffectStyle)style radius:(CGFloat)radius
{
    id result = [super effectWithStyle:style];
    object_setClass(result, self);
    ((TGBlurEffect *)result)->_radius = radius;
    
    return result;
}

- (id)effectSettings
{
    id settings = [super effectSettings];
    [settings setValue:@(_radius) forKey:@"blurRadius"];
    return settings;
}

- (id)copyWithZone:(NSZone*)zone
{
    id result = [super copyWithZone:zone];
    object_setClass(result, [self class]);
    ((TGBlurEffect *)result)->_radius = _radius;
    return result;
}

+ (instancetype)forceTouchBlurEffect
{
    return (TGBlurEffect *)[TGItemPreviewBlur effectWithStyle:UIBlurEffectStyleLight];
}

+ (instancetype)cropBlurEffect
{
    return (TGBlurEffect *)[TGCropBlur effectWithStyle:UIBlurEffectStyleDark];
}

+ (instancetype)callBlurEffect
{
    return (TGBlurEffect *)[TGCallBlur effectWithStyle:UIBlurEffectStyleDark];
}


@end

