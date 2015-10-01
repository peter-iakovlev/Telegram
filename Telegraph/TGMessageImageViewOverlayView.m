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
    TGMessageImageViewOverlayViewTypeNone = 0,
    TGMessageImageViewOverlayViewTypeDownload = 1,
    TGMessageImageViewOverlayViewTypeProgress = 2,
    TGMessageImageViewOverlayViewTypeProgressCancel = 3,
    TGMessageImageViewOverlayViewTypeProgressNoCancel = 4,
    TGMessageImageViewOverlayViewTypePlay = 5,
    TGMessageImageViewOverlayViewTypeSecret = 6,
    TGMessageImageViewOverlayViewTypeSecretViewed = 7,
    TGMessageImageViewOverlayViewTypeSecretProgress = 8,
    TGMessageImageViewOverlayViewTypePlayMedia = 9,
    TGMessageImageViewOverlayViewTypePauseMedia = 10
} TGMessageImageViewOverlayViewType;

@interface TGMessageImageViewOverlayLayer : CALayer
{
}

@property (nonatomic) CGFloat radius;
@property (nonatomic) int overlayStyle;
@property (nonatomic) CGFloat progress;
@property (nonatomic) int type;
@property (nonatomic, strong) UIColor *overlayBackgroundColorHint;

@property (nonatomic, strong) UIImage *blurredBackgroundImage;

@end

@implementation TGMessageImageViewOverlayLayer

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
    }
    return self;
}

- (void)setOverlayBackgroundColorHint:(UIColor *)overlayBackgroundColorHint
{
    if (_overlayBackgroundColorHint != overlayBackgroundColorHint)
    {
        _overlayBackgroundColorHint = overlayBackgroundColorHint;
        [self setNeedsDisplay];
    }
}

- (void)setOverlayStyle:(int)overlayStyle
{
    if (_overlayStyle != overlayStyle)
    {
        _overlayStyle = overlayStyle;
        [self setNeedsDisplay];
    }
}

