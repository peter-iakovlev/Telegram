/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGViewController.h"

#import "ASWatcher.h"

@class TGWallpaperInfo;
@class TGWallpaperController;

@protocol TGWallpaperControllerDelegate <NSObject>

@optional

- (void)wallpaperController:(TGWallpaperController *)wallpaperController didSelectWallpaperWithInfo:(TGWallpaperInfo *)wallpaperInfo;

@end

@interface TGWallpaperController : TGViewController <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

@property (nonatomic, weak) id<TGWallpaperControllerDelegate> delegate;
@property (nonatomic) bool enableWallpaperAdjustment;

- (instancetype)initWithWallpaperInfo:(TGWallpaperInfo *)wallpaperInfo thumbnailImage:(UIImage *)thumbnailImage;

@end
