/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGMessageImageViewOverlayView.h"

#import <pop/POP.h>

typedef enum {
    TGMessageImageViewOverlayViewTypeDownload = 1,
    TGMessageImageViewOverlayViewTypeProgress = 2,
    TGMessageImageViewOverlayViewTypePlay = 3,
    TGMessageImageViewOverlayViewTypeSecret = 4,
    TGMessageImageViewOverlayViewTypeSecretViewed = 5,
    TGMessageImageViewOverlayViewTypeSecretProgress = 6
} TGMessageImageViewOverlayViewType;

@interface TGMessageImageViewOverlayLayer : CALayer
{
}

@property (nonatomic) int overlayStyle;
@property (nonatomic) CGFloat progress;
@property (nonatomic) bool cancelEnabled;
@property (nonatomic) int type;
@property (nonatomic, strong) UIImage *blurredBackgroundImage;
@property (nonatomic, strong) UIColor *imageBackgroundColor;

@end

@implementation TGMessageImageViewOverlayLayer

- (instancetype)initWithLayer:(id)layer
{
    self = [super init];
    if (self != nil)
    {
        if ([layer isKindOfClass:[TGMessageImageViewOverlayLayer class]])
        {
            _type = ((TGMessageImageViewOverlayLayer *)layer).type;
            _overlayStyle = ((TGMessageImageViewOverlayLayer *)layer).overlayStyle;
            _cancelEnabled = ((TGMessageImageViewOverlayLayer *)layer).cancelEnabled;
        }
    }
    return self;
}

- (void)setOverlayStyle:(int)overlayStyle
{
    if (_overlayStyle != overlayStyle)
    {
        _overlayStyle = overlayStyle;
        [self setNeedsDisplay];
    }
}

- (void)setBlurredBackgroundImage:(UIImage *)blurredBackgroundImage
{
    if (_blurredBackgroundImage != blurredBackgroundImage)
    {
        _blurredBackgroundImage = blurredBackgroundImage;
        [self setNeedsDisplay];
    }
}

- (void)setImageBackgroundColor:(UIColor *)imageBackgroundColor
{
    if (_imageBackgroundColor != imageBackgroundColor)
    {
        _imageBackgroundColor = imageBackgroundColor;
        [self setNeedsDisplay];
    }
}

- (void)setDownload
{
    if (_type != TGMessageImageViewOverlayViewTypeDownload)
    {
        [self pop_removeAnimationForKey:@"progress"];
        [self pop_removeAnimationForKey:@"progressAmbient"];
        
        _type = TGMessageImageViewOverlayViewTypeDownload;
        [self setNeedsDisplay];
    }
}

- (void)setPlay
{
    if (_type != TGMessageImageViewOverlayViewTypePlay)
    {
        [self pop_removeAnimationForKey:@"progress"];
        [self pop_removeAnimationForKey:@"progressAmbient"];
        
        _type = TGMessageImageViewOverlayViewTypePlay;
        [self setNeedsDisplay];
    }
}

