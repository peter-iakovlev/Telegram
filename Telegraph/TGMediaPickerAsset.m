#import "TGMediaPickerAsset.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface TGMediaPickerAsset ()
{
    ALAssetsLibrary *_assetsLibrary;
    ALAsset *_asset;
}

@end

@implementation TGMediaPickerAsset

- (instancetype)initWithAssetsLibrary:(ALAssetsLibrary *)assetsLibrary asset:(ALAsset *)asset
{
    self = [super init];
    if (self != nil)
    {
        _assetsLibrary = assetsLibrary;
        _asset = asset;
    }
    return self;
}

- (NSURL *)url
{
    return [_asset defaultRepresentation].url;
}

- (UIImage *)thumbnail
{
    return [[UIImage alloc] initWithCGImage:[_asset thumbnail]];
}

- (UIImage *)aspectThumbnail
{
    return [[UIImage alloc] initWithCGImage:[_asset aspectRatioThumbnail]];
}

- (NSDate *)date
{
    return [_asset valueForProperty:ALAssetPropertyDate];
}

- (bool)isVideo
{
    if ([[_asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo])
        return true;
    
    return false;
}

- (NSTimeInterval)videoDuration
{
    return [[_asset valueForProperty:ALAssetPropertyDuration] doubleValue];
}

@end
