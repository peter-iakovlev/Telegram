/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernGalleryImageItemView.h"

#import "TGModernGalleryImageItem.h"

#import "TGImageInfo.h"
#import "TGRemoteImageView.h"

#import "TGModernGalleryZoomableScrollView.h"

@interface TGModernGalleryImageItemView ()
{
}

@end

@implementation TGModernGalleryImageItemView

- (UIImage *)shadowImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        
    });
    return image;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _imageView = [[TGRemoteImageView alloc] init];
        [self.scrollView addSubview:_imageView];
        
        //_imageView.layer.shadowColor = [UIColor blackColor].CGColor;
        //_imageView.layer.shadowOpacity = 0.7f;
        //_imageView.layer.shadowRadius = 20.0f;
    }
    return self;
}

- (void)prepareForRecycle
{
    [_imageView loadImage:nil];
}

- (void)setItem:(TGModernGalleryImageItem *)item synchronously:(bool)synchronously
{
    [super setItem:item synchronously:synchronously];
    
    _imageSize = CGSizeZero;
    NSString *uri = [item.imageInfo closestImageUrlWithSize:CGSizeMake(1000.0f, 1000.0f) resultingSize:&_imageSize];
    if (uri == nil)
        [_imageView loadImage:nil];
    else
    {
        UIImage *loadedImage = nil;
        if (synchronously)
            loadedImage = [[TGRemoteImageView sharedCache] cachedImage:uri availability:TGCacheDisk];
        
        if (loadedImage != nil)
            [_imageView loadImage:loadedImage];
        else
            [_imageView loadImage:uri filter:@"maybeScale" placeholder:nil];
    }
    
    [self reset];
}

- (CGSize)contentSize
{
    return _imageSize;
}

- (UIView *)contentView
{
    return _imageView;
}

- (UIView *)transitionView
{
    return _imageView;
}

@end
