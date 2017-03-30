#import "TGCallButton.h"

#import "TGFont.h"
#import "TGImageUtils.h"

#import "TGDefaultPasscodeBackground.h"
#import "TGImageBasedPasscodeBackground.h"

@interface TGCallButtonBackgroundLayer : CALayer

@property (nonatomic, assign) CGFloat highlightIntensity;
@property (nonatomic, assign) CGFloat selectionIntensity;
@property (nonatomic, assign) CGColorRef backColor;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, assign) CGFloat iconRotation;
@property (nonatomic, assign) CGFloat iconTargetRotation;

@end

const CGSize TGCallSmallButtonSize = { 65.0f, 65.0f };
const CGSize TGCallNormalButtonSize = { 75.0f, 75.0f };

@interface TGCallButton ()
{
    UIImage *_iconImage;
    UIImageView *_iconImageView;
    bool _animateHighlight;
    
    NSObject<TGPasscodeBackground> *_background;
    CGPoint _absoluteOffset;
}

@property (nonatomic, assign) CGFloat highlightIntensity;
@property (nonatomic, assign) CGFloat selectionIntensity;

@end

@implementation TGCallButton

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, [TGCallButton buttonSize].width, [TGCallButton buttonSize].height)];
    if (self != nil)
    {
        self.adjustsImageWhenDisabled = false;
        self.adjustsImageWhenHighlighted = false;
        self.titleLabel.font = TGSystemFontOfSize(14.0f);
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.numberOfLines = 1;
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return self;
}

+ (CGSize)buttonSize
{
    static dispatch_once_t onceToken;
    static CGSize size;
    dispatch_once(&onceToken, ^
    {
        CGSize screenSize = TGScreenSize();
        if ((int)screenSize.width == 320)
            size = TGCallSmallButtonSize;
        else
            size = TGCallNormalButtonSize;
    });
    return size;
}

+ (Class)layerClass
{
    return [TGCallButtonBackgroundLayer class];
}

- (void)setBackground:(NSObject<TGPasscodeBackground> *)background
{
    _background = background;
    [self setNeedsDisplay];
}

- (void)setAbsoluteOffset:(CGPoint)absoluteOffset
{
    if (!CGPointEqualToPoint(_absoluteOffset, absoluteOffset))
    {
        _absoluteOffset = absoluteOffset;
        [self setNeedsDisplay];
    }
}

- (void)setImage:(UIImage *)image forState:(UIControlState)__unused state
{
    if (!_hasBorder)
    {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - image.size.width) / 2.0f, (self.frame.size.height - image.size.height) / 2.0f, image.size.width, image.size.height)];
        _iconImageView.image = image;
        [self addSubview:_iconImageView];
    }
    else
    {
        _iconImage = image;
    }
    [self setNeedsDisplay];
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    title = [title stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    [super setTitle:title forState:state];
}

