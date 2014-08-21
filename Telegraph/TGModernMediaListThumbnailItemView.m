#import "TGModernMediaListThumbnailItemView.h"

#import "TGImageView.h"

#import "TGModernGalleryTransitionView.h"

@interface TGModernMediaListThumbnailItemView () <TGModernGalleryTransitionView>
{
    TGImageView *_imageView;
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
    
    _imageView.frame = (CGRect){CGPointZero, frame.size};
}

- (void)setImageUri:(NSString *)imageUri
{
    _imageUri = imageUri;
    [_imageView loadUri:imageUri withOptions:@{}];
}

- (void)updateItem
{
    [_imageView loadUri:_imageUri withOptions:@{TGImageViewOptionKeepCurrentImageAsPlaceholder: @true}];
}

@end
