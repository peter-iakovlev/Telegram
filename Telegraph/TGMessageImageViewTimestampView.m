/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGMessageImageViewTimestampView.h"

#import "TGFont.h"
#import "TGImageUtils.h"
#import "TGStaticBackdropAreaData.h"
#import "TGAnimationBlockDelegate.h"

static const float luminanceThreshold = 0.8f;

static UIImage *clockFrameWithColor(UIColor *color)
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(11.0f, 11.0f), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat lineWidth = 1.25f;
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextStrokeEllipseInRect(context, CGRectMake(lineWidth / 2.0f, lineWidth / 2.0f, 11.0f - lineWidth, 11.0f - lineWidth));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

static UIImage *clockMinWithColor(UIColor *color)
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(2.0f, 5.0f), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat lineWidth = 1.25f;
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(lineWidth / 2.0f, lineWidth / 2.0f, 2.0f - lineWidth, 5.0f - lineWidth));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

static UIImage *clockHourWithColor(UIColor *color)
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(4.0f, 2.0f), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat lineWidth = 1.25f;
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(lineWidth / 2.0f, lineWidth / 2.0f, 4.0f - lineWidth, 2.0f - lineWidth));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

static UIImage *checkmarkFirstImageWithColor(UIColor *color)
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(12.0f, 9.0f), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1.2f);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    
    CGPoint checkmarksOrigin = CGPointMake(1.0f, 1.0f);
    
    CGPoint points[] = {
        CGPointMake(checkmarksOrigin.x, checkmarksOrigin.y + 4.0f),
        CGPointMake(checkmarksOrigin.x + 4.0f, checkmarksOrigin.y + 4.0f + 4.0f),
        CGPointMake(checkmarksOrigin.x + 3.5f - 0.5f, checkmarksOrigin.y + 4.0f + 4.0f),
        CGPointMake(checkmarksOrigin.x + 3.5f + (4.0f + 3.5f) - 1.0f, checkmarksOrigin.y)
    };
    CGContextStrokeLineSegments(context, points, (sizeof(points) / sizeof(points[0])));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

static UIImage *checkmarkSecondImageWithColor(UIColor *color)
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(12.0f, 9.0f), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1.2f);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    
    CGPoint checkmarksOrigin = CGPointMake(1.0f, 1.0f);
    
    CGPoint points[] = {
         CGPointMake(checkmarksOrigin.x + 2.5f, checkmarksOrigin.y + 4.0f + 2.5f),
         CGPointMake(checkmarksOrigin.x + 4.0f - 0.9f, checkmarksOrigin.y + 4.0f + 4.0f - 0.9f),
         CGPointMake(checkmarksOrigin.x + 3.5f - 0.5f, checkmarksOrigin.y + 4.0f + 4.0f),
         CGPointMake(checkmarksOrigin.x + 3.5f + (4.0f + 3.5f) - 1.0f, checkmarksOrigin.y)
    };
    CGContextStrokeLineSegments(context, points, (sizeof(points) / sizeof(points[0])));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

static CGImageRef clockFrameImage(CGFloat luminance)
{
    static CGImageRef lightImage = NULL;
    static CGImageRef darkImage = NULL;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        lightImage = CGImageRetain(clockFrameWithColor(UIColorRGBA(0x525252, 0.6f)).CGImage);
        darkImage = CGImageRetain(clockFrameWithColor([UIColor whiteColor]).CGImage);
    });
    
    return luminance >= luminanceThreshold ? lightImage : darkImage;
}

static CGImageRef clockMinImage(CGFloat luminance)
{
    static CGImageRef lightImage = NULL;
    static CGImageRef darkImage = NULL;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        lightImage = CGImageRetain(clockMinWithColor(UIColorRGBA(0x525252, 0.6f)).CGImage);
        darkImage = CGImageRetain(clockMinWithColor([UIColor whiteColor]).CGImage);
    });
    
    return luminance >= luminanceThreshold ? lightImage : darkImage;
}

static CGImageRef clockHourImage(CGFloat luminance)
{
    static CGImageRef lightImage = NULL;
    static CGImageRef darkImage = NULL;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        lightImage = CGImageRetain(clockHourWithColor(UIColorRGBA(0x525252, 0.6f)).CGImage);
        darkImage = CGImageRetain(clockHourWithColor([UIColor whiteColor]).CGImage);
    });
    
    return luminance >= luminanceThreshold ? lightImage : darkImage;
}

