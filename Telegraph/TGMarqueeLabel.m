#import "TGMarqueeLabel.h"
#import <QuartzCore/QuartzCore.h>

NSString *const kMarqueeLabelAnimationCompletionBlock = @"MarqueeLabelAnimationCompletionBlock";

typedef void(^MLAnimationCompletionBlock)(BOOL finished);

@interface GradientSetupAnimation : CABasicAnimation
@end

@interface UIView (MarqueeLabelHelpers)
- (UIViewController *)firstAvailableViewController;
- (id)traverseResponderChainForFirstViewController;
@end

@interface CAMediaTimingFunction (MarqueeLabelHelpers)
- (NSArray *)controlPoints;
- (CGFloat)durationPercentageForPositionPercentage:(CGFloat)positionPercentage withDuration:(NSTimeInterval)duration;
@end

@interface TGMarqueeLabel()
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
<CAAnimationDelegate>
#endif
{
    UIViewAnimationOptions _animationCurve;
}

@property (nonatomic, strong) UILabel *internalLabel;

@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, assign, readonly) BOOL labelShouldScroll;
@property (nonatomic, weak) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, assign) CGRect homeLabelFrame;
@property (nonatomic, assign) CGFloat awayOffset;
@property (nonatomic, assign, readwrite) BOOL isPaused;

@property (nonatomic, copy) MLAnimationCompletionBlock scrollCompletionBlock;
@property (nonatomic, strong) NSArray *gradientColors;
CGPoint MLOffsetCGPoint(CGPoint point, CGFloat offset);

@end


@implementation TGMarqueeLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        [self setupLabel];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (Class)layerClass
{
    return [CAReplicatorLayer class];
}

- (CAReplicatorLayer *)repliLayer
{
    return (CAReplicatorLayer *)self.layer;
}

- (CAGradientLayer *)maskLayer
{
    return (CAGradientLayer *)self.layer.mask;
}

- (void)drawLayer:(CALayer *)__unused layer inContext:(CGContextRef)__unused ctx
{
    
}

- (void)setupLabel
{
    self.clipsToBounds = true;
    self.numberOfLines = 1;
    
    self.internalLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.internalLabel.tag = 700;
    self.internalLabel.layer.anchorPoint = CGPointMake(0.0f, 0.0f);
    [self addSubview:self.internalLabel];
    
    
    _awayOffset = 0.0f;
    _animationCurve = UIViewAnimationOptionCurveLinear;
    _isPaused = false;
    _fadeLength = 0.0f;
    _animationDelay = 1.0;
    _animationDuration = 0.0f;
    _leadingBuffer = 0.0f;
    _trailingBuffer = 0.0f;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartLabel) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shutdownLabel) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)minimizeLabelFrameWithMaximumSize:(CGSize)maxSize adjustHeight:(BOOL)adjustHeight
{
    if (self.internalLabel.text != nil) {
        if (CGSizeEqualToSize(maxSize, CGSizeZero)) {
            maxSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
        }
        CGSize minimumLabelSize = [self subLabelSize];
        
        CGSize minimumSize = CGSizeMake(minimumLabelSize.width + (self.fadeLength * 2), minimumLabelSize.height);
        
        minimumSize = CGSizeMake(MIN(minimumSize.width, maxSize.width), MIN(minimumSize.height, maxSize.height));
        
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, minimumSize.width, (adjustHeight ? minimumSize.height : self.frame.size.height));
    }
}

- (void)didMoveToSuperview
{
    [self updateInternalLabel];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self updateInternalLabel];
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    if (!newWindow)
        [self shutdownLabel];
}

- (void)didMoveToWindow
{
    if (!self.window)
        [self shutdownLabel];
    else
        [self updateInternalLabel];
}

- (void)updateInternalLabel
{
    [self updateSublabelAndBeginScroll:true];
}

