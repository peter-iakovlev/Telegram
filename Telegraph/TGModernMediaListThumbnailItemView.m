#import "TGModernMediaListThumbnailItemView.h"

#import <LegacyComponents/TGImageView.h>

#import <LegacyComponents/TGModernGalleryTransitionView.h>

@interface TGModernMediaListThumbnailItemView () <TGModernGalleryTransitionView>
{
    NSString *_imageUri;
    SSignal *_signal;
}

@end

@implementation TGModernMediaListThumbnailItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _imageView = [[TGImageView alloc] initWithFrame:(CGRect){CGPointZero, frame.size}];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = true;
        [self addSubview:_imageView];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [_imageView reset];
}

- (UIImage *)transitionImage
{
    return _imageView.image;
}

- (void)setIsHidden:(bool)isHidden
{
    [super setIsHidden:isHidden];
    
    self.hidden = isHidden;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGAffineTransform transform = _imageView.transform;
    _imageView.transform = CGAffineTransformIdentity;
    _imageView.frame = (CGRect){CGPointZero, frame.size};
    _imageView.transform = transform;
}

- (void)setImageUri:(NSString *)imageUri
{
    [self setImageUri:imageUri synchronously:false];
}

- (void)setImageUri:(NSString *)imageUri synchronously:(bool)synchronously
{
    _signal = nil;
    _imageUri = imageUri;
    [_imageView loadUri:imageUri withOptions:@{TGImageViewOptionSynchronous: @(synchronously)}];
}

- (void)setImageSignal:(SSignal *)signal {
    _imageUri = nil;
    _signal = signal;
    [_imageView setSignal:signal];
}

- (void)updateItem
{
    if (_signal != nil) {
        [_imageView setSignal:_signal];
    } else {
        [_imageView loadUri:_imageUri withOptions:@{TGImageViewOptionKeepCurrentImageAsPlaceholder: @true}];
    }
}

@end
