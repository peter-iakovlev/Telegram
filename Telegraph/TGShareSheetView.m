#import "TGShareSheetView.h"

#import "TGShareSheetWindow.h"

#import "TGShareSheetItemView.h"
#import "TGImageUtils.h"
#import "TGVerticalSwipeDismissGestureRecognizer.h"
#import "TGAttachmentSheetScrollView.h"

#import "TGShareSheetButtonItemView.h"

#import "TGObserverProxy.h"

#import <Accelerate/Accelerate.h>

static CGFloat blurStaticOffset = 10.0f;
static CGFloat blurDynamicOffset = 5.0f;

@interface TGShareSheetView ()
{
    UIView *_backgroundView;
    
    UIView *_containerView;
    UIImageView *_containerBackgroundView;
    UIImageView *_scrollViewMask;
    
    CGFloat _overscrollHeight;
    CGFloat _swipeStart;
    
    CADisplayLink *_displayLink;
    NSArray *_blurLayers;
    CGPoint _lastPosition;
    
    UIView *_scrollViewContainer;
    TGAttachmentSheetScrollView *_scrollView;
    
    NSArray *_separatorViews;
    
    TGVerticalSwipeDismissGestureRecognizer *_swipeRecognizer;
    
    UIImageView *_cancelContainer;
    TGShareSheetButtonItemView *_cancelItemView;
    
    CGFloat _keyboardOffset;
    
    id _keyboardWillChangeFrameProxy;
}

@end

@implementation TGShareSheetView

+ (UIImage *)containerBackgroundWithFirst:(bool)first last:(bool)last {
    static UIImage *singleImage = nil;
    static UIImage *firstImage = nil;
    static UIImage *lastImage = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat diameter = 30.0f;
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            singleImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)(diameter / 2.0f) topCapHeight:(NSInteger)(diameter / 2.0f)];
            UIGraphicsEndImageContext();
        }
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            CGContextFillRect(context, CGRectMake(0.0f, diameter / 2.0f, diameter, diameter / 2.0f));
            firstImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)(diameter / 2.0f) topCapHeight:(NSInteger)(diameter / 2.0f)];
            UIGraphicsEndImageContext();
        }
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            CGContextFillRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter / 2.0f));
            lastImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)(diameter / 2.0f) topCapHeight:(NSInteger)(diameter / 2.0f)];
            UIGraphicsEndImageContext();
        }
    });
    
    if (first && last) {
        return singleImage;
    } else if (first) {
        return firstImage;
    } else {
        return lastImage;
    }
}

+ (UIImage *)selectionBackgroundWithFirst:(bool)first last:(bool)last {
    static UIImage *singleImage = nil;
    static UIImage *firstImage = nil;
    static UIImage *lastImage = nil;
    static UIImage *middleImage = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat diameter = 30.0f;
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, TGSelectionColor().CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            singleImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)(diameter / 2.0f) topCapHeight:(NSInteger)(diameter / 2.0f)];
            UIGraphicsEndImageContext();
        }
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, TGSelectionColor().CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            CGContextFillRect(context, CGRectMake(0.0f, diameter / 2.0f, diameter, diameter / 2.0f));
            firstImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)(diameter / 2.0f) topCapHeight:(NSInteger)(diameter / 2.0f)];
            UIGraphicsEndImageContext();
        }
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, TGSelectionColor().CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            CGContextFillRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter / 2.0f));
            lastImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)(diameter / 2.0f) topCapHeight:(NSInteger)(diameter / 2.0f)];
            UIGraphicsEndImageContext();
        }
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, TGSelectionColor().CGColor);
            CGContextFillRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            middleImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)(diameter / 2.0f) topCapHeight:(NSInteger)(diameter / 2.0f)];
            UIGraphicsEndImageContext();
        }
    });
    
    if (first && last) {
        return singleImage;
    } else if (first) {
        return firstImage;
    } else if (last) {
        return lastImage;
    } else {
        return middleImage;
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = UIColorRGBA(0x000000, 0.4f);
        [_backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped)]];
        [self addSubview:_backgroundView];
        
        _containerView = [[UIView alloc] init];
        _containerView.userInteractionEnabled = true;
        [self addSubview:_containerView];
        
        _containerBackgroundView = [[UIImageView alloc] initWithImage:[TGShareSheetView containerBackgroundWithFirst:true last:true]];
        [_containerView addSubview:_containerBackgroundView];
        
        _scrollViewMask = [[UIImageView alloc] initWithImage:[TGShareSheetView containerBackgroundWithFirst:true last:true]];
        
        __weak TGShareSheetView *weakSelf = self;
        _cancelItemView = [[TGShareSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") pressed:^{
            __strong TGShareSheetView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (strongSelf->_cancel) {
                    strongSelf->_cancel();
                }
            }
        }];
        [_cancelItemView setBold:true];
        
        _cancelContainer = [[UIImageView alloc] initWithImage:[TGShareSheetView containerBackgroundWithFirst:true last:true]];
        _cancelContainer.userInteractionEnabled = true;
        [_cancelContainer addSubview:_cancelItemView];
        [_containerView addSubview:_cancelContainer];
        
        _scrollViewContainer = [[UIView alloc] init];
        [_containerView addSubview:_scrollViewContainer];
        
        _scrollView = [[TGAttachmentSheetScrollView alloc] init];
        _scrollView.delaysContentTouches = false;
        _scrollView.canCancelContentTouches = true;
        [_scrollViewContainer addSubview:_scrollView];
        
        _swipeRecognizer = [[TGVerticalSwipeDismissGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
        _swipeRecognizer.cancelsTouchesInView = true;
        [self addGestureRecognizer:_swipeRecognizer];
        
        _overscrollHeight = 320.0f;
        
        [self updateLayout];
        
        _keyboardWillChangeFrameProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification];
    }
    return self;
}