- (void)updateSublabelAndBeginScroll:(bool)beginScroll
{
    if (!self.internalLabel.text || !self.superview)
        return;
    
    
    CGSize expectedLabelSize = [self subLabelSize];
    
    [self invalidateIntrinsicContentSize];
    [self returnLabelToOriginImmediately];
    
    [self applyGradientMaskForFadeLength:self.fadeLength animated:true];
    
    if (!self.labelShouldScroll)
    {
        self.internalLabel.textAlignment = [super textAlignment];
        self.internalLabel.lineBreakMode = [super lineBreakMode];
        
        CGRect labelFrame = CGRectIntegral(CGRectMake(self.leadingBuffer, 0.0f, self.bounds.size.width - self.leadingBuffer, self.bounds.size.height));
        
        self.homeLabelFrame = labelFrame;
        self.awayOffset = 0.0f;
        
        self.repliLayer.instanceCount = 1;
        
        self.internalLabel.frame = labelFrame;

        [self removeGradientMask];
        
        return;
    }
    
    [self.internalLabel setLineBreakMode:NSLineBreakByClipping];
    
    CGFloat minTrailing = MAX(MAX(self.leadingBuffer, self.trailingBuffer), self.fadeLength);
    
    self.homeLabelFrame = CGRectIntegral(CGRectMake(self.leadingBuffer, 0.0f, expectedLabelSize.width, self.bounds.size.height));
    self.awayOffset = -(self.homeLabelFrame.size.width + minTrailing);
    
    self.internalLabel.frame = self.homeLabelFrame;
    
    self.repliLayer.instanceCount = 2;
    self.repliLayer.instanceTransform = CATransform3DMakeTranslation(-self.awayOffset, 0.0, 0.0);
    
    self.animationDuration = (self.rate != 0) ? ((NSTimeInterval) fabs(self.awayOffset) / self.rate) : (self.scrollDuration);
    
    if (beginScroll)
        [self beginScroll];
}

- (CGSize)subLabelSize
{
    CGSize expectedLabelSize = CGSizeZero;
    CGSize maximumLabelSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    
    expectedLabelSize = [self.internalLabel sizeThatFits:maximumLabelSize];
    expectedLabelSize.width = MIN(expectedLabelSize.width, 5461.0f);
    expectedLabelSize.height = self.bounds.size.height;
    
    return expectedLabelSize;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize fitSize = [self.internalLabel sizeThatFits:size];
    fitSize.width += self.leadingBuffer;
    return fitSize;
}


- (BOOL)labelShouldScroll {
    BOOL stringLength = ([self.internalLabel.text length] > 0);
    if (!stringLength) {
        return NO;
    }
    
    BOOL labelTooLarge = ([self subLabelSize].width + self.leadingBuffer > self.bounds.size.width + FLT_EPSILON);
    BOOL animationHasDuration = (self.scrollDuration > 0.0f || self.rate > 0.0f);
    return (labelTooLarge && animationHasDuration);
}

- (bool)labelReadyForScroll
{
    if (self.superview == nil)
        return false;

    if (self.window == nil)
        return false;
    
    return true;
}

- (void)beginScroll
{
    [self beginScrollWithDelay:true];
}

- (void)beginScrollWithDelay:(bool)delay
{
    [self scrollContinuousWithInterval:self.animationDuration after:(delay ? self.animationDelay : 0.0)];
}

- (void)returnLabelToOriginImmediately
{
    [self.layer.mask removeAllAnimations];

    [self.internalLabel.layer removeAllAnimations];
    self.scrollCompletionBlock = nil;
}

- (void)scrollContinuousWithInterval:(NSTimeInterval)interval after:(NSTimeInterval)delayAmount {
    [self scrollContinuousWithInterval:interval after:delayAmount labelAnimation:nil gradientAnimation:nil];
}

