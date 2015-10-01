#import "HPGrowingTextView.h"
#import "HPTextViewInternal.h"

@interface HPGrowingTextView ()
{
    bool _ignoreChangeNotification;
}

@end

@implementation HPGrowingTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        [self commonInitialiser];
    }
    return self;
}

- (void)commonInitialiser
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        [HPTextViewInternal addTextViewMethods];
    });
    
    CGRect frame = self.frame;
    frame.origin = CGPointZero;
    _internalTextView = [[HPTextViewInternal alloc] initWithFrame:frame];
    _internalTextView.delegate = self;
    _internalTextView.contentInset = UIEdgeInsetsZero;
    _internalTextView.showsHorizontalScrollIndicator = NO;
    _internalTextView.text = @"-";
    _internalTextView.scrollsToTop = false;
    if (iosMajorVersion() >= 7) {
        _internalTextView.textContainer.layoutManager.allowsNonContiguousLayout = true;
    }
    [self addSubview:_internalTextView];
    
    _minHeight = _internalTextView.frame.size.height;
    _minNumberOfLines = 1;
    
    _animateHeightChange = true;
    _animationDuration = 0.1f;
    
    _internalTextView.text = @"";
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    frame.origin = CGPointZero;
    _internalTextView.frame = frame;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    if (self.text.length == 0)
        size.height = _minHeight;
    
    return size;
}

- (void)setMaxNumberOfLines:(int)maxNumberOfLines
{
    if (maxNumberOfLines == 0 && _maxHeight > 0) // the user specified a maxHeight themselves.
        return;
    
    // Use internalTextView for height calculations, thanks to Gwynne <http://blog.darkrainfall.org/>
    NSString *saveText = _internalTextView.text;
    NSString *newText = @"-";
    
    _internalTextView.delegate = nil;
    _internalTextView.hidden = YES;
    
    for (int i = 1; i < maxNumberOfLines; ++i)
        newText = [newText stringByAppendingString:@"\n|W|"];
    
    _internalTextView.text = newText;
    
    _maxHeight = [self measureHeight];
    
    _internalTextView.text = saveText;
    _internalTextView.hidden = NO;
    _internalTextView.delegate = self;
    
    [self sizeToFit];
    
    _maxNumberOfLines = maxNumberOfLines;
}

- (void)setMaxHeight:(CGFloat)maxHeight
{
    _maxHeight = maxHeight;
    _maxNumberOfLines = 0;
}

- (void)setMinNumberOfLines:(int)minNumberOfLines
{
    if (minNumberOfLines == 0 && _minHeight > 0) // the user specified a minHeight themselves.
        return;

	// Use internalTextView for height calculations, thanks to Gwynne <http://blog.darkrainfall.org/>
    NSString *saveText = _internalTextView.text;
    NSString *newText = @"-";
    
    _internalTextView.delegate = nil;
    _internalTextView.hidden = YES;
    
    for (int i = 1; i < minNumberOfLines; ++i)
        newText = [newText stringByAppendingString:@"\n|W|"];
    
    _internalTextView.text = newText;
    
    _minHeight = [self measureHeight];
    
    _internalTextView.text = saveText;
    _internalTextView.hidden = NO;
    _internalTextView.delegate = self;
    
    [self sizeToFit];
    
    _minNumberOfLines = minNumberOfLines;
}

- (void)setMinHeight:(CGFloat)minHeight
{
    _minHeight = minHeight;
    _minNumberOfLines = 0;
}

- (void)textViewDidChange:(UITextView *)__unused textView
{
    [self refreshHeight];
    if (self.showPlaceholderWhenFocussed)
        _placeholderView.hidden = [_internalTextView hasText];
}

