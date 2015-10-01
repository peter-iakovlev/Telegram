#import "TGTextMessageBackgroundViewModel.h"

#import "TGImageUtils.h"

#define TGTextMessageBackgroundImageDef(name, incoming, filePhone, filePad) \
    static UIImage *name() \
    { \
        static UIImage *image = nil; \
        static dispatch_once_t onceToken; \
        dispatch_once(&onceToken, ^ \
        { \
            CGSize screenSize = TGScreenSize(); \
            CGFloat screenSide = MAX(screenSize.width, screenSize.height); \
            bool isLarge = (TGIsPad() || (screenSide >= 667.0f - FLT_EPSILON)); \
TGLog(@"%d", isLarge ? 1 : 0);\
            image = [[UIImage imageNamed:!isLarge ? filePhone : filePad] stretchableImageWithLeftCapWidth:incoming ? 23 : (40 - 23) topCapHeight:16]; \
        }); \
        return image; \
    }

TGTextMessageBackgroundImageDef(incomingImage, true, @"ModernBubbleIncomingFull.png", @"ModernBubbleIncomingFullPad.png")
TGTextMessageBackgroundImageDef(incomingImageHighlighted, true, @"ModernBubbleIncomingFullHighlighted.png", @"ModernBubbleIncomingFullHighlightedPad.png")
TGTextMessageBackgroundImageDef(incomingPartialImage, true, @"ModernBubbleIncomingPartial.png", @"ModernBubbleIncomingPartialPad.png")
TGTextMessageBackgroundImageDef(incomingPartialImageHighlighted, true, @"ModernBubbleIncomingPartialHighlighted.png", @"ModernBubbleIncomingPartialHighlightedPad.png")

TGTextMessageBackgroundImageDef(outgoingImage, false, @"ModernBubbleOutgoingFull.png", @"ModernBubbleOutgoingFullPad.png")
TGTextMessageBackgroundImageDef(outgoingImageHighlighted, false, @"ModernBubbleOutgoingFullHighlighted.png", @"ModernBubbleOutgoingFullHighlightedPad.png")
TGTextMessageBackgroundImageDef(outgoingPartialImage, false, @"ModernBubbleOutgoingPartial.png", @"ModernBubbleOutgoingPartialPad.png")
TGTextMessageBackgroundImageDef(outgoingPartialImageHighlighted, false, @"ModernBubbleOutgoingPartialHighlighted.png", @"ModernBubbleOutgoingPartialHighlightedPad.png")

@interface TGTextMessageBackgroundViewModel ()
{
    TGTextMessageBackgroundType _type;
    bool _imageIsValid;
    
    bool _highlighted;
    UIView *_animatingHighligtedView;
}

@end

@implementation TGTextMessageBackgroundViewModel

- (instancetype)initWithType:(TGTextMessageBackgroundType)type
{
    self = [super initWithImage:nil];
    if (self != nil)
    {
        _type = type;
    }
    return self;
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    _highlighted = false;
    
    if (!_imageIsValid)
    {
        _imageIsValid = true;
        self.image = _type == TGTextMessageBackgroundIncoming ? (_partialMode ? incomingPartialImage() : incomingImage()) : (_partialMode ? outgoingPartialImage() : outgoingImage());
    }
    
    [super bindViewToContainer:container viewStorage:viewStorage];
}