- (void)setNone
{
    _type = TGMessageImageViewOverlayViewTypeNone;
    
    [self pop_removeAnimationForKey:@"progress"];
    [self pop_removeAnimationForKey:@"progressAmbient"];
    _progress = 0.0f;
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

- (void)setPlayMedia
{
    if (_type != TGMessageImageViewOverlayViewTypePlayMedia)
    {
        [self pop_removeAnimationForKey:@"progress"];
        [self pop_removeAnimationForKey:@"progressAmbient"];
        
        _type = TGMessageImageViewOverlayViewTypePlayMedia;
        [self setNeedsDisplay];
    }
}

- (void)setPauseMedia
{
    if (_type != TGMessageImageViewOverlayViewTypePauseMedia)
    {
        [self pop_removeAnimationForKey:@"progress"];
        [self pop_removeAnimationForKey:@"progressAmbient"];
        
        _type = TGMessageImageViewOverlayViewTypePauseMedia;
        [self setNeedsDisplay];
    }
}

- (void)setProgressCancel
{
    if (_type != TGMessageImageViewOverlayViewTypeProgressCancel)
    {
        [self pop_removeAnimationForKey:@"progress"];
        [self pop_removeAnimationForKey:@"progressAmbient"];
        
        _type = TGMessageImageViewOverlayViewTypeProgressCancel;
        [self setNeedsDisplay];
    }
}

- (void)setProgressNoCancel
{
    if (_type != TGMessageImageViewOverlayViewTypeProgressNoCancel)
    {
        [self pop_removeAnimationForKey:@"progress"];
        [self pop_removeAnimationForKey:@"progressAmbient"];
        
        _type = TGMessageImageViewOverlayViewTypeProgressNoCancel;
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
    ambientProgress.fromValue = @((CGFloat)0.0f);
    ambientProgress.toValue = @((CGFloat)M_PI * 2.0f);
    ambientProgress.duration = 3.0;
    ambientProgress.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    ambientProgress.repeatForever = true;
    
    [layer pop_addAnimation:ambientProgress forKey:@"progressAmbient"];
}

- (void)setProgress:(CGFloat)progress animated:(bool)animated
{    
    if (_type != TGMessageImageViewOverlayViewTypeProgress || ABS(_progress - progress) > FLT_EPSILON)
    {
        if (_type != TGMessageImageViewOverlayViewTypeProgress)
            _progress = 0.0f;
        
        if ([self pop_animationForKey:@"progressAmbient"] == nil)
            [TGMessageImageViewOverlayLayer _addAmbientProgressAnimation:self];
        
        _type = TGMessageImageViewOverlayViewTypeProgress;
        
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

- (void)setSecretProgress:(CGFloat)progress completeDuration:(NSTimeInterval)completeDuration animated:(bool)animated
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
                animation.toValue = @(0.0);
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
                animation.duration = completeDuration * _progress;
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
            CGFloat diameter = _overlayStyle == TGMessageImageViewOverlayStyleList ? 30.0f : self.radius;
            CGFloat lineWidth = _overlayStyle == TGMessageImageViewOverlayStyleList ? 1.4f : 2.0f;
            CGFloat height = _overlayStyle == TGMessageImageViewOverlayStyleList ? 18.0f : (CGCeil(self.radius / 2.0f) - 1.0f);
            CGFloat width = _overlayStyle == TGMessageImageViewOverlayStyleList ? 17.0f : CGCeil(self.radius / 2.5f);
            
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            
            if (_overlayStyle == TGMessageImageViewOverlayStyleDefault)
            {
                CGContextSetFillColorWithColor(context, UIColorRGBA(0xffffffff, 0.8f).CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            }
            else if (_overlayStyle == TGMessageImageViewOverlayStyleAccent)
            {
                CGContextSetStrokeColorWithColor(context, UIColorRGB(0xeaeaea).CGColor);
                CGContextSetLineWidth(context, 1.5f);
                CGContextStrokeEllipseInRect(context, CGRectMake(1.5f / 2.0f, 1.5f / 2.0f, diameter - 1.5f, diameter - 1.5f));
            }
            else if (_overlayStyle == TGMessageImageViewOverlayStyleList)
            {
            }
            else if (_overlayStyle == TGMessageImageViewOverlayStyleIncoming)
            {
                CGContextSetFillColorWithColor(context, UIColorRGBA(0x85baf2, 0.15f).CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            }
            else if (_overlayStyle == TGMessageImageViewOverlayStyleOutgoing)
            {
                CGContextSetFillColorWithColor(context, UIColorRGBA(0x4fb212, 0.15f).CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            }
            
            if (_overlayStyle == TGMessageImageViewOverlayStyleDefault)
                CGContextSetStrokeColorWithColor(context, UIColorRGBA(0xff000000, 0.55f).CGColor);
            else if (_overlayStyle == TGMessageImageViewOverlayStyleIncoming)
                CGContextSetStrokeColorWithColor(context, UIColorRGB(0x4f9ef3).CGColor);
            else if (_overlayStyle == TGMessageImageViewOverlayStyleOutgoing)
                CGContextSetStrokeColorWithColor(context, UIColorRGB(0x64b15e).CGColor);
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
        case TGMessageImageViewOverlayViewTypeProgressCancel:
        case TGMessageImageViewOverlayViewTypeProgressNoCancel:
        {
            CGFloat diameter = _overlayStyle == TGMessageImageViewOverlayStyleList ? 30.0f : self.radius;
            CGFloat inset = 0.5f;
            CGFloat lineWidth = _overlayStyle == TGMessageImageViewOverlayStyleList ? 1.5f : 2.0f;
            CGFloat crossSize = _overlayStyle == TGMessageImageViewOverlayStyleList ? 10.0f : 16.0f;
            
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            
            if (_overlayStyle == TGMessageImageViewOverlayStyleDefault)
            {
                if (_overlayBackgroundColorHint != nil)
                    CGContextSetFillColorWithColor(context, _overlayBackgroundColorHint.CGColor);
                else
                    CGContextSetFillColorWithColor(context, UIColorRGBA(0x000000, 0.7f).CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(inset, inset, diameter - inset * 2.0f, diameter - inset * 2.0f));
            }
            else if (_overlayStyle == TGMessageImageViewOverlayStyleIncoming)
            {
                CGContextSetFillColorWithColor(context, UIColorRGBA(0x85baf2, 0.15f).CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            }
            else if (_overlayStyle == TGMessageImageViewOverlayStyleOutgoing)
            {
                CGContextSetFillColorWithColor(context, UIColorRGBA(0x4fb212, 0.15f).CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            }
            else if (_overlayStyle == TGMessageImageViewOverlayStyleAccent)
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
            else if (_overlayStyle == TGMessageImageViewOverlayStyleIncoming)
                CGContextSetStrokeColorWithColor(context, UIColorRGB(0x4f9ef3).CGColor);
            else if (_overlayStyle == TGMessageImageViewOverlayStyleOutgoing)
                CGContextSetStrokeColorWithColor(context, UIColorRGB(0x64b15e).CGColor);
            else
                CGContextSetStrokeColorWithColor(context, TGAccentColor().CGColor);
            
            if (_type == TGMessageImageViewOverlayViewTypeProgressCancel)
                CGContextStrokeLineSegments(context, crossLine, sizeof(crossLine) / sizeof(crossLine[0]));
            
            if (_overlayStyle == TGMessageImageViewOverlayStyleDefault)
            {
                CGContextSetBlendMode(context, kCGBlendModeNormal);
                CGContextSetStrokeColorWithColor(context, UIColorRGBA(0xffffff, 1.0f).CGColor);
                if (_type == TGMessageImageViewOverlayViewTypeProgressCancel)
                    CGContextStrokeLineSegments(context, crossLine, sizeof(crossLine) / sizeof(crossLine[0]));
            }
            
            break;
        }
        case TGMessageImageViewOverlayViewTypeProgress:
        {
            const CGFloat diameter = _overlayStyle == TGMessageImageViewOverlayStyleList ? 30.0f : self.radius;
            const CGFloat lineWidth = _overlayStyle == TGMessageImageViewOverlayStyleList ? 1.0f : 2.0f;
            
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            
            CGContextSetLineCap(context, kCGLineCapRound);
            CGContextSetLineWidth(context, lineWidth);
            
            if (_overlayStyle == TGMessageImageViewOverlayStyleDefault)
                CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
            else if (_overlayStyle == TGMessageImageViewOverlayStyleIncoming)
                CGContextSetStrokeColorWithColor(context, UIColorRGB(0x4f9ef3).CGColor);
            else if (_overlayStyle == TGMessageImageViewOverlayStyleOutgoing)
                CGContextSetStrokeColorWithColor(context, UIColorRGB(0x64b15e).CGColor);
            else
                CGContextSetStrokeColorWithColor(context, TGAccentColor().CGColor);
            
            if (_overlayStyle == TGMessageImageViewOverlayStyleDefault)
            {
                CGContextSetBlendMode(context, kCGBlendModeNormal);
                CGContextSetStrokeColorWithColor(context, UIColorRGBA(0xffffff, 1.0f).CGColor);
            }
            
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            
            CGFloat start_angle = 2.0f * ((CGFloat)M_PI) * 0.0f - ((CGFloat)M_PI_2);
            CGFloat end_angle = 2.0f * ((CGFloat)M_PI) * _progress - ((CGFloat)M_PI_2);
            
            CGFloat pathLineWidth = _overlayStyle == TGMessageImageViewOverlayStyleDefault ? 2.0f : 2.0f;
            if (_overlayStyle == TGMessageImageViewOverlayStyleList)
                pathLineWidth = 1.4f;
            CGFloat pathDiameter = diameter - pathLineWidth;
            UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(diameter / 2.0f, diameter / 2.0f) radius:pathDiameter / 2.0f startAngle:start_angle endAngle:end_angle clockwise:true];
            path.lineWidth = pathLineWidth;
            path.lineCapStyle = kCGLineCapRound;
            [path stroke];
            
            break;
        }
        case TGMessageImageViewOverlayViewTypePlay:
        {
            const CGFloat diameter = self.radius;
            const CGFloat width = 20.0f;
            const CGFloat height = width + 4.0f;
            const CGFloat offset = 3.0f;
            
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            
            if (_overlayStyle == TGMessageImageViewOverlayStyleIncoming)
            {
                CGContextSetFillColorWithColor(context, UIColorRGBA(0x85baf2, 0.15f).CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
                
                UIImage *iconImage = [UIImage imageNamed:@"ModernMessageDocumentIconIncoming.png"];
                [iconImage drawAtPoint:CGPointMake(CGFloor((diameter - iconImage.size.width) / 2.0f), CGFloor((diameter - iconImage.size.height) / 2.0f)) blendMode:kCGBlendModeNormal alpha:1.0f];
            }
            else if (_overlayStyle == TGMessageImageViewOverlayStyleOutgoing)
            {
                CGContextSetFillColorWithColor(context, UIColorRGBA(0x4fb212, 0.15f).CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
                
                UIImage *iconImage = [UIImage imageNamed:@"ModernMessageDocumentIconOutgoing.png"];
                [iconImage drawAtPoint:CGPointMake(CGFloor((diameter - iconImage.size.width) / 2.0f), CGFloor((diameter - iconImage.size.height) / 2.0f)) blendMode:kCGBlendModeNormal alpha:1.0f];
            }
            else
            {
                CGContextSetFillColorWithColor(context, UIColorRGBA(0xffffffff, 0.8f).CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
                
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, offset + CGFloor((diameter - width) / 2.0f), CGFloor((diameter - height) / 2.0f));
                CGContextAddLineToPoint(context, offset + CGFloor((diameter - width) / 2.0f) + width, CGFloor(diameter / 2.0f));
                CGContextAddLineToPoint(context, offset + CGFloor((diameter - width) / 2.0f), CGFloor((diameter + height) / 2.0f));
                CGContextClosePath(context);
                CGContextSetFillColorWithColor(context, UIColorRGBA(0xff000000, 0.45f).CGColor);
                CGContextFillPath(context);
            }
            
            break;
        }
        case TGMessageImageViewOverlayViewTypePlayMedia:
        {
            const CGFloat diameter = self.radius;
            const CGFloat width = 20.0f;
            const CGFloat height = width + 4.0f;
            const CGFloat offset = 3.0f;
            
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            
            if (_overlayStyle == TGMessageImageViewOverlayStyleIncoming)
            {
                CGContextSetFillColorWithColor(context, TGAccentColor().CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
                
                CGContextSetBlendMode(context, kCGBlendModeCopy);
                
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, 17.0f, 13.0f);
                CGContextAddLineToPoint(context, 32.0f, 22.0f);
                CGContextAddLineToPoint(context, 17.0f, 32.0f);
                CGContextClosePath(context);
                CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
                CGContextFillPath(context);
            }
            else if (_overlayStyle == TGMessageImageViewOverlayStyleOutgoing)
            {
                CGContextSetFillColorWithColor(context, UIColorRGB(0x3fc33b).CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
                
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, 17.0f, 13.0f);
                CGContextAddLineToPoint(context, 32.0f, 22.0f);
                CGContextAddLineToPoint(context, 17.0f, 32.0f);
                CGContextClosePath(context);
                CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
                CGContextFillPath(context);
            }
            else
            {
                CGContextSetFillColorWithColor(context, UIColorRGBA(0xffffffff, 0.8f).CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
                
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, offset + CGFloor((diameter - width) / 2.0f), CGFloor((diameter - height) / 2.0f));
                CGContextAddLineToPoint(context, offset + CGFloor((diameter - width) / 2.0f) + width, CGFloor(diameter / 2.0f));
                CGContextAddLineToPoint(context, offset + CGFloor((diameter - width) / 2.0f), CGFloor((diameter + height) / 2.0f));
                CGContextClosePath(context);
                CGContextSetFillColorWithColor(context, UIColorRGBA(0xff000000, 0.45f).CGColor);
                CGContextFillPath(context);
            }
            
            break;
        }
        case TGMessageImageViewOverlayViewTypePauseMedia:
        {
            const CGFloat diameter = self.radius;
            const CGFloat width = 20.0f;
            const CGFloat height = width + 4.0f;
            const CGFloat offset = 3.0f;
            
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            
            if (_overlayStyle == TGMessageImageViewOverlayStyleIncoming)
            {
                CGContextSetFillColorWithColor(context, TGAccentColor().CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
                
                CGContextSetBlendMode(context, kCGBlendModeCopy);
                
                CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
                CGContextFillRect(context, CGRectMake(15.5f, 14.5f, 4.0f, 15.0f));
                CGContextFillRect(context, CGRectMake(24.5f, 14.5f, 4.0f, 15.0f));
            }
            else if (_overlayStyle == TGMessageImageViewOverlayStyleOutgoing)
            {
                CGContextSetFillColorWithColor(context, UIColorRGB(0x3fc33b).CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
                
                CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
                CGContextFillRect(context, CGRectMake(15.5f, 14.5f, 4.0f, 15.0f));
                CGContextFillRect(context, CGRectMake(24.5f, 14.5f, 4.0f, 15.0f));
            }
            else
            {
                CGContextSetFillColorWithColor(context, UIColorRGBA(0xffffffff, 0.8f).CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
                
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, offset + CGFloor((diameter - width) / 2.0f), CGFloor((diameter - height) / 2.0f));
                CGContextAddLineToPoint(context, offset + CGFloor((diameter - width) / 2.0f) + width, CGFloor(diameter / 2.0f));
                CGContextAddLineToPoint(context, offset + CGFloor((diameter - width) / 2.0f), CGFloor((diameter + height) / 2.0f));
                CGContextClosePath(context);
                CGContextSetFillColorWithColor(context, UIColorRGBA(0xff000000, 0.45f).CGColor);
                CGContextFillPath(context);
            }
            
            break;
        }
        case TGMessageImageViewOverlayViewTypeSecret:
        case TGMessageImageViewOverlayViewTypeSecretViewed:
        {
            const CGFloat diameter = self.radius;
            
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
            const CGFloat diameter = self.radius;
            
            [_blurredBackgroundImage drawInRect:CGRectMake(0.0f, 0.0f, diameter, diameter) blendMode:kCGBlendModeCopy alpha:1.0f];
            CGContextSetFillColorWithColor(context, UIColorRGBA(0xffffffff, 0.5f).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            
            CGContextSetBlendMode(context, kCGBlendModeClear);
            
            CGContextSetFillColorWithColor(context, UIColorRGBA(0xffffffff, 1.0f).CGColor);
            
            CGPoint center = CGPointMake(diameter / 2.0f, diameter / 2.0f);
            CGFloat radius = diameter / 2.0f + 0.25f;
            CGFloat startAngle = - ((CGFloat)M_PI / 2);
            CGFloat endAngle = ((1.0f - _progress) * 2 * (CGFloat)M_PI) + startAngle;
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

@interface TGMessageImageViewOverlayView ()
{
    CALayer *_blurredBackgroundLayer;
    TGMessageImageViewOverlayLayer *_contentLayer;
    TGMessageImageViewOverlayLayer *_progressLayer;
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
        
        _blurredBackgroundLayer = [[CALayer alloc] init];
        _blurredBackgroundLayer.frame = CGRectMake(0.5f + 0.125f, 0.5f + 0.125f, 50.0f - 0.25f - 1.0f, 50.0f - 0.25f - 1.0f);
        [self.layer addSublayer:_blurredBackgroundLayer];
        
        _contentLayer = [[TGMessageImageViewOverlayLayer alloc] init];
        _contentLayer.radius = 50.0f;
        _contentLayer.frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
        _contentLayer.contentsScale = [UIScreen mainScreen].scale;
        [self.layer addSublayer:_contentLayer];
        
        _progressLayer = [[TGMessageImageViewOverlayLayer alloc] init];
        _progressLayer.radius = 50.0f;
        _progressLayer.frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
        _progressLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
        _progressLayer.contentsScale = [UIScreen mainScreen].scale;
        _progressLayer.hidden = true;
        [self.layer addSublayer:_progressLayer];
    }
    return self;
}

- (void)setRadius:(CGFloat)radius
{
    _blurredBackgroundLayer.frame = CGRectMake(0.5f + 0.125f, 0.5f + 0.125f, radius - 0.25f - 1.0f, radius - 0.25f - 1.0f);
    _contentLayer.radius = radius;
    _contentLayer.frame = CGRectMake(0.0f, 0.0f, radius, radius);
    
    CATransform3D transform = _progressLayer.transform;
    _progressLayer.transform = CATransform3DIdentity;
    _progressLayer.radius = radius;
    _progressLayer.frame = CGRectMake(0.0f, 0.0f, radius, radius);
    _progressLayer.transform = transform;
}

- (void)setOverlayBackgroundColorHint:(UIColor *)overlayBackgroundColorHint
{
    [_contentLayer setOverlayBackgroundColorHint:overlayBackgroundColorHint];
}

- (void)setOverlayStyle:(TGMessageImageViewOverlayStyle)overlayStyle
{
    [_contentLayer setOverlayStyle:overlayStyle];
    [_progressLayer setOverlayStyle:overlayStyle];
    
    if (overlayStyle == TGMessageImageViewOverlayStyleList)
    {
        _contentLayer.frame = CGRectMake(0.0f, 0.0f, 30.0f, 30.0f);
        _progressLayer.frame = CGRectMake(0.0f, 0.0f, 30.0f, 30.0f);
        _progressLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
    }
    else
    {
        _contentLayer.frame = CGRectMake(0.0f, 0.0f, _contentLayer.radius, _contentLayer.radius);
        _progressLayer.frame = CGRectMake(0.0f, 0.0f, _progressLayer.radius, _progressLayer.radius);
        _progressLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
    }
}

- (void)setBlurredBackgroundImage:(UIImage *)blurredBackgroundImage
{
    _blurredBackgroundLayer.contents = (__bridge id)blurredBackgroundImage.CGImage;
    _contentLayer.blurredBackgroundImage = blurredBackgroundImage;
    if (_contentLayer.type == TGMessageImageViewOverlayViewTypeSecretProgress)
        [_contentLayer setNeedsDisplay];
}

- (void)setDownload
{
    [_contentLayer setDownload];
    [_progressLayer setNone];
    _progressLayer.hidden = true;
    _blurredBackgroundLayer.hidden = false;
}

- (void)setPlay
{
    [_contentLayer setPlay];
    [_progressLayer setNone];
    _progressLayer.hidden = true;
    _blurredBackgroundLayer.hidden = false;
}

- (void)setPlayMedia
{
    [_contentLayer setPlayMedia];
    [_progressLayer setNone];
    _progressLayer.hidden = true;
    _blurredBackgroundLayer.hidden = false;
}

- (void)setPauseMedia
{
    [_contentLayer setPauseMedia];
    [_progressLayer setNone];
    _progressLayer.hidden = true;
    _blurredBackgroundLayer.hidden = false;
}

- (void)setSecret:(bool)isViewed
{
    [_contentLayer setSecret:isViewed];
    [_progressLayer setNone];
    _progressLayer.hidden = true;
    _blurredBackgroundLayer.hidden = false;
}

- (void)setNone
{
    [_contentLayer setNone];
    [_progressLayer setNone];
    _progressLayer.hidden = true;
    _blurredBackgroundLayer.hidden = false;
}

- (void)setProgress:(CGFloat)progress animated:(bool)animated
{
    [self setProgress:progress cancelEnabled:true animated:animated];
}

- (void)setProgress:(CGFloat)progress cancelEnabled:(bool)cancelEnabled animated:(bool)animated
{
    if (progress > FLT_EPSILON)
        progress = MAX(progress, 0.027f);
    _blurredBackgroundLayer.hidden = false;
    _progressLayer.hidden = false;
    
    if (!animated)
    {
        _progressLayer.transform = CATransform3DIdentity;
        _progressLayer.frame = CGRectMake(0.0f, 0.0f, _contentLayer.frame.size.width, _contentLayer.frame.size.height);
    }
    
    [_progressLayer setProgress:progress animated:animated];
    
    if (cancelEnabled)
        [_contentLayer setProgressCancel];
    else
        [_contentLayer setProgressNoCancel];
}

- (void)setSecretProgress:(CGFloat)progress completeDuration:(NSTimeInterval)completeDuration animated:(bool)animated
{
    _blurredBackgroundLayer.hidden = true;
    [_progressLayer setNone];
    _progressLayer.hidden = true;
    [_contentLayer setSecretProgress:progress completeDuration:completeDuration animated:animated];
}

@end
