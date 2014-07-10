#import "TGModernRemoteImageViewModel.h"

#import "TGModernRemoteImageView.h"

@implementation TGModernRemoteImageViewModel

- (instancetype)initWithUrl:(NSString *)url filter:(NSString *)filter
{
    self = [super init];
    if (self != nil)
    {
        _url = url;
        _filter = filter;
        
        _fadeTransitionDuration = 0.2;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithUrl:nil filter:nil];
}

- (Class)viewClass
{
    return [TGModernRemoteImageView class];
}

- (void)_updateViewStateIdentifier
{
    self.viewStateIdentifier = [[NSString alloc] initWithFormat:@"TGModernRemoteImageView/%@/%@", _url, _url == nil ? nil : _filter];
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [self _updateViewStateIdentifier];
    
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    TGModernRemoteImageView *view = (TGModernRemoteImageView *)[self boundView];
    
    view.fadeTransition = _fadeTransition;
    view.fadeTransitionDuration = _fadeTransitionDuration;
    view.contentHints = _flags;
    
    if (_url.length == 0 || ![[view viewStateIdentifier] isEqualToString:self.viewStateIdentifier])
    {
        if (_url.length == 0)
            [view loadImage:_placeholder];
        else
            [view loadImage:_url filter:_filter placeholder:_placeholder];
    }
}

- (void)setUrl:(NSString *)url
{
    if (!TGStringCompare(url, _url))
    {
        _url = url;
        
        TGModernRemoteImageView *view = (TGModernRemoteImageView *)[self boundView];
        if (view != nil)
        {
            if (_url == nil)
                [view loadImage:_placeholder];
            else
            {
                if (!TGStringCompare(view.currentUrl, _url) || !TGStringCompare(view.currentFilter, _filter))
                    [view loadImage:_url filter:_filter placeholder:_placeholder];
            }
        }
    }
}

- (void)invalidateImage
{
    [self invalidateImage:true];
}

- (void)invalidateImage:(bool)animated
{
    if ([self boundView] != nil)
    {
        TGModernRemoteImageView *imageView = (TGModernRemoteImageView *)[self boundView];
        UIImage *currentImage = [imageView currentImage];
        [imageView loadImage:_url filter:_filter placeholder:currentImage != nil ? currentImage : _placeholder forceFade:currentImage != nil && animated];
    }
}

- (void)drawInContext:(CGContextRef)context
{
    [super drawInContext:context];
    
    if (!self.skipDrawInContext && _placeholder != nil)
        [_placeholder drawInRect:self.bounds blendMode:kCGBlendModeNormal alpha:1.0f];
}

@end
