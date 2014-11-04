#import "TGModernMediaListThumbnailItemView.h"

#import "TGImageView.h"

#import "TGModernGalleryTransitionView.h"

@interface TGModernMediaListThumbnailItemView () <TGModernGalleryTransitionView>
{
    NSString *_imageUri;
}

@end

@implementation TGModernMediaListThumbnailItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _imageView = [[TGImageView alloc] initWithFrame:(CGRect){CGPointZero, frame.size}];
        _imageView.backgroundColor = [UIColor grayColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = true;
        [self addSubview:_imageView];
    }
    return self;
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
    _imageUri = imageUri;
    [_imageView loadUri:imageUri withOptions:@{TGImageViewOptionSynchronous: @(synchronously)}];
}

- (void)updateItem
{
    [_imageView loadUri:_imageUri withOptions:@{TGImageViewOptionKeepCurrentImageAsPlaceholder: @true}];
}

@end