- (CGFloat)swipeOffsetForOffset:(CGFloat)offset
{
    if (offset < 0.0f)
    {
        CGFloat c = 0.2f;
        CGFloat d = 320.0f;
        return (CGFloat)((1.0f - (1.0f / ((offset * c / d) + 1.0))) * d);
    }
    
    return offset;
}

- (CGFloat)clampVelocity:(CGFloat)velocity
{
    CGFloat value = velocity < 0.0f ? -velocity : velocity;
    value = MIN(30.0f, value);
    return velocity < 0.0f ? -value : value;
}

- (UIEdgeInsets)insets {
    return UIEdgeInsetsMake(8.0f, 10.0f, 10.0f, 10.0f);
}

- (void)animateToDefaultPosition:(CGFloat)__unused velocity
{
    UIEdgeInsets insets = [self insets];
    CGFloat cancelHeight = insets.top + [_cancelItemView preferredHeightForMaximumHeight:CGFLOAT_MAX] + insets.bottom;
    
    if (iosMajorVersion() >= 7)
    {
        [UIView animateWithDuration:0.45 delay:0.0 usingSpringWithDamping:0.48f initialSpringVelocity:0.0f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^
        {
            _containerView.frame = CGRectMake(insets.left, self.frame.size.height - _containerView.frame.size.height - MAX(0.0f, _keyboardOffset - cancelHeight), _containerView.frame.size.width, _containerView.frame.size.height);
        } completion:nil];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^
        {
            _containerView.frame = CGRectMake(insets.left, self.frame.size.height - _containerView.frame.size.height - MAX(0.0f, _keyboardOffset - cancelHeight), _containerView.frame.size.width, _containerView.frame.size.height);
        }];
    }
}

- (void)swipeGesture:(TGVerticalSwipeDismissGestureRecognizer *)recognizer
{
    UIEdgeInsets insets = [self insets];
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        if (_containerView.layer.presentationLayer != nil)
            _containerView.layer.position = ((CALayer *)_containerView.layer.presentationLayer).position;
        _swipeStart = [recognizer locationInView:self].y;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGFloat cancelHeight = insets.top + [_cancelItemView preferredHeightForMaximumHeight:CGFLOAT_MAX] + insets.bottom;
        
        CGFloat offset = [recognizer locationInView:self].y - _swipeStart;
        CGFloat bandOffset = [self swipeOffsetForOffset:offset];
        _containerView.frame = CGRectMake(insets.left, self.frame.size.height - _containerView.frame.size.height - MAX(0.0f, _keyboardOffset - cancelHeight) + bandOffset, _containerView.frame.size.width, _containerView.frame.size.height);
    }
    else if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        CGFloat velocity = [recognizer velocityInView:self].y;
        CGFloat offset = [recognizer locationInView:self].y - _swipeStart;
        if (offset > (_containerView.frame.size.height - _overscrollHeight) / 3.0f || velocity > 200.0f)
        {
            [self endEditing:true];
            
            [self animateOutWithVelocity:MAX(0.0f, velocity) forInterchange:false completion:^
            {
                TGShareSheetWindow *window = self.attachmentSheetWindow;
                window.hidden = true;

                if (window.dismissalBlock != nil)
                    window.dismissalBlock();
            }];
        }
        else
            [self animateToDefaultPosition:[recognizer velocityInView:self].y];
    }
    else if (recognizer.state == UIGestureRecognizerStateCancelled)
    {
        [self animateToDefaultPosition:[recognizer velocityInView:self].y];
    }
}