- (void)setSecret:(bool)isViewed
{
    int newType = 0;
    if (isViewed)
        newType = TGMessageImageViewOverlayViewTypeSecretViewed;
    else
        newType = TGMessageImageViewOverlayViewTypeSecret;
    
    if (_type != newType)
    {
        [self pop_removeAnimationForKey:@"progress"];
        [self pop_removeAnimationForKey:@"progressAmbient"];
        
        _type = newType;
        [self setNeedsDisplay];
    }
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

+ (void)_addAmbientProgressAnimation:(TGMessageImageViewOverlayLayer *)layer
{
    POPBasicAnimation *ambientProgress = [self pop_animationForKey:@"progressAmbient"];
    
    ambientProgress = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
    __weak TGMessageImageViewOverlayLayer *weakLayer = layer;
    ambientProgress.fromValue = @((CGFloat)0.0f);
    ambientProgress.toValue = @((CGFloat)M_PI * 2.0f);
    ambientProgress.duration = 1.6;
    ambientProgress.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    [ambientProgress setCompletionBlock:^(__unused POPAnimation *animation, BOOL completed)
    {
        __strong TGMessageImageViewOverlayLayer *strongLayer = weakLayer;
        if (completed && strongLayer != nil && strongLayer->_type == TGMessageImageViewOverlayViewTypeProgress)
        {
            [TGMessageImageViewOverlayLayer _addAmbientProgressAnimation:strongLayer];
        }
    }];
    
    [layer pop_addAnimation:ambientProgress forKey:@"progressAmbient"];
}

- (void)setProgress:(float)progress cancelEnabled:(bool)cancelEnabled animated:(bool)animated
{
    if (_type != TGMessageImageViewOverlayViewTypeProgress || ABS(_progress - progress) > FLT_EPSILON)
    {
        if (_type != TGMessageImageViewOverlayViewTypeProgress)
            _progress = 0.0f;
        
        //if ([self pop_animationForKey:@"progressAmbient"] == nil)
        //    [TGMessageImageViewOverlayLayer _addAmbientProgressAnimation:self];
        
        _type = TGMessageImageViewOverlayViewTypeProgress;
        _cancelEnabled = cancelEnabled;
        
        if (animated)
        {
            POPBasicAnimation *animation = [self pop_animationForKey:@"progress"];
            if (animation != nil)
            {
                animation.toValue = @((CGFloat)progress);
            }
            else
            {
                animation = [POPBasicAnimation animation];
                animation.property = [POPAnimatableProperty propertyWithName:@"progress" initializer:^(POPMutableAnimatableProperty *prop)
                {
                    prop.readBlock = ^(TGMessageImageViewOverlayLayer *layer, CGFloat values[])
                    {
                        values[0] = layer.progress;
                    };
                    
                    prop.writeBlock = ^(TGMessageImageViewOverlayLayer *layer, const CGFloat values[])
                    {
                        layer.progress = values[0];
                    };
                    
                    prop.threshold = 0.01f;
                }];
                animation.fromValue = @(_progress);
                animation.toValue = @(progress);
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
                animation.duration = 0.5;
                [self pop_addAnimation:animation forKey:@"progress"];
            }
        }
        else
        {
            _progress = progress;
            
            [self setNeedsDisplay];
        }
    }
}

- (void)setSecretProgress:(float)progress animated:(bool)animated
{
    if (_type != TGMessageImageViewOverlayViewTypeSecretProgress || ABS(_progress - progress) > FLT_EPSILON)
    {
        if (_type != TGMessageImageViewOverlayViewTypeSecretProgress)
        {
            _progress = 0.0f;
            [self setNeedsDisplay];
        }
        
        _type = TGMessageImageViewOverlayViewTypeSecretProgress;
        
        if (animated)
        {
            POPBasicAnimation *animation = [self pop_animationForKey:@"progress"];
            if (animation != nil)
            {
                animation.toValue = @((CGFloat)progress);
            }
            else
            {
                animation = [POPBasicAnimation animation];
                animation.property = [POPAnimatableProperty propertyWithName:@"progress" initializer:^(POPMutableAnimatableProperty *prop)
                {
                    prop.readBlock = ^(TGMessageImageViewOverlayLayer *layer, CGFloat values[])
                    {
                        values[0] = layer.progress;
                    };
                    
                    prop.writeBlock = ^(TGMessageImageViewOverlayLayer *layer, const CGFloat values[])
                    {
                        layer.progress = values[0];
                    };
                    
                    prop.threshold = 0.01f;
                }];
                animation.fromValue = @(_progress);
                animation.toValue = @(progress);
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
                animation.duration = 0.5;
                [self pop_addAnimation:animation forKey:@"progress"];
            }
        }
        else
        {
            _progress = progress;
            
            [self setNeedsDisplay];
        }
    }
}

- (void)drawInContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);

    switch (_type)
    {
        case TGMessageImageViewOverlayViewTypeDownload:
        {
            const CGFloat diameter = 50.0f;
            const CGFloat lineWidth = 2.0f;
            const CGFloat height = 24.0f;
            const CGFloat width = 20.0f;
            
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            
            if (_overlayStyle == TGMessageImageViewOverlayStyleDefault)
            {
                CGContextSetFillColorWithColor(context, UIColorRGBA(0xffffffff, 0.8f).CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            }
            else
            {
                CGContextSetStrokeColorWithColor(context, UIColorRGB(0xeaeaea).CGColor);
                CGContextSetLineWidth(context, 1.5f);
                CGContextStrokeEllipseInRect(context, CGRectMake(1.5f / 2.0f, 1.5f / 2.0f, diameter - 1.5f, diameter - 1.5f));
            }
            
            if (_overlayStyle == TGMessageImageViewOverlayStyleDefault)
                CGContextSetStrokeColorWithColor(context, UIColorRGBA(0xff000000, 0.55f).CGColor);
            else
                CGContextSetStrokeColorWithColor(context, TGAccentColor().CGColor);
            
            CGContextSetLineCap(context, kCGLineCapRound);
            CGContextSetLineWidth(context, lineWidth);
            
            CGPoint mainLine[] = {
                CGPointMake((diameter - lineWidth) / 2.0f + lineWidth / 2.0f, (diameter - height) / 2.0f + lineWidth / 2.0f),
                CGPointMake((diameter - lineWidth) / 2.0f + lineWidth / 2.0f, (diameter + height) / 2.0f - lineWidth / 2.0f)
            };
            
            CGPoint arrowLine[] = {
                CGPointMake((diameter - lineWidth) / 2.0f + lineWidth / 2.0f - width / 2.0f, (diameter + height) / 2.0f + lineWidth / 2.0f - width / 2.0f),
                CGPointMake((diameter - lineWidth) / 2.0f + lineWidth / 2.0f, (diameter + height) / 2.0f + lineWidth / 2.0f),
                CGPointMake((diameter - lineWidth) / 2.0f + lineWidth / 2.0f, (diameter + height) / 2.0f + lineWidth / 2.0f),
                CGPointMake((diameter - lineWidth) / 2.0f + lineWidth / 2.0f + width / 2.0f, (diameter + height) / 2.0f + lineWidth / 2.0f - width / 2.0f),
            };
            
            if (_overlayStyle == TGMessageImageViewOverlayStyleDefault)
                CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
            CGContextStrokeLineSegments(context, mainLine, sizeof(mainLine) / sizeof(mainLine[0]));
            CGContextStrokeLineSegments(context, arrowLine, sizeof(arrowLine) / sizeof(arrowLine[0]));
            
            if (_overlayStyle == TGMessageImageViewOverlayStyleDefault)
            {
                CGContextSetBlendMode(context, kCGBlendModeNormal);
                CGContextSetStrokeColorWithColor(context, UIColorRGBA(0x000000, 0.55f).CGColor);
                CGContextStrokeLineSegments(context, arrowLine, sizeof(arrowLine) / sizeof(arrowLine[0]));
                
                CGContextSetBlendMode(context, kCGBlendModeCopy);
                CGContextStrokeLineSegments(context, mainLine, sizeof(mainLine) / sizeof(mainLine[0]));
            }
            
            break;
        }
        case TGMessageImageViewOverlayViewTypeProgress:
        {
            const CGFloat diameter = 50.0f;
            const CGFloat lineWidth = 2.0f;
            const CGFloat crossSize = 16.0f;
            
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            
            if (_overlayStyle == TGMessageImageViewOverlayStyleDefault)
            {
                CGContextSetFillColorWithColor(context, UIColorRGBA(0x000000, 0.7f).CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            }
            else
            {
                CGContextSetStrokeColorWithColor(context, UIColorRGB(0xeaeaea).CGColor);
                CGContextSetLineWidth(context, 1.5f);
                CGContextStrokeEllipseInRect(context, CGRectMake(1.5f / 2.0f, 1.5f / 2.0f, diameter - 1.5f, diameter - 1.5f));
            }
            
                CGContextSetLineCap(context, kCGLineCapRound);
            CGContextSetLineWidth(context, lineWidth);
            
                CGPoint crossLine[] = {
                    CGPointMake((diameter - crossSize) / 2.0f, (diameter - crossSize) / 2.0f),
                    CGPointMake((diameter + crossSize) / 2.0f, (diameter + crossSize) / 2.0f),
                    CGPointMake((diameter + crossSize) / 2.0f, (diameter - crossSize) / 2.0f),
                    CGPointMake((diameter - crossSize) / 2.0f, (diameter + crossSize) / 2.0f),
                };
                
                if (_overlayStyle == TGMessageImageViewOverlayStyleDefault)
                    CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
                else
                    CGContextSetStrokeColorWithColor(context, TGAccentColor().CGColor);
            
            if (_cancelEnabled)
                CGContextStrokeLineSegments(context, crossLine, sizeof(crossLine) / sizeof(crossLine[0]));
            
            if (_overlayStyle == TGMessageImageViewOverlayStyleDefault)
            {
                CGContextSetBlendMode(context, kCGBlendModeNormal);
                CGContextSetStrokeColorWithColor(context, UIColorRGBA(0xffffff, 1.0f).CGColor);
                if (_cancelEnabled)
                    CGContextStrokeLineSegments(context, crossLine, sizeof(crossLine) / sizeof(crossLine[0]));
            }
            
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            
            CGFloat start_angle = 2.0f * ((CGFloat)M_PI) * 0.0f - ((CGFloat)M_PI_2);
            CGFloat end_angle = 2.0f * ((CGFloat)M_PI) * _progress - ((CGFloat)M_PI_2);
            
            CGFloat pathLineWidth = _overlayStyle == TGMessageImageViewOverlayStyleDefault ? 2.0f : 2.0f;
            CGFloat pathDiameter = diameter - pathLineWidth;
            UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(diameter / 2.0f, diameter / 2.0f) radius:pathDiameter / 2.0f startAngle:start_angle endAngle:end_angle clockwise:true];
            path.lineWidth = pathLineWidth;
            path.lineCapStyle = kCGLineCapRound;
            [path stroke];
            
            break;
        }
        case TGMessageImageViewOverlayViewTypePlay:
        {
            const CGFloat diameter = 50.0f;
            const CGFloat width = 20.0f;
            const CGFloat height = width + 4.0f;
            const CGFloat offset = 3.0f;
            
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            
            CGContextSetFillColorWithColor(context, UIColorRGBA(0xffffffff, 0.8f).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, offset + CGFloor((diameter - width) / 2.0f), CGFloor((diameter - height) / 2.0f));
            CGContextAddLineToPoint(context, offset + CGFloor((diameter - width) / 2.0f) + width, CGFloor(diameter / 2.0f));
            CGContextAddLineToPoint(context, offset + CGFloor((diameter - width) / 2.0f), CGFloor((diameter + height) / 2.0f));
            CGContextClosePath(context);
            CGContextSetFillColorWithColor(context, UIColorRGBA(0xff000000, 0.45f).CGColor);
            CGContextFillPath(context);
            
            break;
        }
        case TGMessageImageViewOverlayViewTypeSecret:
        case TGMessageImageViewOverlayViewTypeSecretViewed:
        {
            const CGFloat diameter = 50.0f;
            
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            
            CGContextSetFillColorWithColor(context, UIColorRGBA(0xffffffff, 0.7f).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            
            static UIImage *fireIconMask = nil;
            static UIImage *fireIcon = nil;
            static UIImage *viewedIconMask = nil;
            static UIImage *viewedIcon = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                fireIconMask = [UIImage imageNamed:@"SecretPhotoFireMask.png"];
                fireIcon = [UIImage imageNamed:@"SecretPhotoFire.png"];
                viewedIconMask = [UIImage imageNamed:@"SecretPhotoCheckMask.png"];
                viewedIcon = [UIImage imageNamed:@"SecretPhotoCheck.png"];
            });
            
            if (_type == TGMessageImageViewOverlayViewTypeSecret)
            {
                [fireIconMask drawAtPoint:CGPointMake(CGFloor((diameter - fireIcon.size.width) / 2.0f), CGFloor((diameter - fireIcon.size.height) / 2.0f)) blendMode:kCGBlendModeDestinationIn alpha:1.0f];
                [fireIcon drawAtPoint:CGPointMake(CGFloor((diameter - fireIcon.size.width) / 2.0f), CGFloor((diameter - fireIcon.size.height) / 2.0f)) blendMode:kCGBlendModeNormal alpha:0.4f];
            }
            else
            {
                CGPoint offset = CGPointMake(1.0f, 2.0f);
                [viewedIconMask drawAtPoint:CGPointMake(offset.x + CGFloor((diameter - viewedIcon.size.width) / 2.0f), offset.y + CGFloor((diameter - viewedIcon.size.height) / 2.0f)) blendMode:kCGBlendModeDestinationIn alpha:1.0f];
                [viewedIcon drawAtPoint:CGPointMake(offset.x + CGFloor((diameter - viewedIcon.size.width) / 2.0f), offset.y + CGFloor((diameter - viewedIcon.size.height) / 2.0f)) blendMode:kCGBlendModeNormal alpha:0.3f];
            }
            
            break;
        }
        case TGMessageImageViewOverlayViewTypeSecretProgress:
        {
            const CGFloat diameter = 50.0f;
            
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            
            CGContextSetFillColorWithColor(context, UIColorRGBA(0xffffffff, 0.7f).CGColor);

            CGPoint center = CGPointMake(diameter / 2.0f, diameter / 2.0f);
            CGFloat radius = diameter / 2.0f;
            CGFloat startAngle = - ((float)M_PI / 2);
            CGFloat endAngle = (_progress * 2 * (float)M_PI) + startAngle;
            CGContextMoveToPoint(context, center.x, center.y);
            CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
            CGContextClosePath(context);
            
            CGContextFillPath(context);
            
            break;
        }
        default:
            break;
    }
    
    UIGraphicsPopContext();
}

