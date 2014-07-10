/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

@class TGWallpaperInfo;

@interface TGWallpaperManager : NSObject

+ (instancetype)instance;

- (void)setCurrentWallpaperWithInfo:(TGWallpaperInfo *)wallpaperInfo;

- (UIImage *)currentWallpaperImage;
- (TGWallpaperInfo *)currentWallpaperInfo;

- (NSArray *)builtinWallpaperList;

@end