- (void)backgroundTapped
{
    [self endEditing:true];
    
    [self animateOut:^
    {
        TGShareSheetWindow *window = self.attachmentSheetWindow;
        window.hidden = true;
        
        if (window.dismissalBlock != nil)
            window.dismissalBlock();
    }];
}

- (NSArray *)blurryLayer:(CALayer *)layer size:(CGSize)size withBlurLevel:(CGFloat)blur {
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    
    int boxSize = (int)(blur * 100);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    vImage_Buffer inBuffer, outBuffer;
    
    CGFloat scale = 1.0f;
    const struct { int width, height; } targetContextSize = { (int)(size.width * scale), (int)(size.height * scale) };
    
    size_t targetBytesPerRow = ((4 * (int)targetContextSize.width) + 15) & (~15);
    void *targetMemory = malloc((int)(targetBytesPerRow * targetContextSize.height));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
    
    CGContextRef targetContext = CGBitmapContextCreate(targetMemory, (int)targetContextSize.width, (int)targetContextSize.height, 8, targetBytesPerRow, colorSpace, bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    
    UIGraphicsPushContext(targetContext);
    CGContextTranslateCTM(targetContext, targetContextSize.width / 2.0f, targetContextSize.height / 2.0f);
    CGContextScaleCTM(targetContext, 1.0f, -1.0f);
    CGContextTranslateCTM(targetContext, -targetContextSize.width / 2.0f, -targetContextSize.height / 2.0f);
    [layer renderInContext:targetContext];
    UIGraphicsPopContext();
    
    inBuffer.data = targetMemory;
    inBuffer.width = targetContextSize.width;
    inBuffer.height = targetContextSize.height;
    inBuffer.rowBytes = targetBytesPerRow;
    
    void *pixelBuffer = malloc(targetBytesPerRow * targetContextSize.height);
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = targetContextSize.width;
    outBuffer.height = targetContextSize.height;
    outBuffer.rowBytes = targetBytesPerRow;
    
    TG_TIMESTAMP_DEFINE(convolve)
    vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, 1.0f, NULL, kvImageEdgeExtend);
    TG_TIMESTAMP_MEASURE(convolve)
    
    memcpy(targetMemory, pixelBuffer, targetBytesPerRow * targetContextSize.height);
    free(pixelBuffer);
    
    CGImageRef bitmapImage = CGBitmapContextCreateImage(targetContext);
    UIImage *image0 = [[UIImage alloc] initWithCGImage:bitmapImage scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(bitmapImage);
    
    CGContextRelease(targetContext);
    free(targetMemory);
    
    return @[image0];
}

- (NSArray *)containerLayerSnapshots
{
    return [self blurryLayer:_containerView.layer size:CGSizeMake(_containerView.frame.size.width, _containerView.frame.size.height - _overscrollHeight) withBlurLevel:0.8f];
}

- (void)beginBlur
{
    if (_displayLink == nil)
    {
        NSMutableArray *blurLayers = [[NSMutableArray alloc] init];
        for (UIImage *image in [self containerLayerSnapshots])
        {
            UIImageView *blurLayer0 = [[UIImageView alloc] initWithImage:image];
            blurLayer0.frame = CGRectMake(0.0f, blurStaticOffset + blurDynamicOffset, _containerView.frame.size.width, _containerView.frame.size.height - _overscrollHeight + 0.0f);
            [_containerView insertSubview:blurLayer0 atIndex:0];
            [blurLayers addObject:blurLayer0];
            
            UIImageView *blurLayer1 = [[UIImageView alloc] initWithImage:image];
            blurLayer1.frame = CGRectMake(0.0f, 12.0f, _containerView.frame.size.width, _containerView.frame.size.height - _overscrollHeight + 0.0f);
            [_containerView addSubview:blurLayer1];
            [blurLayers addObject:blurLayer1];
        }
        
        _blurLayers = blurLayers;
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        _lastPosition = _containerView.layer.position;
    }
}

- (void)endBlur
{
    [_displayLink invalidate];
    _displayLink = nil;
    
    for (UIView *view in _blurLayers)
    {
        [view removeFromSuperview];
    }
    _blurLayers = nil;
}

- (void)animateIn
{
    [self animateInInitial:true];
}

- (void)animateInInitial:(bool)initial
{
    [self layoutIfNeeded];
    
    UIEdgeInsets insets = [self insets];
    
    _containerView.frame = CGRectMake(insets.left, self.frame.size.height, self.frame.size.width - insets.left - insets.right, _containerView.frame.size.height);
    
    if (initial)
        _backgroundView.alpha = 0.0f;
    
    if (iosMajorVersion() >= 7)
    {
        //[self beginBlur];
        [UIView animateWithDuration:0.12 delay:0.0 options:(7 << 16) | UIViewAnimationOptionAllowUserInteraction animations:^
        {
            _containerView.frame = CGRectMake(insets.left, self.frame.size.height - _containerView.frame.size.height, self.frame.size.width - insets.left - insets.right, _containerView.frame.size.height);
            _backgroundView.alpha = 1.0f;
        } completion:^(__unused BOOL finished)
        {
            [self dispatchDidAppear];
            //[self endBlur];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^
        {
            _containerView.frame = CGRectMake(insets.left, self.frame.size.height - _containerView.frame.size.height, self.frame.size.width - insets.left - insets.right, _containerView.frame.size.height);
            _backgroundView.alpha = 1.0f;
        } completion:^(__unused BOOL finished)
        {
            [self dispatchDidAppear];
        }];
    }
}

- (void)dispatchDidAppear
{
    for (TGShareSheetItemView *itemView in _items)
    {
        [itemView sheetDidAppear];
    }
}

- (void)dispatchWillDisappear
{
    for (TGShareSheetItemView *itemView in _items)
    {
        [itemView sheetWillDisappear];
    }
}

- (void)tick:(CADisplayLink *)__unused displayLink
{
    CGPoint realPosition = _containerView.layer.presentationLayer == nil ? _containerView.layer.position : ((CALayer *)_containerView.layer.presentationLayer).position;
    CGPoint lastPosition = _lastPosition;
    
    CGFloat dy = (CGFloat)(ABS(realPosition.y - lastPosition.y));
    CGFloat delta = (CGFloat)(dy);
    
    CGFloat unboundedOpacity = 0.0f;
    if (delta > FLT_EPSILON)
    {
        //unboundedOpacity = (CGFloat)log10(delta) / 3.0f;
        unboundedOpacity = delta / 40.0f;
    }

    CGFloat opacity = (CGFloat)MAX(MIN(unboundedOpacity, 1.0f), 0.0f);
    CGFloat offset = blurStaticOffset + blurDynamicOffset * opacity;
    CGFloat secondaryOpacity = opacity * 0.06f;
    if (_blurLayers.count != 0)
    {
        ((UIView *)_blurLayers[0]).alpha = opacity;
        CGRect frame = ((UIView *)_blurLayers[0]).frame;
        frame.origin.y = offset;
        ((UIView *)_blurLayers[0]).frame = frame;
        
        ((UIView *)_blurLayers[1]).alpha = secondaryOpacity;
        ((UIView *)_blurLayers[1]).frame = frame;
    }
    
    _lastPosition = realPosition;
}

- (void)animateOut:(void (^)())completion
{
    [self animateOutWithVelocity:0.0f forInterchange:false completion:completion];
}

- (void)animateOutForInterchange:(bool)interchange completion:(void (^)())completion
{
    [self animateOutWithVelocity:interchange ? 2000.0f : 0.0f forInterchange:interchange completion:completion];
}

- (void)animateOutWithVelocity:(CGFloat)velocity forInterchange:(bool)interchange completion:(void (^)())completion
{
    const CGFloat minVelocity = 400.0f;
    if (ABS(velocity) < minVelocity)
        velocity = (velocity < 0.0f ? -1.0f : 1.0f) * minVelocity;
    CGFloat distance = (velocity < FLT_EPSILON ? -1.0f : 1.0f) * (self.frame.size.height - _containerView.frame.origin.y);
    NSTimeInterval duration = MIN(0.3, (CGFloat)(fabs(distance)) / velocity);
    
    [self dispatchWillDisappear];
    
    UIEdgeInsets insets = [self insets];
    
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^
    {
        _containerView.frame = CGRectMake(insets.left, self.frame.size.height, self.frame.size.width - insets.left - insets.right, _containerView.frame.size.height);
        if (!interchange)
            _backgroundView.alpha = 0.0f;
    } completion:^(__unused BOOL finished)
    {
        if (completion)
            completion();
    }];
}

- (void)setItems:(NSArray *)items
{
    for (TGShareSheetItemView *itemView in _items)
    {
        [itemView removeFromSuperview];
    }
    
    _items = items;
    
    NSMutableArray *separatorViews = [[NSMutableArray alloc] init];
    __weak TGShareSheetView *weakSelf = self;
    for (TGShareSheetItemView *itemView in items)
    {
        itemView.preferredHeightNeedsUpdate = ^(__unused TGShareSheetItemView *itemView) {
            __strong TGShareSheetView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf updateLayout];
            }
        };
        if (itemView != items.lastObject) {
            UIView *separatorView = [[UIView alloc] init];
            separatorView.backgroundColor = TGSeparatorColor();
            [separatorViews addObject:separatorView];
            [_scrollView addSubview:separatorView];
        }
        
        [_scrollView addSubview:itemView];
    }
    
    _separatorViews = separatorViews;
    
    [self updateLayout];
}