- (void)setPartialMode:(bool)partialMode
{
    if (_partialMode != partialMode)
    {
        bool wasPartial = _partialMode;
        _partialMode = partialMode;
        _imageIsValid = false;
        
        if ([self boundView] != nil)
        {
            UIImageView *boundView = (UIImageView *)[self boundView];
            
            _imageIsValid = !_highlighted;
            UIImage *previousImage = self.image;
            UIImage *newImage = [self currentImage];
            self.image = newImage;
            
            if (previousImage != nil && iosMajorVersion() >= 7)
            {
                UIImageView *overlayImageView = [[UIImageView alloc] initWithFrame:boundView.bounds];
                
                if (!wasPartial)
                {
                    boundView.image = newImage;
                    overlayImageView.image = previousImage;
                }
                else
                {
                    boundView.image = previousImage;
                    overlayImageView.image = newImage;
                    overlayImageView.alpha = 0.0f;
                }
                
                [boundView addSubview:overlayImageView];
                
                [UIView animateWithDuration:0.3 * 0.7 animations:^
                {
                    overlayImageView.alpha = wasPartial ? 1.0f : 0.0f;
                } completion:^(__unused BOOL finished)
                {
                    if (finished && wasPartial)
                        boundView.image = newImage;
                    [overlayImageView removeFromSuperview];
                }];
            }
            else
                [(UIImageView *)[self boundView] setImage:self.image];
        }
    }
}

- (UIImage *)currentImage
{
    UIImage *newImage = nil;
    if (_type == TGTextMessageBackgroundIncoming)
    {
        if (_partialMode)
            newImage = _highlighted ? incomingPartialImageHighlighted() : incomingPartialImage();
        else
            newImage = _highlighted ? incomingImageHighlighted() : incomingImage();
    }
    else
    {
        if (_partialMode)
            newImage = _highlighted ? outgoingPartialImageHighlighted() : outgoingPartialImage();
        else
            newImage = _highlighted ? outgoingImageHighlighted() : outgoingImage();
    }
    
    return newImage;
}

- (void)setHighlightedIfBound
{
    if ([self boundView] != nil && !_highlighted)
    {
        _highlighted = true;
        
        _imageIsValid = false;
        
        self.image = [self currentImage];
        ((UIImageView *)[self boundView]).image = self.image;
    }
}

- (void)addScaleAnimationToLayer:(CALayer *)layer from:(CGSize)fromScale to:(CGSize)toScale duration:(NSTimeInterval)duration
{;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(fromScale.width, fromScale.height, 1.0f)];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(toScale.width, toScale.height, 1.0f)];
    animation.duration = duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.removedOnCompletion = true;
    animation.fillMode = kCAFillModeForwards;
    [layer addAnimation:animation forKey:@"transform"];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _animatingHighligtedView.frame = frame;
}

- (void)clearHighlight
{
    if (_highlighted)
    {
        _highlighted = false;
        
        if ([self boundView] != nil)
        {
            UIImage *previousImage = self.image;
            
            UIImage *newImage = [self currentImage];
            self.image = newImage;
            _imageIsValid = true;
            
            ((UIImageView *)[self boundView]).image = self.image;
            
            if (previousImage != nil && iosMajorVersion() >= 7)
            {
                [_animatingHighligtedView removeFromSuperview];
                
                UIImageView *overlayImageView = [[UIImageView alloc] initWithFrame:[self boundView].frame];
                overlayImageView.image = previousImage;
                _animatingHighligtedView = overlayImageView;
                
                [[self boundView].superview insertSubview:overlayImageView aboveSubview:[self boundView]];
                
                CGSize frameSize = [self boundView].frame.size;
                [self addScaleAnimationToLayer:[self boundView].layer from:CGSizeMake((frameSize.width - 2.0f) / frameSize.width, (frameSize.height - 2.0f) / frameSize.height) to:CGSizeMake(1.0f, 1.0f) duration:0.2];
                
                __weak TGTextMessageBackgroundViewModel *weakSelf = self;
                [UIView animateWithDuration:0.4 animations:^
                {
                    overlayImageView.alpha = 0.0f;
                } completion:^(__unused BOOL finished)
                {
                    [overlayImageView removeFromSuperview];
                    __strong TGTextMessageBackgroundViewModel *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        if (strongSelf->_animatingHighligtedView == overlayImageView)
                            strongSelf->_animatingHighligtedView = nil;
                    }
                }];
            }
        }
    }
}

@end
