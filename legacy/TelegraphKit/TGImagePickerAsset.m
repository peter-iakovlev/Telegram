#import "TGImagePickerAsset.h"

#import "TGImageUtils.h"

#import "NSObject+TGLock.h"

@interface TGImagePickerAsset ()
{
    TG_SYNCHRONIZED_DEFINE(_assetUrl);
}

@end

@implementation TGImagePickerAsset

@synthesize asset = _asset;
@synthesize assetUrl = _assetUrl;
@synthesize thumbnailImage = _thumbnailImage;
@synthesize isLoading = _isLoading;
@synthesize isLoaded = _isLoaded;

- (id)initWithAsset:(ALAsset *)asset
{
    self = [super init];
    if (self != nil)
    {
        TG_SYNCHRONIZED_INIT(_assetUrl);
        
        _asset = asset;
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        TG_SYNCHRONIZED_INIT(_assetUrl);
    }
    return self;
}

- (id)copyWithZone:(NSZone *)__unused zone
{
    TGImagePickerAsset *copyAsset = [[TGImagePickerAsset alloc] init];
    
    copyAsset.asset = _asset;
    copyAsset.assetUrl = _assetUrl;
    copyAsset.thumbnailImage = _thumbnailImage;
    copyAsset.isLoading = _isLoading;
    copyAsset.isLoaded = _isLoaded;
    
    return copyAsset;
}

- (void)setAsset:(ALAsset *)asset
{
    _asset = asset;
}

- (NSString *)assetUrl
{
    NSString *result = nil;
    TG_SYNCHRONIZED_BEGIN(_assetUrl);
    if (_assetUrl == nil && _asset != nil)
        _assetUrl = [[_asset.defaultRepresentation url] absoluteString];
    result = _assetUrl;
    TG_SYNCHRONIZED_END(_assetUrl);

    return _assetUrl;
}

- (void)load
{
    _thumbnailImage = [[UIImage alloc] initWithCGImage:[_asset thumbnail]];
    
    _isLoading = false;
    _isLoaded = true;
}

- (void)unload
{
    _thumbnailImage = nil;
    _isLoaded = false;
}

- (UIImage *)forceLoadedThumbnailImage
{
    if (_thumbnailImage != nil)
        return _thumbnailImage;
 
    if (_asset != nil)
        return [[UIImage alloc] initWithCGImage:[_asset thumbnail]];
    
    return nil;
}

@end
