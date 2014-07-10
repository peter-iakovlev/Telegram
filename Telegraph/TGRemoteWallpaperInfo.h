/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGWallpaperInfo.h"

@interface TGRemoteWallpaperInfo : TGWallpaperInfo

- (instancetype)initWithRemoteId:(int)remoteId thumbnailUri:(NSString *)thumbnailUri fullscreenUri:(NSString *)fullscreenUri tintColor:(int)tintColor;

@end
