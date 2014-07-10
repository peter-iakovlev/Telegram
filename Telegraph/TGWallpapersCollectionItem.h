/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCollectionItem.h"

#import "ASWatcher.h"

@class TGWallpaperInfo;

@interface TGWallpapersCollectionItem : TGCollectionItem <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;
@property (nonatomic, strong) ASHandle *interfaceHandle;
@property (nonatomic, strong) NSString *title;

- (instancetype)initWithAction:(SEL)action title:(NSString *)title;

- (void)setCurrentWallpaperInfo:(TGWallpaperInfo *)currentWallpaperInfo;

@end
