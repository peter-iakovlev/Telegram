#import "TGPreviewLocationItemView.h"

#import "TGLocationMediaAttachment.h"

#import "TGImageView.h"
#import "TGLocationMapView.h"
#import "TGLocationAnnotation.h"

@interface TGPreviewLocationItemView ()
{
    CLLocation *_location;
    TGLocationAnnotation *_annotation;
    
    TGImageView *_imageView;
    CGSize _imageSize;
    TGLocationMapView *_mapView;
}
@end

@implementation TGPreviewLocationItemView

- (instancetype)initWithLocationAttachment:(TGLocationMediaAttachment *)attachment
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:attachment.latitude longitude:attachment.longitude];
    return [self initWithLocation:location];
}

- (instancetype)initWithLocation:(CLLocation *)location
{
    self = [super initWithType:TGMenuSheetItemTypeDefault];
    if (self != nil)
    {
        _location = location;
        
        _imageView = [[TGImageView alloc] initWithFrame:self.bounds];
        _imageView.backgroundColor = UIColorRGB(0xf9f5ed);
        [self addSubview:_imageView];
    }
    return self;
}

- (void)menuView:(TGMenuSheetView *)__unused menuView willAppearAnimated:(bool)__unused animated
{
    CGSize mapImageSize = _imageSize;
    NSString *uri = [[NSString alloc] initWithFormat:@"map-thumbnail://?latitude=%f&longitude=%f&width=%d&height=%d&flat=1&cornerRadius=-1", _location.coordinate.latitude, _location.coordinate.longitude, (int)mapImageSize.width, (int)mapImageSize.height];
    [_imageView loadUri:uri withOptions:@{}];
}

- (CGFloat)preferredHeightForWidth:(CGFloat)__unused width screenHeight:(CGFloat)__unused screenHeight
{
    _imageSize = CGSizeMake(width, 200.0f);
    return _imageSize.height;;
}

- (void)layoutSubviews
{
    _imageView.frame = self.bounds;
}

@end