@end

@implementation TGMessageImageViewOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.opaque = false;
        self.backgroundColor = [UIColor clearColor];
        
        self.layer.contentsScale = [UIScreen mainScreen].scale;
    }
    return self;
}

+ (Class)layerClass
{
    return [TGMessageImageViewOverlayLayer class];
}

- (void)setOverlayStyle:(TGMessageImageViewOverlayStyle)overlayStyle
{
    [((TGMessageImageViewOverlayLayer *)self.layer) setOverlayStyle:overlayStyle];
}

- (void)setBlurredBackgroundImage:(UIImage *)blurredBackgroundImage
{
    [((TGMessageImageViewOverlayLayer *)self.layer) setBlurredBackgroundImage:blurredBackgroundImage];
}

- (void)setImageBackgroundColor:(UIColor *)imageBackgroundColor
{
    [((TGMessageImageViewOverlayLayer *)self.layer) setImageBackgroundColor:imageBackgroundColor];
}

- (void)setDownload
{
    [((TGMessageImageViewOverlayLayer *)self.layer) setDownload];
}

- (void)setPlay
{
    [((TGMessageImageViewOverlayLayer *)self.layer) setPlay];
}

- (void)setSecret:(bool)isViewed
{
    [((TGMessageImageViewOverlayLayer *)self.layer) setSecret:isViewed];
}

- (void)setProgress:(float)progress animated:(bool)animated
{
    [self setProgress:progress cancelEnabled:true animated:animated];
}

- (void)setProgress:(float)progress cancelEnabled:(bool)cancelEnabled animated:(bool)animated
{
    [((TGMessageImageViewOverlayLayer *)self.layer) setProgress:progress cancelEnabled:cancelEnabled animated:animated];
}

- (void)setSecretProgress:(float)progress animated:(bool)animated
{
    [((TGMessageImageViewOverlayLayer *)self.layer) setSecretProgress:progress animated:animated];
}

@end
