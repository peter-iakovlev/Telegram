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
#import "TGImageView.h"

#import "TGModernGalleryImageItemImageView.h"
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
        __weak TGModernGalleryImageItemView *weakSelf = self;
        _imageView = [[TGModernGalleryImageItemImageView alloc] init];
        _imageView.progressChanged = ^(float value)
        {
            __strong TGModernGalleryImageItemView *strongSelf = weakSelf;
            [strongSelf setProgressVisible:value < 1.0f - FLT_EPSILON value:value animated:true];
        };
        [self.scrollView addSubview:_imageView];
        
        //_imageView.layer.shadowColor = [UIColor blackColor].CGColor;
        //_imageView.layer.shadowOpacity = 0.7f;
        //_imageView.layer.shadowRadius = 20.0f;
    }
    return self;
}

- (void)prepareForRecycle
{
    [_imageView reset];
    [self setProgressVisible:false value:0.0f animated:false];
}

- (void)setItem:(TGModernGalleryImageItem *)item synchronously:(bool)synchronously
{
    [super setItem:item synchronously:synchronously];
    
    _imageSize = item.imageSize;
    
    if (item.uri == nil)
        [_imageView reset];
    else
        [_imageView loadUri:item.uri withOptions:@{TGImageViewOptionSynchronous: @(synchronously)}];
    
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
