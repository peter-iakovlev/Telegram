#import "TGMediaPickerAsset.h"

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "TGAssetImageManager.h"

#import "TGStringUtils.h"

@interface TGMediaPickerAsset ()
{
    PHAsset *_asset;
    ALAsset *_legacyAsset;
    
    NSArray *_burstAssets;
    
    NSString *_cachedUniqueId;
    NSURL *_cachedLegacyAssetUrl;
    NSNumber *_cachedDuration;
    
    NSNumber *_legacyIsVideoRotated;
}
@end

@implementation TGMediaPickerAsset

- (instancetype)initWithPHAsset:(PHAsset *)asset
{
    self = [super init];
    if (self != nil)
    {
        _asset = asset;
        
        if (_asset.representsBurst || _asset.burstIdentifier != nil)
        {
            NSMutableArray *burstAssets = [[NSMutableArray alloc] init];
            PHFetchResult *burstFetchResult = [PHAsset fetchAssetsWithBurstIdentifier:_asset.burstIdentifier options:nil];
            for (PHAsset *burstAsset in burstFetchResult)
                [burstAssets addObject:burstAsset];
            
            _burstAssets = burstAssets;
        }
    }
    return self;
}

- (instancetype)initWithALAsset:(ALAsset *)asset
{
    self = [super init];
    if (self != nil)
    {
        _legacyAsset = asset;
    }
    return self;
}

- (NSString *)persistentId
{
    if (self.backingAsset != nil)
        return self.backingAsset.localIdentifier;
    
    return nil;
}

- (NSURL *)url
{
    if (self.backingLegacyAsset != nil)
    {
        if (!_cachedLegacyAssetUrl)
            _cachedLegacyAssetUrl = [self.backingLegacyAsset defaultRepresentation].url;
        
        return _cachedLegacyAssetUrl;
    }
    
    return nil;
}

- (CGSize)dimensions
{
    if (self.backingAsset != nil)
    {
        return CGSizeMake(self.backingAsset.pixelWidth, self.backingAsset.pixelHeight);
    }
    else if (self.backingLegacyAsset != nil)
    {
        CGSize dimensions = self.backingLegacyAsset.defaultRepresentation.dimensions;
        
        if (self.isVideo)
        {
            bool videoRotated = false;
            if (_legacyIsVideoRotated == nil)
            {
                CGImageRef thumbnailImage = self.backingLegacyAsset.aspectRatioThumbnail;
                CGSize thumbnailSize = CGSizeMake(CGImageGetWidth(thumbnailImage), CGImageGetHeight(thumbnailImage));
                bool thumbnailIsWide = (thumbnailSize.width > thumbnailSize.height);
                bool videoIsWide = (dimensions.width > dimensions.height);
                
                videoRotated = (thumbnailIsWide != videoIsWide);
                _legacyIsVideoRotated = @(videoRotated);
            }
            else
            {
                videoRotated = _legacyIsVideoRotated.boolValue;
            }
            if (videoRotated)
                dimensions = CGSizeMake(dimensions.height, dimensions.width);
        }
        
        return dimensions;
    }
    
    return CGSizeZero;
}

- (NSDate *)date
{
    if (self.backingAsset != nil)
        return self.backingAsset.creationDate;
    else if (self.backingLegacyAsset != nil)
        return [self.backingLegacyAsset valueForProperty:ALAssetPropertyDate];
    
    return nil;
}

- (bool)isVideo
{
    return self.type == TGMediaPickerAssetVideoType;
}

- (bool)representsBurst
{
    return (_burstAssets.count > 0);
}

- (TGMediaPickerAssetType)type
{
    if (self.backingAsset != nil)
    {
        return TGMediaPickerAssetTypeForPHAssetMediaType(self.backingAsset.mediaType);
    }
    else if (self.backingLegacyAsset != nil)
    {
        if ([[self.backingLegacyAsset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo])
            return TGMediaPickerAssetVideoType;
    }
    
    return TGMediaPickerAssetPhotoType;
}

- (TGMediaPickerAssetSubtype)subtypes
{
    TGMediaPickerAssetSubtype subtypes = TGMediaPickerAssetSubtypeNone;
    
    if (self.backingAsset != nil)
    {
        subtypes = TGMediaPickerAssetSubtypesForPHAssetMediaSubtypes(self.backingAsset.mediaSubtypes);
    }
    else if (self.backingLegacyAsset != nil)
    {

    }
    
    return subtypes;
}

- (NSTimeInterval)videoDuration
{
    if (self.backingAsset != nil)
    {
        return self.backingAsset.duration;
    }
    else if (self.backingLegacyAsset != nil)
    {
        return [[self.backingLegacyAsset valueForProperty:ALAssetPropertyDuration] doubleValue];
    }
    
    return 0;
}

- (NSTimeInterval)actualVideoDuration
{
    if (!self.isVideo)
        return 0;
    
    if (self.subtypes & TGMediaPickerAssetSubtypeVideoHighFrameRate)
    {
        if (!_cachedDuration)
        {
            AVAsset *avAsset = [TGAssetImageManager avAssetForVideoAsset:self];
            NSTimeInterval duration = CMTimeGetSeconds(avAsset.duration);
            if (duration > DBL_EPSILON)
                _cachedDuration = @(duration);
        }
        
        return _cachedDuration.doubleValue;
    }
    
    return self.videoDuration;
}

- (PHAsset *)backingAsset
{
    return _asset;
}

- (ALAsset *)backingLegacyAsset
{
    return _legacyAsset;
}

- (NSString *)uniqueId
{
    if (!_cachedUniqueId)
    {
        if (self.backingAsset != nil)
            _cachedUniqueId = self.persistentId;
        else if (self.backingLegacyAsset != nil)
            _cachedUniqueId = self.url.absoluteString;
    }
    
    return _cachedUniqueId;
}

- (BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    
    return [self.uniqueId isEqual:((TGMediaPickerAsset *)object).uniqueId];
}

TGMediaPickerAssetType TGMediaPickerAssetTypeForPHAssetMediaType(PHAssetMediaType type)
{
    switch (type)
    {
        case PHAssetMediaTypeImage:
            return TGMediaPickerAssetPhotoType;
            
        case PHAssetMediaTypeVideo:
            return TGMediaPickerAssetVideoType;
                        
        default:
            return TGMediaPickerAssetAnyType;
    }
}

TGMediaPickerAssetSubtype TGMediaPickerAssetSubtypesForPHAssetMediaSubtypes(PHAssetMediaSubtype subtypes)
{
    TGMediaPickerAssetSubtype result = TGMediaPickerAssetSubtypeNone;
    
    if (subtypes & PHAssetMediaSubtypePhotoPanorama)
        result |= TGMediaPickerAssetSubtypePhotoPanorama;
    
    if (subtypes & PHAssetMediaSubtypePhotoHDR)
        result |= TGMediaPickerAssetSubtypePhotoHDR;
    
    if (subtypes & PHAssetMediaSubtypeVideoStreamed)
        result |= TGMediaPickerAssetSubtypeVideoStreamed;
    
    if (subtypes & PHAssetMediaSubtypeVideoHighFrameRate)
        result |= TGMediaPickerAssetSubtypeVideoHighFrameRate;
    
    if (subtypes & PHAssetMediaSubtypeVideoTimelapse)
        result |= TGMediaPickerAssetSubtypeVideoTimelapse;
    
    return result;
}

@end
