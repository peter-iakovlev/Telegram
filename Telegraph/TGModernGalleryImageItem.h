/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernGalleryItem.h"

@class TGImageInfo;

@interface TGModernGalleryImageItem : NSObject <TGModernGalleryItem>

@property (nonatomic, readonly) TGImageInfo *imageInfo;

- (instancetype)initWithImageInfo:(TGImageInfo *)imageInfo;

@end
