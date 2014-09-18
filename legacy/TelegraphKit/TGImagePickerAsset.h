/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import <AssetsLibrary/AssetsLibrary.h>

@interface TGImagePickerAsset : NSObject <NSCopying>

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, strong) NSString *assetUrl;

@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic) bool isLoading;
@property (nonatomic) bool isLoaded;

- (id)initWithAsset:(ALAsset *)asset;
- (id)init;

- (void)load;
- (void)unload;

- (UIImage *)forceLoadedThumbnailImage;

@end