- (void)scrollContinuousWithInterval:(NSTimeInterval)interval
                               after:(NSTimeInterval)delayAmount
                      labelAnimation:(CAKeyframeAnimation *)labelAnimation
                   gradientAnimation:(CAKeyframeAnimation *)gradientAnimation {
    // Check for conditions which would prevent scrolling
    if (![self labelReadyForScroll]) {
        return;
    }
    
    // Return labels to home (cancel any animations)
    [self returnLabelToOriginImmediately];
    
    // Call pre-animation method
    [self labelWillBeginScroll];
    
    // Animate
    [CATransaction begin];
    
    // Set Duration
    [CATransaction setAnimationDuration:(delayAmount + interval)];
    
    // Create animation for gradient, if needed
    if (self.fadeLength != 0.0f) {
        if (!gradientAnimation) {
            gradientAnimation = [self keyFrameAnimationForGradientFadeLength:self.fadeLength
                                                                    interval:interval
                                                                       delay:delayAmount];
        }
        [self.layer.mask addAnimation:gradientAnimation forKey:@"gradient"];
    }
    
    // Create animation for sublabel positions, if needed
    if (!labelAnimation) {
        CGPoint homeOrigin = self.homeLabelFrame.origin;
        CGPoint awayOrigin = MLOffsetCGPoint(self.homeLabelFrame.origin, self.awayOffset);
        NSArray *values = @[[NSValue valueWithCGPoint:homeOrigin],      // Initial location, home
                            [NSValue valueWithCGPoint:homeOrigin],      // Initial delay, at home
                            [NSValue valueWithCGPoint:awayOrigin]];     // Animation to home
        
        labelAnimation = [self keyFrameAnimationForProperty:@"position"
                                                     values:values
                                                   interval:interval
                                                      delay:delayAmount];
    }
    
    __weak __typeof__(self) weakSelf = self;
    self.scrollCompletionBlock = ^(BOOL finished) {
        if (!finished || !weakSelf) {
            // Do not continue into the next loop
            return;
        }
        // Call returned home method
        [weakSelf labelReturnedToHome:YES];
        // Check to ensure that:
        // 1) We don't double fire if an animation already exists
        // 2) The instance is still attached to a window - this completion block is called for
        //    many reasons, including if the animation is removed due to the view being removed
        //    from the UIWindow (typically when the view controller is no longer the "top" view)
        if (weakSelf.window && ![weakSelf.internalLabel.layer animationForKey:@"position"]) {
            // Begin again, if conditions met
            if (weakSelf.labelShouldScroll)
            {
                [weakSelf scrollContinuousWithInterval:interval
                                                 after:delayAmount
                                        labelAnimation:labelAnimation
                                     gradientAnimation:gradientAnimation];
            }
        }
    };
    
    
    // Attach completion block
    [labelAnimation setValue:@(YES) forKey:kMarqueeLabelAnimationCompletionBlock];
    
    // Add animation
    [self.internalLabel.layer addAnimation:labelAnimation forKey:@"position"];
    
    [CATransaction commit];
}

- (void)applyGradientMaskForFadeLength:(CGFloat)fadeLength animated:(BOOL)animated {
    
    // Remove any in-flight animations
    [self.layer.mask removeAllAnimations];
    
    // Check for zero-length fade
    if (fadeLength <= 0.0f) {
        [self removeGradientMask];
        return;
    }
    
    // Configure gradient mask without implicit animations
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    CAGradientLayer *gradientMask = (CAGradientLayer *)self.layer.mask;
    
    // Set up colors
    NSObject *transparent = (NSObject *)[[UIColor clearColor] CGColor];
    NSObject *opaque = (NSObject *)[[UIColor blackColor] CGColor];
    
    if (!gradientMask) {
        // Create CAGradientLayer if needed
        gradientMask = [CAGradientLayer layer];
        gradientMask.shouldRasterize = YES;
        gradientMask.rasterizationScale = [UIScreen mainScreen].scale;
        gradientMask.startPoint = CGPointMake(0.0f, 0.5f);
        gradientMask.endPoint = CGPointMake(1.0f, 0.5f);
    }
    
    // Check if there is a mask-to-bounds size mismatch
    if (!CGRectEqualToRect(gradientMask.bounds, self.bounds)) {
        // Adjust stops based on fade length
        CGFloat leftFadeStop = fadeLength/self.bounds.size.width;
        CGFloat rightFadeStop = fadeLength/self.bounds.size.width;
        gradientMask.locations = @[@(0.0f), @(leftFadeStop), @(1.0f - rightFadeStop), @(1.0f)];
    }
    
    gradientMask.bounds = self.layer.bounds;
    gradientMask.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    // Set mask
    self.layer.mask = gradientMask;
    
    bool trailingFadeNeeded = self.labelShouldScroll;
    NSArray *adjustedColors = @[opaque,
                                opaque,
                                opaque,
                                (trailingFadeNeeded ? transparent : opaque)];
    
    if (animated)
    {
        [CATransaction commit];
        
        GradientSetupAnimation *colorAnimation = [GradientSetupAnimation animationWithKeyPath:@"colors"];
        colorAnimation.fromValue = gradientMask.colors;
        colorAnimation.toValue = adjustedColors;
        colorAnimation.duration = 0.25;
        colorAnimation.removedOnCompletion = NO;
        colorAnimation.delegate = self;
        [gradientMask addAnimation:colorAnimation forKey:@"setupFade"];
    }
    else
    {
        gradientMask.colors = adjustedColors;
        [CATransaction commit];
    }
}

