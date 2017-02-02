/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernGalleryItem.h"

@class TGVideoMediaAttachment;

@interface TGModernGalleryVideoItem : NSObject <TGModernGalleryItem>

@property (nonatomic, strong, readonly) id media;
@property (nonatomic, strong, readonly) NSString *previewUri;
@property (nonatomic, strong, readonly) id videoDownloadArguments;

- (instancetype)initWithMedia:(id)media previewUri:(NSString *)previewUri;

@end
