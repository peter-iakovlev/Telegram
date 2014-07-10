/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

@interface TGWallpaperInfo : NSObject

- (NSString *)thumbnailUrl;
- (NSString *)fullscreenUrl;
- (int)tintColor;
- (CGFloat)systemAlpha;
- (CGFloat)buttonsAlpha;
- (CGFloat)highlightedButtonAlpha;
- (CGFloat)progressAlpha;

- (UIImage *)image;
- (NSData *)imageData;
- (bool)hasData;

- (NSDictionary *)infoDictionary;
+ (TGWallpaperInfo *)infoWithDictionary:(NSDictionary *)dict;

@end