- (void)setHasBorder:(bool)hasBorder
{
    _hasBorder = hasBorder;
    [self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted
{
    highlighted = highlighted || self.selected;
    if (_hasBorder)
    {
        void (^changeBlock)(void) = ^
        {
            self.highlightIntensity = highlighted ? 1.0f : 0.0f;
        };
        
        if (_animateHighlight || !highlighted)
            [UIView animateWithDuration:0.15 animations:changeBlock];
        else
            changeBlock();
    }
    else
    {
        void (^changeBlock)(void) = ^
        {
            self.alpha = highlighted ? 0.5f : 1.0f;
        };
        
        if (_animateHighlight || !highlighted)
            [UIView animateWithDuration:0.15 animations:changeBlock];
        else
            changeBlock();
    }
}

- (void)setHighlightIntensity:(CGFloat)highlightIntensity
{
    ((TGCallButtonBackgroundLayer *)self.layer).highlightIntensity = highlightIntensity;
}

- (CGFloat)highlightIntensity
{
    return ((TGCallButtonBackgroundLayer *)self.layer).highlightIntensity;
}

- (void)setSelected:(BOOL)selected
{
    bool wasSelected = self.selected;
    if (wasSelected == selected)
        return;
    
    [super setSelected:selected];
    
    if (_hasBorder)
        [self setHighlighted:selected];
    
    if (_hasBorder && wasSelected != self.selected)
    {
        void (^changeBlock)(void) = ^
        {
            self.selectionIntensity = selected ? 1.0f : 0.0f;
        };
        
        [UIView animateWithDuration:0.15 animations:changeBlock];
    }
}

- (void)setSelectionIntensity:(CGFloat)selectionIntensity
{
    ((TGCallButtonBackgroundLayer *)self.layer).selectionIntensity = selectionIntensity;
}

- (CGFloat)selectionIntensity
{
    return ((TGCallButtonBackgroundLayer *)self.layer).selectionIntensity;
}

- (void)setIconRotation:(CGFloat)iconRotation
{
    ((TGCallButtonBackgroundLayer *)self.layer).iconTargetRotation = iconRotation;
    ((TGCallButtonBackgroundLayer *)self.layer).iconRotation = iconRotation;
}

- (CGFloat)iconRotation
{
    return ((TGCallButtonBackgroundLayer *)self.layer).iconRotation;
}

- (void)setBackColor:(UIColor *)backColor
{
    ((TGCallButtonBackgroundLayer *)self.layer).backColor = backColor.CGColor;
    [self setNeedsDisplay];
}

- (UIColor *)backColor
{
    return [UIColor colorWithCGColor:((TGCallButtonBackgroundLayer *)self.layer).backColor];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    TGCallButtonBackgroundLayer *sourceLayer = (TGCallButtonBackgroundLayer *)(self.layer.presentationLayer ?: self.layer);
    if (_hasBorder)
    {
        CGFloat selectionIntensity = sourceLayer.selectionIntensity;
        CGFloat alpha = 0.5 + selectionIntensity * 0.5f;
        CGFloat highlightIntensity = sourceLayer.highlightIntensity;
        if (highlightIntensity > FLT_EPSILON)
        {
            CGContextSetFillColorWithColor(context, UIColorRGBA(0xffffff, alpha * highlightIntensity).CGColor);
            CGContextFillEllipseInRect(context, CGRectInset(rect, 1.45f, 1.45f));
        }
        
        CGContextSetStrokeColorWithColor(context, UIColorRGBA(0xffffff, alpha).CGColor);
        CGContextSetLineWidth(context, 1.5f);
        CGContextStrokeEllipseInRect(context, CGRectInset(rect, 1.5f / 2.0f, 1.5f / 2.0f));
        
        CGSize imageSize =_iconImage.size;
        
        if (selectionIntensity > 0.0f)
        {
            [_iconImage drawInRect:CGRectMake((self.frame.size.width - imageSize.width) / 2.0f, (self.frame.size.height - imageSize.height) / 2.0f, imageSize.width, imageSize.height) blendMode:kCGBlendModeDestinationOut alpha:selectionIntensity];
        
            [_iconImage drawInRect:CGRectMake((self.frame.size.width - imageSize.width) / 2.0f, (self.frame.size.height - imageSize.height) / 2.0f, imageSize.width, imageSize.height) blendMode:kCGBlendModeNormal alpha:1.0f - selectionIntensity];
        }
        else
        {
            [_iconImage drawInRect:CGRectMake((self.frame.size.width - imageSize.width) / 2.0f, (self.frame.size.height - imageSize.height) / 2.0f, imageSize.width, imageSize.height) blendMode:kCGBlendModeNormal alpha:1.0f];
        }
    }
    else
    {
        CGColorRef backColor = [sourceLayer backColor];
        CGContextSetFillColorWithColor(context, backColor);
        CGContextFillEllipseInRect(context, rect);
        
        _iconImageView.transform = CGAffineTransformMakeRotation(sourceLayer.iconRotation);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    _animateHighlight = true;
    [super touchesBegan:touches withEvent:event];
    _animateHighlight = false;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    _animateHighlight = true;
    [super touchesMoved:touches withEvent:event];
    _animateHighlight = false;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _animateHighlight = true;
    [super touchesCancelled:touches withEvent:event];
    _animateHighlight = false;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _animateHighlight = true;
    [super touchesEnded:touches withEvent:event];
    _animateHighlight = false;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.titleLabel sizeToFit];
    CGRect frame = self.titleLabel.frame;
    frame = CGRectMake(floor((self.frame.size.width - frame.size.width) / 2.0f), self.bounds.size.height + 6.0f, frame.size.width, frame.size.height);
    self.titleLabel.frame = frame;
}

@end

NSString *const TGCallButtonHighlightIntensityKey = @"highlightIntensity";
NSString *const TGCallButtonSelectionIntensityKey = @"selectionIntensity";
NSString *const TGCallButtonBackColorKey = @"backColor";
NSString *const TGCallButtonStrokeColorKey = @"strokeColor";
NSString *const TGCallButtonIconRotationKey = @"iconRotation";

@implementation TGCallButtonBackgroundLayer

@dynamic highlightIntensity;
@dynamic selectionIntensity;
@dynamic backColor;
@dynamic strokeColor;
@dynamic iconRotation;

- (instancetype)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    if (self != nil)
    {
        if ([layer isKindOfClass:[TGCallButtonBackgroundLayer class]])
        {
            self.highlightIntensity = ((TGCallButtonBackgroundLayer *)layer).highlightIntensity;
            self.selectionIntensity = ((TGCallButtonBackgroundLayer *)layer).selectionIntensity;
            self.backColor = ((TGCallButtonBackgroundLayer *)layer).backColor;
            self.strokeColor = ((TGCallButtonBackgroundLayer *)layer).strokeColor;
            self.iconRotation = ((TGCallButtonBackgroundLayer *)layer).iconRotation;
        }
    }
    return self;
}

+ (BOOL)isCustomAnimKey:(NSString *)key
{
    static dispatch_once_t onceToken;
    static NSArray *animationKeys;
    dispatch_once(&onceToken, ^
    {
        animationKeys = @
        [
            TGCallButtonHighlightIntensityKey,
            TGCallButtonSelectionIntensityKey,
            TGCallButtonBackColorKey,
            TGCallButtonStrokeColorKey,
            TGCallButtonIconRotationKey
        ];
    });
    return [animationKeys containsObject:key];
}

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([self isCustomAnimKey:key])
        return true;
    else
        return [super needsDisplayForKey:key];
}