static CGImageRef checkmarkFirstImage(CGFloat luminance)
{
    static CGImageRef lightImage = NULL;
    static CGImageRef darkImage = NULL;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        lightImage = CGImageRetain(checkmarkFirstImageWithColor(UIColorRGBA(0x525252, 0.6f)).CGImage);
        darkImage = CGImageRetain(checkmarkFirstImageWithColor([UIColor whiteColor]).CGImage);
    });
    
    return luminance >= luminanceThreshold ? lightImage : darkImage;
}

static CGImageRef checkmarkSecondImage(CGFloat luminance)
{
    static CGImageRef lightImage = NULL;
    static CGImageRef darkImage = NULL;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        lightImage = CGImageRetain(checkmarkSecondImageWithColor(UIColorRGBA(0x525252, 0.6f)).CGImage);
        darkImage = CGImageRetain(checkmarkSecondImageWithColor([UIColor whiteColor]).CGImage);
    });
    
    return luminance >= luminanceThreshold ? lightImage : darkImage;
}

@interface TGMessageImageViewTimestampLayer : CALayer

@end

@implementation TGMessageImageViewTimestampLayer

- (void)display
{
    if ([self needsDisplay])
    {
        
    }
}

@end

@interface TGMessageImageViewTimestampView ()
{
    TGStaticBackdropAreaData *_backdropArea;
    
    UIColor *_timestampColor;
    NSString *_timestampString;
    NSString *_signatureString;
    bool _displayCheckmarks;
    int _checkmarkValue;
    int _checkmarkDisplayValue;
    
    bool _timestampStringSizeCalculated;
    CGSize _timestampStringSize;
    CGSize _signatureStringSize;
    
    CALayer *_chechmarkFirstLayer;
    CALayer *_chechmarkSecondLayer;
    
    CALayer *_clockFrameLayer;
    CALayer *_clockMinLayer;
    CALayer *_clockHourLayer;
    
    bool _isBroadcast;
    bool _transparent;
    
    NSString *_viewsString;
    CGFloat _maxWidth;
}

@end

@implementation TGMessageImageViewTimestampView

