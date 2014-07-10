/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCollectionItemView.h"

#import "ASWatcher.h"

@class TGWallpaperInfo;

@interface TGWallpapersCollectionItemView : TGCollectionItemView

@property (nonatomic, strong) ASHandle *itemHandle;

- (void)setTitle:(NSString *)title;
- (void)setSelectedWallpaperInfo:(TGWallpaperInfo *)selectedWallpaperInfo;
- (void)setWallpaperInfos:(NSArray *)wallpaperInfos synchronous:(bool)synchronous;

@end