- (id<CAAction>)actionForKey:(NSString *)key
{
    if ([[self class] isCustomAnimKey:key])
    {
        id animation = [super actionForKey:@"backgroundColor"];
        if (animation == nil || [animation isEqual:[NSNull null]])
        {
            [self setNeedsDisplay];
            return nil;
        }
        
        [animation setKeyPath:key];
        
        if ([key isEqualToString:TGCallButtonHighlightIntensityKey])
             [animation setFromValue:@([self.presentationLayer highlightIntensity])];
        
        if ([key isEqualToString:TGCallButtonSelectionIntensityKey])
            [animation setFromValue:@([self.presentationLayer selectionIntensity])];
        
        if ([key isEqualToString:TGCallButtonBackColorKey])
            [animation setFromValue:(id)[self.presentationLayer backColor]];
        
        if ([key isEqualToString:TGCallButtonStrokeColorKey])
            [animation setFromValue:[self.presentationLayer strokeColor]];
        
        if ([key isEqualToString:TGCallButtonIconRotationKey])
        {
            //CGFloat fromValue = [self.presentationLayer iconRotation];
            
            CGFloat fromValue = 0.0f;
            CGFloat byValue = 0.0f;
            if (fabs(self.iconTargetRotation) < DBL_EPSILON)
            {
                fromValue = -2.35619f;
                byValue = -2.35619f - M_PI_2;
            }
            else
            {
                byValue = 2 * M_PI - 2.35619f;
            }
            
            [animation setFromValue:@(fromValue)];
            [animation setByValue:@(byValue)];
        }
        [animation setToValue:nil];
        return animation;
    }
    return [super actionForKey:key];
}

@end