/*+ (Class)layerClass
{
    return [TGMessageImageViewTimestampLayer class];
}*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.opaque = false;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    bool update = CGSizeEqualToSize(self.frame.size, frame.size);
    
    [super setFrame:frame];
    
    if (update) {
        _timestampStringSizeCalculated = false;
        [self setNeedsDisplay];
    }
}

- (void)setBackdropArea:(TGStaticBackdropAreaData *)backdropArea transitionDuration:(NSTimeInterval)transitionDuration
{
    if (false && cpuCoreCount() >= 2 && transitionDuration > DBL_EPSILON)
    {
        id currentContents = self.layer.contents;
        if (currentContents != nil)
        {
            [CATransaction begin];
            [CATransaction setDisableActions:true];
            CALayer *transitionLayer = [[CALayer alloc] init];
            transitionLayer.frame = self.bounds;
            transitionLayer.contents = currentContents;
            [CATransaction commit];
            
            [self.layer addSublayer:transitionLayer];
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            animation.fromValue = @(1.0f);
            animation.toValue = @(0.0f);
            animation.duration = 5.0;//transitionDuration;
            animation.removedOnCompletion = true;
            
            TGAnimationBlockDelegate *animationDelegate = [[TGAnimationBlockDelegate alloc] initWithLayer:transitionLayer];;
            animationDelegate.removeLayerOnCompletion = true;
            animation.delegate = animationDelegate;
            
            [transitionLayer addAnimation:animation forKey:@"opacity"];
        }
    }
    
    CGFloat previousLuminance = 0.0f;//_backdropArea.luminance;
    CGFloat currentLuminance = 0.0f;//backdropArea.luminance;
    
    if (_backdropArea != backdropArea)
    {
        _backdropArea = backdropArea;
        
        if (ABS(currentLuminance - previousLuminance) > FLT_EPSILON)
        {
            if (_clockFrameLayer != nil)
            {
                _clockFrameLayer.contents = (__bridge id)clockFrameImage(currentLuminance);
                _clockMinLayer.contents = (__bridge id)clockMinImage(currentLuminance);
                _clockHourLayer.contents = (__bridge id)clockHourImage(currentLuminance);
            }
            
            if (_chechmarkFirstLayer != nil)
                _chechmarkFirstLayer.contents = (__bridge id)checkmarkFirstImage(currentLuminance);
            
            if (_chechmarkSecondLayer != nil)
                _chechmarkSecondLayer.contents = (__bridge id)checkmarkSecondImage(currentLuminance);
        }
        
        [self setNeedsDisplay];
    }
}

- (void)setTimestampColor:(UIColor *)timestampColor
{
    if (_timestampColor != timestampColor)
    {
        _timestampColor = timestampColor;
        [self setNeedsDisplay];
    }
}


+ (NSString *)stringForCount:(int32_t)count {
    if (count < 0)
        count = 0;
    
    if (count < 1000) {
        return [[NSString alloc] initWithFormat:@"%d", (int)count];
    } else if (count < 1000 * 1000) {
        return [[NSString alloc] initWithFormat:@"%dk", (int)count / 1000];
    } else {
        return [[NSString alloc] initWithFormat:@"%dm", (int)count / 1000];
    }
}

- (void)setTimestampString:(NSString *)timestampString signatureString:(NSString *)signatureString displayCheckmarks:(bool)displayCheckmarks checkmarkValue:(int)checkmarkValue displayViews:(bool)displayViews viewsValue:(int)viewsValue animated:(bool)animated
{
    NSString *viewsString = nil;
    if (displayViews) {
        viewsString = [TGMessageImageViewTimestampView stringForCount:viewsValue];
    }
    
    if (!TGStringCompare(_viewsString, viewsString)) {
        _viewsString = viewsString;
        [self setNeedsDisplay];
    }
    
    if (_checkmarkValue != checkmarkValue)
    {
        if (animated)
        {
            _checkmarkValue = checkmarkValue;
            
            if (_viewsString == nil && (_checkmarkValue >= 1) != (_chechmarkFirstLayer != nil) && _checkmarkDisplayValue < 1)
                [self _addFirstCheckmark];
            
            if (_viewsString == nil && (_checkmarkValue >= 2) != (_chechmarkSecondLayer != nil) && _checkmarkDisplayValue < 2)
                [self _addSecondCheckmark];
            
            [self setNeedsDisplay];
        }
        else
        {
            _checkmarkValue = checkmarkValue;
            _checkmarkDisplayValue = checkmarkValue;
            
            [self setNeedsDisplay];
        }
    }
    else if (!animated && _checkmarkDisplayValue != _checkmarkValue)
    {
        _checkmarkDisplayValue = _checkmarkValue;
        
        [self setNeedsDisplay];
    }
    
    if (!animated)
        [self _removeCheckmarks];
    
    if (!TGStringCompare(_timestampString, timestampString) || !TGStringCompare(_signatureString, signatureString) || _displayCheckmarks != displayCheckmarks)
    {
        _timestampString = timestampString;
        _signatureString = signatureString;
        _timestampStringSizeCalculated = false;
        
        _displayCheckmarks = displayCheckmarks;
        
        [self setNeedsDisplay];
    }
    
    if (_clockFrameLayer != nil) {
        [CATransaction begin];
        [CATransaction setDisableActions:true];
        [self updateProgressPosition];
        [CATransaction commit];
    }
}

- (void)setDisplayProgress:(bool)displayProgress
{
    if (displayProgress != (_clockFrameLayer != nil))
    {
        if (displayProgress)
            [self _addProgress];
        else
            [self _removeProgress];
    }
}

- (void)setIsBroadcast:(bool)isBroadcast
{
    if (_isBroadcast != isBroadcast)
    {
        _isBroadcast = isBroadcast;
        
        [self setNeedsDisplay];
    }
}

- (NSMutableArray *)_layerQueue
{
    static NSMutableArray *array = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        array = [[NSMutableArray alloc] init];
    });

    return array;
}

- (CALayer *)_dequeueLayer
{
    CALayer *layer = [[self _layerQueue] lastObject];
    if (layer != nil)
        [[self _layerQueue] removeLastObject];
    else
        layer = [[CALayer alloc] init];
    
    return layer;
}

- (void)_enqueueLayer:(CALayer *)layer
{
    if (layer != nil)
    {
        [layer removeFromSuperlayer];
        [layer removeAllAnimations];
        [[self _layerQueue] addObject:layer];
    }
}

- (CAAnimation *)_createRotationAnimationWithDuration:(NSTimeInterval)duration
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [animation setFromValue:@(0.0f)];
    [animation setToValue:@((float)M_PI * 2.0f)];
    [animation setDuration:duration];
    [animation setRepeatCount:INFINITY];
    [animation setAutoreverses:false];
    
    return animation;
}

- (void)_addProgress
{
    CGFloat luminance = 0.0f;//_backdropArea.luminance;
    
    [CATransaction begin];
    [CATransaction setDisableActions:true];
    _clockFrameLayer = [self _dequeueLayer];
    _clockFrameLayer.contents = (__bridge id)clockFrameImage(luminance);
    _clockFrameLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
    _clockFrameLayer.bounds = CGRectMake(0.0f, 0.0f, 11.0f, 11.0f);
    
    _clockMinLayer = [self _dequeueLayer];
    _clockMinLayer.contents = (__bridge id)clockMinImage(luminance);
    _clockMinLayer.anchorPoint = CGPointMake(0.5f, 4.0f / 5.0f);
    _clockMinLayer.bounds = CGRectMake(0.0f, 0.0f, 2.0f, 5.0f);
    
    _clockHourLayer = [self _dequeueLayer];
    _clockHourLayer.contents = (__bridge id)clockHourImage(luminance);
    _clockHourLayer.anchorPoint = CGPointMake(1.0f / 4.0f, 0.5f);
    _clockHourLayer.bounds = CGRectMake(0.0f, 0.0f, 4.0f, 2.0f);
    [self updateProgressPosition];
    [CATransaction commit];
    
    [self.layer addSublayer:_clockFrameLayer];
    [self.layer addSublayer:_clockMinLayer];
    [self.layer addSublayer:_clockHourLayer];
    
    [_clockHourLayer addAnimation:[self _createRotationAnimationWithDuration:1.0 * 6.0] forKey:@"transform.rotation.z"];
    [_clockMinLayer addAnimation:[self _createRotationAnimationWithDuration:1.0] forKey:@"transform.rotation.z"];
}

- (void)updateProgressPosition {
    if (_clockFrameLayer != nil) {
        CGPoint position = CGPointZero;
        if (_viewsString != nil) {
            position = CGPointMake(self.bounds.size.width - [self timestampStringSize].width - 6.0f - 17.5f + 11.0f / 2.0f, 3.5f + 11.0f / 2.0f);;
        } else {
            position = CGPointMake(self.bounds.size.width - 17.5f + 11.0f / 2.0f, 3.5f + 11.0f / 2.0f);
        }
        _clockFrameLayer.position = position;
        _clockMinLayer.position = position;
        _clockHourLayer.position = position;
    }
}

- (void)_removeProgress
{
    [self _enqueueLayer:_clockFrameLayer];
    _clockFrameLayer = nil;
    
    [self _enqueueLayer:_clockMinLayer];
    _clockMinLayer = nil;
    
    [self _enqueueLayer:_clockHourLayer];
    _clockHourLayer = nil;
}

- (CAAnimation *)_checkmarkAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = @(1.3f);
    animation.toValue = @(1.0f);
    animation.duration = 0.1;
    animation.removedOnCompletion = true;
    return animation;
}

- (void)_addFirstCheckmark
{
    [CATransaction begin];
    [CATransaction setDisableActions:true];
    
    CGFloat luminance = 0.0f;//_backdropArea.luminance
    _chechmarkFirstLayer = [self _dequeueLayer];
    _chechmarkFirstLayer.contents = (__bridge id)checkmarkFirstImage(luminance);
    _chechmarkFirstLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
    _chechmarkFirstLayer.bounds = CGRectMake(0.0f, 0.0f, 12.0f, 9.0f);
    _chechmarkFirstLayer.position = CGPointMake(self.bounds.size.width - 15.0f, 8.5f);
    
    [CATransaction commit];
    
    [self.layer addSublayer:_chechmarkFirstLayer];
    [_chechmarkFirstLayer addAnimation:[self _checkmarkAnimation] forKey:@"transform.scale"];
}

- (void)_addSecondCheckmark
{
    [CATransaction begin];
    [CATransaction setDisableActions:true];
    
    CGFloat luminance = 0.0f;//_backdropArea.luminance
    
    _chechmarkSecondLayer = [self _dequeueLayer];
    _chechmarkSecondLayer.contents = (__bridge id)checkmarkSecondImage(luminance);
    _chechmarkSecondLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
    _chechmarkSecondLayer.bounds = CGRectMake(0.0f, 0.0f, 12.0f, 9.0f);
    _chechmarkSecondLayer.position = CGPointMake(self.bounds.size.width - 11.0f, 8.5f);
    
    [CATransaction commit];
    
    [self.layer addSublayer:_chechmarkSecondLayer];
    [_chechmarkSecondLayer addAnimation:[self _checkmarkAnimation] forKey:@"transform.scale"];
}

- (void)_removeCheckmarks
{
    if (_chechmarkFirstLayer != nil)
    {
        [self _enqueueLayer:_chechmarkFirstLayer];
        _chechmarkFirstLayer = nil;
    }
    
    if (_chechmarkSecondLayer != nil)
    {
        [self _enqueueLayer:_chechmarkSecondLayer];
        _chechmarkSecondLayer = nil;
    }
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
}

- (void)setTransparent:(bool)transparent
{
    if (_transparent != transparent)
    {
        _transparent = transparent;
        [self setNeedsDisplay];
    }
}

- (UIFont *)timestampFont
{
    static UIFont *font = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        font = TGItalicSystemFontOfSize(11.0f);
    });
    
    return font;
}

- (CGSize)timestampStringSize
{
    if (!_timestampStringSizeCalculated)
    {
        _timestampStringSizeCalculated = true;
        _timestampStringSize = [_timestampString sizeWithFont:[self timestampFont]];
        _signatureStringSize = [_signatureString sizeWithFont:[self timestampFont]];
        _signatureStringSize.width = MIN(_maxWidth - 8.0f - _timestampStringSize.width - (_displayCheckmarks ? 20.0f : 0.0f) - (_viewsString.length == 0 ? 0 : 40.0f), _signatureStringSize.width);
        if (_signatureString != nil) {
            _signatureStringSize.width += 8.0f;
        }
        _timestampStringSize.width += _signatureStringSize.width;
    }
    
    return _timestampStringSize;
}

- (CGFloat)broadcastIconWidth
{
    return 17.0f;
}

- (CGFloat)viewsWidth {
    if (_viewsString == nil) {
        return 0.0f;
    } else {
        return 11.0f + [_viewsString sizeWithFont:[self timestampFont]].width;
    }
}

- (CGSize)timestampSize
{
    CGSize size = [self timestampStringSize];
    if (_displayCheckmarks)
        size.width += 18.0f;
    size.width += 12.0f;
    
    if (_isBroadcast)
        size.width += [self broadcastIconWidth];
    
    if (_viewsString != nil && (!_displayCheckmarks || _checkmarkValue != 0)) {
        size.width += [self viewsWidth];
        if (!_displayCheckmarks) {
            size.width += 18.0f;
        }
    }
    
    return size;
}

- (void)drawRect:(CGRect)__unused rect
{
    CGRect bounds = self.bounds;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat contentWidth = [self timestampSize].width;
    
    CGRect backgroundRect = CGRectMake(bounds.size.width - contentWidth, 0.0f, contentWidth, 18.0f);
    
    CGContextBeginPath(context);
    CGContextAddEllipseInRect(context, CGRectMake(backgroundRect.origin.x, backgroundRect.origin.y, backgroundRect.size.height, backgroundRect.size.height));
    CGContextAddRect(context, CGRectMake(backgroundRect.origin.x + backgroundRect.size.height / 2.0f, backgroundRect.origin.y, backgroundRect.size.width - backgroundRect.size.height, backgroundRect.size.height));
    CGContextAddEllipseInRect(context, CGRectMake(backgroundRect.origin.x + backgroundRect.size.width - backgroundRect.size.height, backgroundRect.origin.y, backgroundRect.size.height, backgroundRect.size.height));
    CGContextClip(context);
    
    /*if (_backdropArea == nil)
    {
        CGContextSetFillColorWithColor(context, UIColorRGB(0xaaaaaa).CGColor);
        CGContextFillRect(context, backgroundRect);
    }
    else
        [_backdropArea drawRelativeToImageRect:CGRectMake(-position.x, -position.y, imageSize.width, imageSize.height)];*/
    
    static UIColor *color = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        color = UIColorRGBA(0x000000, 0.4f);
    });
    
    if (!_transparent)
    {
        CGContextSetFillColorWithColor(context, _timestampColor == nil ? color.CGColor : _timestampColor.CGColor);
        CGContextFillRect(context, backgroundRect);
    }
    
    CGFloat luminance = 0.0f;//_backdropArea.luminance;
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    UIColor *textColor = luminance > luminanceThreshold ? UIColorRGBA(0x525252, 0.6f) : [UIColor whiteColor];
    
    CGContextSetFillColorWithColor(context, textColor.CGColor);
    CGContextSetStrokeColorWithColor(context, textColor.CGColor);
    
    CGFloat viewsWidth = 0.0f;
    if (_viewsString != nil) {
        if (!_displayCheckmarks || _checkmarkValue != 0) {
            viewsWidth = [self viewsWidth];
            
            static UIImage *viewsImage = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                viewsImage = [UIImage imageNamed:@"MessageInlineViewCountIconMedia.png"];
            });
            
            [viewsImage drawAtPoint:CGPointMake(backgroundRect.origin.x + 6.0f, backgroundRect.origin.y + 5.0f)];
            
            [_viewsString drawAtPoint:CGPointMake(backgroundRect.origin.x + 23.0f, backgroundRect.origin.y + 2.0f) withFont:[self timestampFont]];
            
            viewsWidth += 17.0f;
        } else {
            viewsWidth = 17.0f;
        }
    }
    
    if (_signatureString != nil) {
        [_signatureString drawInRect:CGRectMake(backgroundRect.origin.x + viewsWidth + 6.0f - TGRetinaPixel, backgroundRect.origin.y + 2.0f, _signatureStringSize.width, _signatureStringSize.height) withFont:[self timestampFont] lineBreakMode:NSLineBreakByTruncatingTail];
    }
    
    [_timestampString drawAtPoint:CGPointMake(backgroundRect.origin.x + viewsWidth + _signatureStringSize.width + 6.0f - TGRetinaPixel, backgroundRect.origin.y + 2.0f) withFont:[self timestampFont]];
    
    if (_displayCheckmarks && _viewsString == nil)
    {
        if (_checkmarkDisplayValue >= 1)
        {
            CGImageRef checkmarkImage = checkmarkFirstImage(luminance);
            if (checkmarkImage != NULL)
            {
                CGRect checkmarkFrame = CGRectMake(backgroundRect.origin.x + backgroundRect.size.width - 21.0f, 4.0f, 12.0f, 9.0f);
                
                CGContextTranslateCTM(context, CGRectGetMidX(checkmarkFrame), CGRectGetMidY(checkmarkFrame));
                CGContextScaleCTM(context, 1.0f, -1.0f);
                CGContextTranslateCTM(context, -CGRectGetMidX(checkmarkFrame), -CGRectGetMidY(checkmarkFrame));
                
                CGContextDrawImage(context, checkmarkFrame, checkmarkImage);
                
                CGContextTranslateCTM(context, CGRectGetMidX(checkmarkFrame), CGRectGetMidY(checkmarkFrame));
                CGContextScaleCTM(context, 1.0f, -1.0f);
                CGContextTranslateCTM(context, -CGRectGetMidX(checkmarkFrame), -CGRectGetMidY(checkmarkFrame));
            }
        }
        
        if (_checkmarkDisplayValue >= 2)
        {
            CGImageRef checkmarkImage = checkmarkSecondImage(luminance);
            if (checkmarkImage != NULL)
            {
                CGRect checkmarkFrame = CGRectMake(backgroundRect.origin.x + backgroundRect.size.width - 21.0f + 4.0f, 4.0f, 12.0f, 9.0f);
                
                CGContextTranslateCTM(context, CGRectGetMidX(checkmarkFrame), CGRectGetMidY(checkmarkFrame));
                CGContextScaleCTM(context, 1.0f, -1.0f);
                CGContextTranslateCTM(context, -CGRectGetMidX(checkmarkFrame), -CGRectGetMidY(checkmarkFrame));
                
                CGContextDrawImage(context, checkmarkFrame, checkmarkImage);
                
                CGContextTranslateCTM(context, CGRectGetMidX(checkmarkFrame), CGRectGetMidY(checkmarkFrame));
                CGContextScaleCTM(context, 1.0f, -1.0f);
                CGContextTranslateCTM(context, -CGRectGetMidX(checkmarkFrame), -CGRectGetMidY(checkmarkFrame));
            }
        }
    }
}

- (CGSize)sizeForMaxWidth:(CGFloat)maxWidth
{
    if (ABS(_maxWidth - maxWidth) > FLT_EPSILON) {
        _maxWidth = maxWidth;
        _timestampStringSizeCalculated = false;
    }
    return [self timestampSize];
}

@end