- (void)performAnimated:(bool)animated updates:(void (^)(void))updates completion:(void (^)(void))completion
{
    [self performAnimated:animated updates:updates stickToBottom:false completion:completion];
}

- (void)performAnimated:(bool)animated updates:(void (^)(void))updates stickToBottom:(bool)stickToBottom completion:(void (^)(void))completion
{
    if (updates == nil)
        return;
    
    void (^updatesBlock)(void) = ^
    {
        updates();
        [self updateLayout];
        
        if (stickToBottom)
            _scrollView.contentOffset = CGPointMake(0, _scrollView.contentSize.height - _scrollView.bounds.size.height);
    };
    
    if (animated)
    {
        [UIView animateWithDuration:0.3f delay:0.0f options:(7 << 16) | UIViewAnimationOptionLayoutSubviews animations:updatesBlock
                         completion:^(__unused BOOL finished)
        {
            if (completion != nil)
                completion();
        }];
    }
    else
    {
        updatesBlock();
        
        if (completion != nil)
            completion();
    }
}

- (void)scrollToBottomAnimated:(bool)animated
{
    [_scrollView setContentOffset:CGPointMake(0, _scrollView.contentSize.height - _scrollView.bounds.size.height) animated:animated];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self updateLayout];
}

- (void)updateLayout
{
    _backgroundView.frame = self.bounds;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat minScreenHeight = MIN(screenSize.width, screenSize.height);
    CGFloat maxScreenSide = MAX(screenSize.width, screenSize.height);
    
    UIEdgeInsets insets = [self insets];
    
    CGFloat cancelHeight = insets.top + [_cancelItemView preferredHeightForMaximumHeight:CGFLOAT_MAX] + insets.bottom;
    
    CGFloat maxHeight = self.frame.size.width < (maxScreenSide - FLT_EPSILON) ? (maxScreenSide - 20.0f - 44.0f + 4.0f - cancelHeight) : (minScreenHeight - 20.0f - 32.0f + 4.0f - cancelHeight);
    if (self.frame.size.width > self.frame.size.height) {
        maxHeight += 26.0f;
    }
    
    CGFloat maxItemHeight = self.frame.size.width < (maxScreenSide - FLT_EPSILON) ? (maxScreenSide - 20.0f - MAX(cancelHeight, _keyboardOffset)) : (minScreenHeight - 20.0f - MAX(cancelHeight, _keyboardOffset));
    maxItemHeight = MAX(80.0f, maxItemHeight);
    
    CGFloat containerWidth = self.frame.size.width - insets.left - insets.right;
    CGFloat containerHeight = 0.0f;
    CGFloat separatorHeight = TGScreenPixel;
    
    NSInteger index = -1;
    for (TGShareSheetItemView *itemView in _items)
    {
        index++;
        
        CGFloat itemPreferredHeight = [itemView preferredHeightForMaximumHeight:maxItemHeight];
        
        itemView.frame = CGRectMake(0.0f, containerHeight, containerWidth, itemPreferredHeight);
        bool first = itemView == _items.firstObject;
        bool last = itemView == _items.lastObject;
        [itemView setHighlightedImage:[TGShareSheetView selectionBackgroundWithFirst:first last:last]];
        
        containerHeight += itemPreferredHeight;
        
        if (!last) {
            UIView *separatorView = _separatorViews[index];
            separatorView.frame = CGRectMake(0.0f, containerHeight, containerWidth, separatorHeight);
            containerHeight += separatorHeight;
        }
    }
    
    _containerBackgroundView.frame = CGRectMake(0.0f, 0.0f, containerWidth, MIN(maxHeight, containerHeight));
    
    _cancelContainer.frame = CGRectMake(0.0f, MIN(maxHeight, containerHeight) + insets.top + MAX(0.0, _keyboardOffset - cancelHeight), containerWidth, [_cancelItemView preferredHeightForMaximumHeight:CGFLOAT_MAX]);
    [_cancelItemView setHighlightedImage:[TGShareSheetView selectionBackgroundWithFirst:true last:true]];
    _cancelItemView.frame = CGRectMake(0.0f, 0.0f, containerWidth, [_cancelItemView preferredHeightForMaximumHeight:CGFLOAT_MAX]);

    _scrollView.contentSize = CGSizeMake(self.frame.size.width, containerHeight);
    
    _containerView.frame = CGRectMake(insets.left, self.frame.size.height - MIN(maxHeight, containerHeight) - cancelHeight - MAX(0.0f, _keyboardOffset - cancelHeight), containerWidth, MIN(maxHeight, containerHeight) + cancelHeight);
    _scrollViewContainer.frame = CGRectMake(0.0f, 0.0f, _containerView.frame.size.width, _containerView.frame.size.height - cancelHeight);
    _scrollView.frame = _scrollViewContainer.bounds;
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, containerHeight);
    
    _scrollViewMask.frame = _scrollViewContainer.bounds;
    
    bool collapsed = containerHeight > maxHeight;
    
    _swipeRecognizer.enabled = !collapsed;
    
    /*if (collapsed) {
        if (_scrollViewContainer.maskView == nil) {
            _scrollViewContainer.maskView = _scrollViewMask;
        }
    } else {
        if (_scrollViewContainer.maskView != nil) {
            _scrollViewContainer.maskView = nil;
        }
    }*/
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    NSTimeInterval duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] == nil ? 0.3 : [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    int curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGRect screenKeyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrame = [self convertRect:screenKeyboardFrame fromView:nil];
    
    CGFloat keyboardHeight = (keyboardFrame.size.height <= FLT_EPSILON || keyboardFrame.size.width <= FLT_EPSILON) ? 0.0f : (self.frame.size.height - keyboardFrame.origin.y);
    keyboardHeight = MAX(keyboardHeight, 0.0f);
    if (keyboardHeight > FLT_EPSILON) {
        keyboardHeight += [self insets].bottom;
    }
    
    bool followKeyboard = false;
    for (TGShareSheetItemView *itemView in _items) {
        if ([itemView followsKeyboard]) {
            followKeyboard = true;
            break;
        }
    }
    
    if (followKeyboard) {
        if (duration >= FLT_EPSILON) {
            [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
                [self updateKeyboardOffset:keyboardHeight];
            } completion:nil];
        } else {
            [self updateKeyboardOffset:keyboardHeight];
        }
    }
}

- (void)updateKeyboardOffset:(CGFloat)keyboardOffset {
    _keyboardOffset = keyboardOffset;
    
    [self updateLayout];
}

@end
