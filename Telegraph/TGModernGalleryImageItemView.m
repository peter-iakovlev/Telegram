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

@interface TGModernGalleryImageItemView ()

@end

@implementation TGModernGalleryImageItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _imageView = [[TGRemoteImageView alloc] init];
        [self.scrollView addSubview:_imageView];
    }
    return self;
}

- (void)prepareForRecycle
{
    [_imageView loadImage:nil];
}

- (void)setItem:(TGModernGalleryImageItem *)item
{
    [super setItem:item];
    
    _imageSize = CGSizeZero;
    NSString *uri = [item.imageInfo closestImageUrlWithSize:CGSizeMake(1000.0f, 1000.0f) resultingSize:&_imageSize];
    if (uri == nil)
        [_imageView loadImage:nil];
    else
        [_imageView loadImage:uri filter:@"maybeScale" placeholder:nil];
    _imageView.frame = CGRectMake(0.0f, 0.0f, _imageSize.width, _imageSize.height);
}

- (CGSize)contentSize
{
    return _imageSize;
}

- (UIView *)contentView
{
    return _imageView;
}

@end
