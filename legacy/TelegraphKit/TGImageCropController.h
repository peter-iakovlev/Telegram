/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGViewController.h"

#import "ASWatcher.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "TGCache.h"
#import "TGImageInfo.h"

@interface TGImageCropController : TGViewController <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;
@property (nonatomic, strong) ASHandle *watcherHandle;

@property (nonatomic, strong) TGCache *customCache;

- (id)initWithAsset:(ALAsset *)asset;
- (id)initWithImageInfo:(TGImageInfo *)imageInfo thumbnail:(UIImage *)thumbnail;
- (instancetype)initWithImage:(UIImage *)image;

@end
