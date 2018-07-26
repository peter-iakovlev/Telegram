#import "TGUserInfoAddressCollectionItemView.h"

#import <LegacyComponents/TGImageUtils.h>
#import <LegacyComponents/TGImageView.h>
#import <CoreLocation/CoreLocation.h>

#import "TGPresentation.h"

@interface TGUserInfoAddressCollectionItemView ()
{
    CLPlacemark *_placemark;
    CGSize _cachedImageSize;
    
    TGImageView *_imageView;
}
@end

@implementation TGUserInfoAddressCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _imageView = [[TGImageView alloc] init];
        [self addSubview:_imageView];
    }
    return self;
}

- (void)setPlacemark:(CLPlacemark *)placemark
{
    if (placemark == _placemark)
        return;
    
    _placemark = placemark;
    _cachedImageSize = CGSizeZero;
    [self updateImageIfNeeded];
}

- (void)updateImageIfNeeded
{
    if (_placemark == nil)
    {
        _imageView.image = nil;
        return;
    }
    
    CGSize mapImageSize = _imageView.frame.size;
    
    if (CGSizeEqualToSize(mapImageSize, _cachedImageSize))
        return;
    
    _cachedImageSize = mapImageSize;
    
    NSString *uri = [[NSString alloc] initWithFormat:@"map-thumbnail://?latitude=%f&longitude=%f&width=%d&height=%d&flat=1&cornerRadius=4&offset=-10", _placemark.location.coordinate.latitude, _placemark.location.coordinate.longitude, (int)mapImageSize.width, (int)mapImageSize.height];
    [_imageView loadUri:uri withOptions:@{}];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat mapSide = MIN(90.0f, self.frame.size.height - 18.0f);
    _imageView.frame = CGRectMake(self.frame.size.width - mapSide - 9.0f, TGScreenPixelFloor((self.frame.size.height - mapSide) / 2.0f), mapSide, mapSide);
    
    [self updateImageIfNeeded];
}

@end
