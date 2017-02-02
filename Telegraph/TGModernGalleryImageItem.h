/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernGalleryItem.h"

#import <SSignalKit/SSignalKit.h>

@class TGImageInfo;
@class TGImageView;

@interface TGModernGalleryImageItem : NSObject <TGModernGalleryItem>

@property (nonatomic, readonly) NSString *uri;
@property (nonatomic, copy, readonly) dispatch_block_t (^loader)(TGImageView *, bool);

@property (nonatomic, readonly) CGSize imageSize;
@property (nonatomic, strong) NSArray *embeddedStickerDocuments;
@property (nonatomic) bool hasStickers;
@property (nonatomic) int64_t imageId;
@property (nonatomic) int64_t accessHash;

- (instancetype)initWithUri:(NSString *)uri imageSize:(CGSize)imageSize;
- (instancetype)initWithLoader:(dispatch_block_t (^)(TGImageView *, bool))loader imageSize:(CGSize)imageSize;
- (instancetype)initWithSignal:(SSignal *)signal imageSize:(CGSize)imageSize;

@end