- (void)refreshHeight
{
    CGFloat newSizeH = [self measureHeight]; //size of content, so we can set the frame of self
    
    if(newSizeH < _minHeight || !_internalTextView.hasText)
        newSizeH = _minHeight; //not smalles than minHeight
    
    if (_internalTextView.frame.size.height > _maxHeight)
        newSizeH = _maxHeight; // not taller than maxHeight
    
    id<HPGrowingTextViewDelegate> delegate = _delegate;

	if (ABS(_internalTextView.frame.size.height - newSizeH) > FLT_EPSILON || _oneTimeLongAnimation)
	{
        // [fixed] Pasting too much text into the view failed to fire the height change, 
        // thanks to Gwynne <http://blog.darkrainfall.org/>
        
        if (newSizeH > _maxHeight && _internalTextView.frame.size.height <= _maxHeight)
            newSizeH = _maxHeight;
        
		if (newSizeH <= _maxHeight)
		{
            if (_animateHeightChange && !_internalTextView.isPasting)
            {
                NSTimeInterval currentAnimationDuration = 0.12;
                if (_oneTimeLongAnimation)
                {
                    _oneTimeLongAnimation = false;
                    currentAnimationDuration = 0.3;
                    if (iosMajorVersion() < 7)
                        currentAnimationDuration *= 0.7;
                }
                
                [UIView animateWithDuration:currentAnimationDuration delay:0 options:(UIViewAnimationOptionAllowUserInteraction| UIViewAnimationOptionBeginFromCurrentState) animations:^
                {
                    [self resizeTextView:newSizeH];
                } completion:nil];
                
                if ([delegate respondsToSelector:@selector(growingTextView:willChangeHeight:duration:animationCurve:)])
                    [delegate growingTextView:self willChangeHeight:newSizeH duration:currentAnimationDuration animationCurve:0];
            }
            else
            {
                [self resizeTextView:newSizeH];
                
                if ([delegate respondsToSelector:@selector(growingTextView:willChangeHeight:duration:animationCurve:)])
                    [delegate growingTextView:self willChangeHeight:newSizeH duration:0.0 animationCurve:0];
            }
		}
		
        // scroll to caret (needed on iOS7)
        if (iosMajorVersion() >= 7)
        {
            /*NSRange range = _internalTextView.selectedRange;
            [_internalTextView _scrollRangeToVisible:range animated:false];
            
            CGRect r = [_internalTextView caretRectForPosition:_internalTextView.selectedTextRange.end];
            CGFloat frameHeight = _internalTextView.frame.size.height;
            CGFloat caretY = MAX(r.origin.y - frameHeight + r.size.height + 8, 0);
            if (r.origin.y != INFINITY)
            {
                CGPoint contentOffset = _internalTextView.contentOffset;
                contentOffset.y = caretY;
                _internalTextView.contentOffset = contentOffset;
            }*/
        }
	}
	
    if ([delegate respondsToSelector:@selector(growingTextViewDidChange:afterSetText:afterPastingText:)])
		[delegate growingTextViewDidChange:self afterSetText:_ignoreChangeNotification afterPastingText:_internalTextView.isPasting];

    _oneTimeLongAnimation = false;
}

// Code from apple developer forum - @Steve Krulewitz, @Mark Marszal, @Eric Silverberg
- (CGFloat)measureHeight
{
    if (iosMajorVersion() >= 7)
    {
        CGRect frame = _internalTextView.bounds;
        CGSize fudgeFactor = CGSizeMake(10.0, 17.0);
        
        frame.size.height -= fudgeFactor.height;
        frame.size.width -= fudgeFactor.width;
        
        frame.size.width -= _internalTextView.textContainerInset.right;
        
        NSString *textToMeasure = _internalTextView.text;
        if ([textToMeasure hasSuffix:@"\n"])
        {
            textToMeasure = [NSString stringWithFormat:@"%@-", _internalTextView.text];
        }
        
        NSDictionary *attributes = @{NSFontAttributeName: _internalTextView.font};
        // NSString class method: boundingRectWithSize:options:attributes:context is
        // available only on ios7.0 sdk.
        CGRect size = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes
                                                  context:nil];
        
        return CGFloor(CGRectGetHeight(size) + fudgeFactor.height);
    }
    else
    {
        return CGFloor(self.internalTextView.contentSize.height);
    }
}

- (void)resizeTextView:(CGFloat)newSizeH
{
    CGRect internalTextViewFrame = self.frame;
    internalTextViewFrame.size.height = CGFloor(newSizeH);
    self.frame = internalTextViewFrame;
    
    internalTextViewFrame.origin = CGPointZero;
    if(!CGRectEqualToRect(_internalTextView.frame, internalTextViewFrame))
        _internalTextView.frame = internalTextViewFrame;
    
    //[_internalTextView textViewEnsureSelectionVisible];
}

