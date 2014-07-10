#import <Foundation/Foundation.h>

@class ALAssetsLibrary;
@class ALAsset;

@interface TGMediaPickerAsset : NSObject

- (instancetype)initWithAssetsLibrary:(ALAssetsLibrary *)assetsLibrary asset:(ALAsset *)asset;

- (NSURL *)url;
- (UIImage *)thumbnail;
- (UIImage *)aspectThumbnail;
- (NSDate *)date;

- (bool)isVideo;
- (NSTimeInterval)videoDuration;

@end
