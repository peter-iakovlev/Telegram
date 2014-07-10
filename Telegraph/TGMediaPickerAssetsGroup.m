#import "TGMediaPickerAssetsGroup.h"

@interface TGMediaPickerAssetsGroup ()
{
    NSArray *_latestAssets;
    UIImage *_groupThumbnail;
    
    NSString *_persistentId;
    NSString *_title;
    NSUInteger _assetCount;
}

@end

@implementation TGMediaPickerAssetsGroup

- (instancetype)initWithLatestAssets:(NSArray *)latestAssets groupThumbnail:(UIImage *)groupThumbnail persistentId:(NSString *)persistentId title:(NSString *)title assetCount:(NSUInteger)assetCount
{
    self = [super init];
    if (self != nil)
    {
        _latestAssets = latestAssets;
        _groupThumbnail = groupThumbnail;
        _persistentId = persistentId;
        _title = title;
        _assetCount = assetCount;
    }
    return self;
}

- (NSArray *)latestAssets
{
    return _latestAssets;
}

- (UIImage *)groupThumbnail
{
    return _groupThumbnail;
}

- (NSString *)persistentId
{
    return _persistentId;
}

- (NSString *)title
{
    return _title;
}

- (NSUInteger)assetCount
{
    return _assetCount;
}

@end