- (void)removeGradientMask
{
    self.layer.mask = nil;
}

- (CAKeyframeAnimation *)keyFrameAnimationForGradientFadeLength:(CGFloat)__unused fadeLength
                                                       interval:(NSTimeInterval)interval
                                                          delay:(NSTimeInterval)delayAmount
{
    // Setup
    NSArray *values = nil;
    NSArray *keyTimes = nil;
    NSTimeInterval totalDuration;
    NSObject *transp = (NSObject *)[[UIColor clearColor] CGColor];
    NSObject *opaque = (NSObject *)[[UIColor blackColor] CGColor];
    
    // Create new animation
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"colors"];
    
    // Get timing function
    CAMediaTimingFunction *timingFunction = [self timingFunctionForAnimationOptions:_animationCurve];
    
    // Calculate total animation duration
    totalDuration = delayAmount + interval;
    
    // Find when the lead label will be totally offscreen
    CGFloat startFadeFraction = fabs((self.internalLabel.bounds.size.width + self.leadingBuffer) / self.awayOffset);
    // Find when the animation will hit that point
    CGFloat startFadeTimeFraction = [timingFunction durationPercentageForPositionPercentage:startFadeFraction withDuration:totalDuration];
    NSTimeInterval startFadeTime = delayAmount + startFadeTimeFraction * interval;
    
    keyTimes = @[
                 @(0.0),                                            // Initial gradient
                 @(delayAmount/totalDuration),                      // Begin of fade in
                 @((delayAmount + 0.2)/totalDuration),              // End of fade in, just as scroll away starts
                 @((startFadeTime)/totalDuration),                  // Begin of fade out, just before scroll home completes
                 @((startFadeTime + 0.1)/totalDuration),            // End of fade out, as scroll home completes
                 @(1.0)                                             // Buffer final value (used on continuous types)
                 ];
    
    // Define gradient values
    // Get curent layer values
    CAGradientLayer *currentMask = [[self maskLayer] presentationLayer];
    NSArray *currentValues = currentMask.colors;
    
    values = @[
               (currentValues ? currentValues : @[opaque, opaque, opaque, transp]),           // Initial gradient
               @[opaque, opaque, opaque, transp],           // Begin of fade in
               @[transp, opaque, opaque, transp],           // End of fade in, just as scroll away starts
               @[transp, opaque, opaque, transp],           // Begin of fade out, just before scroll home completes
               @[opaque, opaque, opaque, transp],           // End of fade out, as scroll home completes
               @[opaque, opaque, opaque, transp]            // Final "home" value
               ];
    
    animation.values = values;
    animation.keyTimes = keyTimes;
    animation.timingFunctions = @[timingFunction, timingFunction, timingFunction, timingFunction];
    
    return animation;
}

- (CAKeyframeAnimation *)keyFrameAnimationForProperty:(NSString *)property
                                               values:(NSArray *)values
                                             interval:(NSTimeInterval)interval
                                                delay:(NSTimeInterval)delayAmount
{
    // Create new animation
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:property];
    
    // Get timing function
    CAMediaTimingFunction *timingFunction = [self timingFunctionForAnimationOptions:_animationCurve];
    
    // Calculate times based on marqueeType
    NSTimeInterval totalDuration;
    NSAssert(values.count == 3, @"Incorrect number of values passed for MLContinous-type animation");
    totalDuration = delayAmount + interval;
    // Set up keyTimes
    animation.keyTimes = @[@(0.0),                              // Initial location, home
                           @(delayAmount/totalDuration),        // Initial delay, at home
                           @(1.0)];                             // Animation to away
    
    animation.timingFunctions = @[timingFunction,
                                  timingFunction];
    
    animation.values = values;
    animation.delegate = self;
    
    return animation;
}

