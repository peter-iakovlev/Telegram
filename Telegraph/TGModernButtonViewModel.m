#import "TGModernButtonViewModel.h"

#import "TGModernButtonView.h"

@implementation TGModernButtonViewModel

- (Class)viewClass
{
    return [TGModernButtonView class];
}

- (void)_updateViewStateIdentifier
{
    self.viewStateIdentifier = [[NSString alloc] initWithFormat:@"TGModernButtonView/%lx/%lx/%@/%lx/%lx", (long)_backgroundImage, (long)_highlightedBackgroundImage, _title, (long)_font, (long)_image];
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [self _updateViewStateIdentifier];
    
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    TGModernButtonView *view = (TGModernButtonView *)[self boundView];
    if (!TGStringCompare(view.viewStateIdentifier, self.viewStateIdentifier))
    {
        [view setBackgroundImage:_backgroundImage];
        [view setHighlightedBackgroundImage:_highlightedBackgroundImage];
        [view setTitle:_title];
        [view setTitleFont:_font];
        [view setImage:_image];
        [view setHighlightedImage:_highlightedImage];
        [view setExtendedEdgeInsets:_extendedEdgeInsets];
        [view setSupplementaryIcon:_supplementaryIcon];
        
        [view setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [view setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 4.0f, 0.0f, 4.0f)];
        [view.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    }
    
    [view addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    view.modernHighlight = _modernHighlight;
    
    [view setDisplayProgress:_displayProgress animated:false];
}

- (void)unbindView:(TGModernViewStorage *)viewStorage {
    [(TGModernButtonView *)self.boundView removeTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    [super unbindView:viewStorage];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    _possibleTitles = nil;
    
    if ([self boundView] != nil)
    {
        [(TGModernButtonView *)[self boundView] setTitle:_title];
    }
}

- (void)setPossibleTitles:(NSArray *)possibleTitles
{
    _possibleTitles = possibleTitles;
    _title = nil;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    if ([self boundView] != nil)
        [(TGModernButtonView *)[self boundView] setImage:_image];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    
    if ([self boundView] != nil)
        [(TGModernButtonView *)[self boundView] setBackgroundImage:_backgroundImage];
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    CGSize textSize = CGSizeMake(_titleInset.left + _titleInset.right, 0.0f);
    
    if (_possibleTitles.count != 0)
    {
        NSString *bestMatchTitle = nil;
        CGSize bestMatchSize = CGSizeZero;
        
        for (NSString *title in _possibleTitles)
        {
            bestMatchTitle = title;
            bestMatchSize = [title sizeWithFont:_font];
            
            if (bestMatchSize.width + textSize.width <= containerSize.width)
                break;
        }
        
        _title = bestMatchTitle;
        if ([self boundView] != nil)
            [(TGModernButtonView *)[self boundView] setTitle:_title];
        
        textSize.width += bestMatchSize.width;
        textSize.height += bestMatchSize.height;
    }
    else
    {
        CGSize titleSize = [_title sizeWithFont:_font];
        textSize.width += titleSize.width;
        textSize.height += titleSize.height;
    }
    
    CGRect frame = self.frame;
    frame.size = CGSizeMake(MIN(textSize.width, containerSize.width), _backgroundImage.size.height);
    self.frame = frame;
}

- (void)drawInContext:(CGContextRef)__unused context
{
    if (!self.skipDrawInContext && self.alpha > FLT_EPSILON && !self.hidden)
    {
        if (_backgroundImage != nil)
            [_backgroundImage drawInRect:self.bounds blendMode:kCGBlendModeNormal alpha:1.0f];
        if (_image != nil)
        {
            CGRect bounds = self.bounds;
            CGSize imageSize = _image.size;
            [_image drawInRect:CGRectMake(CGFloor((bounds.size.width - imageSize.width) / 2.0f), CGFloor((bounds.size.height - imageSize.height) / 2.0f), imageSize.width, imageSize.height)];
        }
        if (_title.length != 0) {
            CGSize titleSize = [_title sizeWithFont:_font];
            [_title drawInRect:CGRectMake(CGFloor(self.frame.size.width - titleSize.width), CGFloor(self.frame.size.height - titleSize.height), titleSize.width, titleSize.height) withFont:_font];
        }
    }
}

- (void)buttonPressed {
    if (_pressed) {
        _pressed();
    }
}

- (void)setDisplayProgress:(bool)displayProgress {
    [self setDisplayProgress:displayProgress animated:true];
}

- (void)setDisplayProgress:(bool)displayProgress animated:(bool)animated {
    _displayProgress = displayProgress;
    [(TGModernButtonView *)[self boundView] setDisplayProgress:displayProgress animated:animated];
}

@end
