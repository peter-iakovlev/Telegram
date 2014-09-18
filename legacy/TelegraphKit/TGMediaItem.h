/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "TGMessage.h"
#import "TGImageInfo.h"
#import "TGVideoMediaAttachment.h"
#import "TGUser.h"

typedef enum {
    TGMediaItemTypePhoto = 0,
    TGMediaItemTypeVideo = 1
} TGMediaItemType;

@protocol TGMediaItem <NSObject, NSCopying>

@property (nonatomic) TGMediaItemType type;

- (id)itemId;
- (int)date;
- (int)authorUid;
- (TGUser *)author;

- (UIImage *)immediateThumbnail;

- (TGImageInfo *)imageInfo;
- (TGVideoMediaAttachment *)videoAttachment;

@optional

- (int)itemMessageId;
- (id)itemMediaId;

@end