- (CAMediaTimingFunction *)timingFunctionForAnimationOptions:(UIViewAnimationOptions)animationOptions {
    NSString *timingFunction;
    switch (animationOptions) {
        case UIViewAnimationOptionCurveEaseIn:
            timingFunction = kCAMediaTimingFunctionEaseIn;
            break;
            
        case UIViewAnimationOptionCurveEaseInOut:
            timingFunction = kCAMediaTimingFunctionEaseInEaseOut;
            break;
            
        case UIViewAnimationOptionCurveEaseOut:
            timingFunction = kCAMediaTimingFunctionEaseOut;
            break;
            
        default:
            timingFunction = kCAMediaTimingFunctionLinear;
            break;
    }
    
    return [CAMediaTimingFunction functionWithName:timingFunction];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([anim isMemberOfClass:[GradientSetupAnimation class]])
    {
        GradientSetupAnimation *setupFade = (GradientSetupAnimation *)anim;
        NSArray *finalColors = setupFade.toValue;
        if (finalColors)
            [(CAGradientLayer *)self.layer.mask setColors:finalColors];

        [self.layer.mask removeAnimationForKey:@"setupFade"];
    }
    else
    {
        if (self.scrollCompletionBlock)
            self.scrollCompletionBlock(flag);
    }
}

#pragma mark - Label Control

- (void)restartLabel
{
    [self shutdownLabel];
    if (self.labelShouldScroll)
        [self beginScroll];
}

- (void)resetLabel
{
    [self returnLabelToOriginImmediately];
    self.homeLabelFrame = CGRectNull;
    self.awayOffset = 0.0f;
}

- (void)shutdownLabel
{
    [self returnLabelToOriginImmediately];
    [self applyGradientMaskForFadeLength:self.fadeLength animated:false];
}

- (void)pauseLabel
{
    if (!self.isPaused && self.awayFromHome)
    {
        CFTimeInterval labelPauseTime = [self.internalLabel.layer convertTime:CACurrentMediaTime() fromLayer:nil];
        self.internalLabel.layer.speed = 0.0;
        self.internalLabel.layer.timeOffset = labelPauseTime;
        
        CFTimeInterval gradientPauseTime = [self.layer.mask convertTime:CACurrentMediaTime() fromLayer:nil];
        self.layer.mask.speed = 0.0;
        self.layer.mask.timeOffset = gradientPauseTime;
        
        self.isPaused = true;
    }
}

- (void)unpauseLabel
{
    if (self.isPaused)
    {
        CFTimeInterval labelPausedTime = self.internalLabel.layer.timeOffset;
        self.internalLabel.layer.speed = 1.0;
        self.internalLabel.layer.timeOffset = 0.0;
        self.internalLabel.layer.beginTime = 0.0;
        self.internalLabel.layer.beginTime = [self.internalLabel.layer convertTime:CACurrentMediaTime() fromLayer:nil] - labelPausedTime;
        
        CFTimeInterval gradientPauseTime = self.layer.mask.timeOffset;
        self.layer.mask.speed = 1.0;
        self.layer.mask.timeOffset = 0.0;
        self.layer.mask.beginTime = 0.0;
        self.layer.mask.beginTime = [self.layer.mask convertTime:CACurrentMediaTime() fromLayer:nil] - gradientPauseTime;
        
        self.isPaused = false;
    }
}

- (void)triggerScrollStart
{
    if (self.labelShouldScroll && !self.awayFromHome)
        [self beginScroll];
}

- (void)labelWillBeginScroll
{
    return;
}

- (void)labelReturnedToHome:(BOOL)__unused finished
{
    return;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (iosMajorVersion() < 9)
        [self updateInternalLabel];
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    if (iosMajorVersion() < 9)
        [self updateInternalLabel];
}


- (NSString *)text
{
    return self.internalLabel.text;
}

- (void)setText:(NSString *)text
{
    if ([text isEqualToString:self.internalLabel.text])
        return;

    self.internalLabel.text = text;
    super.text = text;
    [self updateInternalLabel];
}

