/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGWallpaperInfo.h"

@interface TGBuiltinWallpaperInfo : TGWallpaperInfo

- (instancetype)initWithBuiltinId:(int)builtinId;
- (instancetype)initWithBuiltinId:(int)builtinId tintColor:(int)tintColor systemAlpha:(CGFloat)systemAlpha buttonsAlpha:(CGFloat)buttonsAlpha highlightedButtonAlpha:(CGFloat)highlightedButtonAlpha progressAlpha:(CGFloat)progressAlpha version:(int32_t)version;

- (BOOL)isDefault;
- (int32_t)version;

@end

extern const int32_t TGBuilitinWallpaperCurrentVersion;
