#import "TGAssetImageView.h"

#import "TGAssetImageManager.h"

#import <MTProtoKit/MTTime.h>

@implementation TGAssetImageView
{
    NSUInteger _loadToken;
    volatile NSInteger _version;
}

- (void)loadWithImage:(UIImage *)image
{
    [self _maybeCancelOngoingRequest];
    
    [self _commitImage:image partial:false loadTime:0.0];
}

- (void)loadWithAsset:(TGMediaPickerAsset *)asset imageType:(TGAssetImageType)imageType size:(CGSize)size
{
    [self loadWithAsset:asset imageType:imageType size:size completionBlock:nil];
}

- (void)loadWithAsset:(TGMediaPickerAsset *)asset imageType:(TGAssetImageType)imageType size:(CGSize)size completionBlock:(void (^)(UIImage *))completionBlock
{
    [self _maybeCancelOngoingRequest];
    
    __weak TGAssetImageView *weakSelf = self;
    NSInteger version = _version;
    
    _loadToken = [TGAssetImageManager requestImageWithAsset:asset imageType:imageType size:size synchronous:false progressBlock:^(CGFloat progress)
    {
        __strong TGAssetImageView *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf performProgressUpdate:progress];
    } completionBlock:^(UIImage *image, __unused NSError *error)
    {
        __strong TGAssetImageView *strongSelf = weakSelf;
        if (strongSelf != nil && strongSelf->_version == version)
        {
            strongSelf->_loadToken = 0;
            
            TGDispatchOnMainThread(^
            {
                [strongSelf _commitImage:image partial:false loadTime:0.0];
                
                if (completionBlock != nil)
                    completionBlock(image);
            });
        }
    }];
}

- (void)reset
{
    [self _maybeCancelOngoingRequest];
    
    [self _commitImage:nil partial:false loadTime:0.0];
}

- (void)_maybeCancelOngoingRequest
{
    _version++;
    
    if (_loadToken != 0)
    {
        [TGAssetImageManager cancelRequestWithToken:_loadToken];
        _loadToken = 0;
    }
}

- (void)performProgressUpdate:(CGFloat)progress
{
    [super performProgressUpdate:progress];
    
    if (_progressChanged)
        _progressChanged(progress);
}

- (void)_commitImage:(UIImage *)image partial:(bool)partial loadTime:(NSTimeInterval)loadTime
{
    [super _commitImage:image partial:partial loadTime:loadTime];
    
    bool available = (self.currentImage != nil && self.currentImage.size.width > 1 && self.currentImage.size.height > 1);
    if (_availabilityStateChanged)
        _availabilityStateChanged(available && !partial);
}

- (bool)isAvailableNow
{
    bool available = (self.currentImage != nil && self.currentImage.size.width > 1 && self.currentImage.size.height > 1);
    return available;
}

@end