- (NSAttributedString *)attributedText
{
    return self.internalLabel.attributedText;
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    if ([attributedText isEqualToAttributedString:self.internalLabel.attributedText])
        return;

    self.internalLabel.attributedText = attributedText;
    super.attributedText = attributedText;
    [self updateInternalLabel];
}

- (UIFont *)font
{
    return self.internalLabel.font;
}

- (void)setFont:(UIFont *)font
{
    if ([font isEqual:self.internalLabel.font])
        return;

    self.internalLabel.font = font;
    super.font = font;
    [self updateInternalLabel];
}

- (UIColor *)textColor
{
    return self.internalLabel.textColor;
}

- (void)setTextColor:(UIColor *)textColor
{
    self.internalLabel.textColor = textColor;
    super.textColor = textColor;
}

- (void)setNumberOfLines:(NSInteger)__unused numberOfLines
{
    [super setNumberOfLines:1];
}

- (void)setAdjustsFontSizeToFitWidth:(BOOL)__unused adjustsFontSizeToFitWidth
{
    [super setAdjustsFontSizeToFitWidth:false];
}

- (void)setMinimumFontSize:(CGFloat)__unused minimumFontSize
{
    [super setMinimumFontSize:0.0];
}

- (UIBaselineAdjustment)baselineAdjustment
{
    return self.internalLabel.baselineAdjustment;
}

- (void)setBaselineAdjustment:(UIBaselineAdjustment)baselineAdjustment
{
    self.internalLabel.baselineAdjustment = baselineAdjustment;
    super.baselineAdjustment = baselineAdjustment;
}

- (CGSize)intrinsicContentSize
{
    CGSize contentSize = self.internalLabel.intrinsicContentSize;
    contentSize.width += self.leadingBuffer;
    return contentSize;
}

- (void)setAdjustsLetterSpacingToFitWidth:(BOOL)__unused adjustsLetterSpacingToFitWidth
{
    [super setAdjustsLetterSpacingToFitWidth:false];
}

- (void)setMinimumScaleFactor:(CGFloat)__unused minimumScaleFactor
{
    [super setMinimumScaleFactor:0.0f];
}

#pragma mark - Custom Getters and Setters

- (void)setRate:(CGFloat)rate
{
    if (_rate == rate) {
        return;
    }
    
    _scrollDuration = 0.0f;
    _rate = rate;
    [self updateInternalLabel];
}

- (void)setScrollDuration:(CGFloat)lengthOfScroll
{
    if (_scrollDuration == lengthOfScroll)
        return;
    
    _rate = 0.0f;
    _scrollDuration = lengthOfScroll;
    [self updateInternalLabel];
}

- (void)setAnimationCurve:(UIViewAnimationOptions)animationCurve
{
    if (_animationCurve == animationCurve)
        return;
    
    NSUInteger allowableOptions = UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionCurveLinear;
    if ((allowableOptions & animationCurve) == animationCurve) {
        _animationCurve = animationCurve;
    }
}

- (void)setLeadingBuffer:(CGFloat)leadingBuffer
{
    if (_leadingBuffer == leadingBuffer)
        return;
    
    _leadingBuffer = fabs(leadingBuffer);
    [self updateInternalLabel];
}

- (void)setTrailingBuffer:(CGFloat)trailingBuffer
{
    if (_trailingBuffer == trailingBuffer)
        return;
    
    _trailingBuffer = fabs(trailingBuffer);
    [self updateInternalLabel];
}

- (void)setContinuousMarqueeExtraBuffer:(CGFloat)continuousMarqueeExtraBuffer
{
    [self setTrailingBuffer:continuousMarqueeExtraBuffer];
}

- (CGFloat)continuousMarqueeExtraBuffer
{
    return self.trailingBuffer;
}

- (void)setFadeLength:(CGFloat)fadeLength
{
    if (_fadeLength == fadeLength)
        return;
    
    _fadeLength = fadeLength;
    
    [self updateInternalLabel];
}

- (bool)awayFromHome
{
    CALayer *presentationLayer = self.internalLabel.layer.presentationLayer;
    if (!presentationLayer)
        return false;

    return !(presentationLayer.position.x == self.homeLabelFrame.origin.x);
}

#pragma mark - Support