- (BOOL)becomeFirstResponder
{
    return [_internalTextView becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
	return [_internalTextView resignFirstResponder];
}

- (BOOL)isFirstResponder
{
    return [_internalTextView isFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
    return [_internalTextView canBecomeFirstResponder];
}

- (void)setText:(NSString *)newText
{
    [self setText:newText animated:true];
}

- (void)setText:(NSString *)newText animated:(bool)animated
{
    _internalTextView.text = newText;
    
    _placeholderView.hidden = newText.length != 0 || [_internalTextView isFirstResponder];
    
    // include this line to analyze the height of the textview.
    // fix from Ankit Thakur
    
    bool previousAnimateHeightChange = _animateHeightChange;
    _animateHeightChange = animated;
    _ignoreChangeNotification = true;
    [self performSelector:@selector(textViewDidChange:) withObject:_internalTextView];
    _ignoreChangeNotification = false;
    _animateHeightChange = previousAnimateHeightChange;
}

-(NSString *)text
{
    return _internalTextView.text;
}

- (void)setFont:(UIFont *)afont
{
	_internalTextView.font = afont;
	
	[self setMaxNumberOfLines:_maxNumberOfLines];
	[self setMinNumberOfLines:_minNumberOfLines];
}

- (UIFont *)font
{
	return _internalTextView.font;
}

- (void)setTextColor:(UIColor *)color
{
	_internalTextView.textColor = color;
}

- (UIColor *)textColor
{
	return _internalTextView.textColor;
}

- (void)setTextAlignment:(NSTextAlignment)aligment
{
	_internalTextView.textAlignment = aligment;
}

- (NSTextAlignment)textAlignment
{
	return _internalTextView.textAlignment;
}

#pragma mark -

- (void)textViewDidBeginEditing:(UITextView *)__unused textView
{
    id<HPGrowingTextViewDelegate> delegate = _delegate;
    
	if ([delegate respondsToSelector:@selector(growingTextViewDidBeginEditing:)])
		[delegate growingTextViewDidBeginEditing:self];
    
    if (!self.showPlaceholderWhenFocussed && ![_internalTextView hasText])
        _placeholderView.hidden = true;
}

- (void)textViewDidEndEditing:(UITextView *)__unused textView
{
    id<HPGrowingTextViewDelegate> delegate = _delegate;
    
	if ([delegate respondsToSelector:@selector(growingTextViewDidEndEditing:)])
		[delegate growingTextViewDidEndEditing:self];
    
    if (!self.showPlaceholderWhenFocussed)
        _placeholderView.hidden = [_internalTextView hasText];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)__unused range replacementText:(NSString *)atext
{
    id<HPGrowingTextViewDelegate> delegate = _delegate;
    
    if ([delegate respondsToSelector:@selector(growingTextViewEnabled:)])
        return [delegate growingTextViewEnabled:self];
    
	if (![textView hasText] && [atext isEqualToString:@""])
        return NO;
	
	if ([atext isEqualToString:@"\n"])
    {
        id<HPGrowingTextViewDelegate> delegate = _delegate;
        
		if ([delegate respondsToSelector:@selector(growingTextViewShouldReturn:)])
            return (BOOL)[delegate performSelector:@selector(growingTextViewShouldReturn:) withObject:self];
	}
	
	return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)__unused textView
{
    id<HPGrowingTextViewDelegate> delegate = _delegate;
    
	if ([delegate respondsToSelector:@selector(growingTextViewDidChangeSelection:)])
		[delegate growingTextViewDidChangeSelection:self];
}

- (void)keyCommandPressed:(UIKeyCommand *)keyCommand
{
    id<HPGrowingTextViewDelegate> delegate = _delegate;
    
    if ([delegate respondsToSelector:@selector(growingTextView:receivedReturnKeyCommandWithModifierFlags:)])
        [delegate growingTextView:self receivedReturnKeyCommandWithModifierFlags:keyCommand.modifierFlags];
}

- (NSArray *)keyCommands
{
    return @[ [UIKeyCommand keyCommandWithInput:@"\r" modifierFlags:UIKeyModifierCommand action:@selector(keyCommandPressed:)],
              [UIKeyCommand keyCommandWithInput:@"\r" modifierFlags:UIKeyModifierCommand | UIKeyModifierAlphaShift action:@selector(keyCommandPressed:)]];
}

@end