- (NSArray *)gradientColors {
    if (!_gradientColors) {
        NSObject *transparent = (NSObject *)[[UIColor clearColor] CGColor];
        NSObject *opaque = (NSObject *)[[UIColor blackColor] CGColor];
        _gradientColors = [NSArray arrayWithObjects: transparent, opaque, opaque, transparent, nil];
    }
    return _gradientColors;
}

@end



#pragma mark - Helpers

CGPoint MLOffsetCGPoint(CGPoint point, CGFloat offset) {
    return CGPointMake(point.x + offset, point.y);
}

@implementation GradientSetupAnimation

@end

@implementation CAMediaTimingFunction (MarqueeLabelHelpers)

- (CGFloat)durationPercentageForPositionPercentage:(CGFloat)positionPercentage withDuration:(NSTimeInterval)duration
{
    NSArray *controlPoints = [self controlPoints];
    CGFloat epsilon = 1.0f / (100.0f * duration);
    
    CGFloat t_found = [self solveTForY:positionPercentage withEpsilon:epsilon controlPoints:controlPoints];
    return [self XforCurveAt:t_found withControlPoints:controlPoints];
}

- (CGFloat)solveTForY:(CGFloat)y_0 withEpsilon:(CGFloat)epsilon controlPoints:(NSArray *)controlPoints
{
    CGFloat t0 = y_0;
    CGFloat t1 = y_0;
    CGFloat f0, df0;
    
    for (NSInteger i = 0; i < 15; i++)
    {
        t0 = t1;
        f0 = [self YforCurveAt:t0 withControlPoints:controlPoints] - y_0;
        if (fabs(f0) < epsilon)
            return t0;

        df0 = [self derivativeYValueForCurveAt:t0 withControlPoints:controlPoints];
        if (fabs(df0) < 1e-6)
            break;
    
        t1 = t0 - f0/df0;
    }
    
    return t0;
}

- (CGFloat)YforCurveAt:(CGFloat)t withControlPoints:(NSArray *)controlPoints
{
    CGPoint P0 = [controlPoints[0] CGPointValue];
    CGPoint P1 = [controlPoints[1] CGPointValue];
    CGPoint P2 = [controlPoints[2] CGPointValue];
    CGPoint P3 = [controlPoints[3] CGPointValue];

    return pow((1 - t),3) * P0.y + 3.0f * pow(1 - t, 2) * t * P1.y + 3.0f * (1 - t) * pow(t, 2) * P2.y + pow(t, 3) * P3.y;
}

- (CGFloat)XforCurveAt:(CGFloat)t withControlPoints:(NSArray *)controlPoints
{
    CGPoint P0 = [controlPoints[0] CGPointValue];
    CGPoint P1 = [controlPoints[1] CGPointValue];
    CGPoint P2 = [controlPoints[2] CGPointValue];
    CGPoint P3 = [controlPoints[3] CGPointValue];
    
    return  pow((1 - t),3) * P0.x + 3.0f * pow(1 - t, 2) * t * P1.x + 3.0f * (1 - t) * pow(t, 2) * P2.x + pow(t, 3) * P3.x;
}

- (CGFloat)derivativeYValueForCurveAt:(CGFloat)t withControlPoints:(NSArray *)controlPoints
{
    CGPoint P0 = [controlPoints[0] CGPointValue];
    CGPoint P1 = [controlPoints[1] CGPointValue];
    CGPoint P2 = [controlPoints[2] CGPointValue];
    CGPoint P3 = [controlPoints[3] CGPointValue];
    
    return pow(t, 2) * (-3.0f * P0.y - 9.0f * P1.y - 9.0f * P2.y + 3.0f * P3.y) + t * (6.0f * P0.y + 6.0f * P2.y) + (-3.0f * P0.y + 3.0f * P1.y);
}

- (NSArray *)controlPoints
{
    float point[2];
    NSMutableArray *pointArray = [NSMutableArray array];
    for (NSInteger i = 0; i <= 3; i++)
    {
        [self getControlPointAtIndex:i values:point];
        [pointArray addObject:[NSValue valueWithCGPoint:CGPointMake(point[0], point[1])]];
    }
    
    return [NSArray arrayWithArray:pointArray];
}

@end
