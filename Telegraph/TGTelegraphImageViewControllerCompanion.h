/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "TGImageViewControllerCompanion.h"
#import "ActionStage.h"

#import "TGMediaItem.h"

@interface TGTelegraphImageViewControllerCompanion : NSObject <ASWatcher, TGImageViewControllerCompanion>

@property (nonatomic, strong) ASHandle *actionHandle;

@property (nonatomic, weak) TGImageViewController *imageViewController;
@property (nonatomic) bool reverseOrder;

- (id)initWithPeerId:(int64_t)peerId firstItemId:(int)firstItemId isEncrypted:(bool)isEncrypted;

@end

@interface TGMessageMediaItem : NSObject <TGMediaItem>

@property (nonatomic) TGMediaItemType type;

@property (nonatomic, strong) TGImageInfo *imageInfo;
@property (nonatomic, strong) TGVideoMediaAttachment *videoAttachment;
@property (nonatomic, strong) TGUser *author;
@property (nonatomic, strong) TGMessage *message;
@property (nonatomic, strong) id cachedItemId;

- (id)initWithMessage:(TGMessage *)message author:(TGUser *)author imageInfo:(TGImageInfo *)imageInfo;
- (id)initWithMessage:(TGMessage *)message author:(TGUser *)author videoAttachment:(TGVideoMediaAttachment *)videoAttachment;

- (void)replaceMessage:(TGMessage *)message;

- (id)itemId;

- (int)date;
- (int)authorUid;
- (bool)hasLocalId;

- (UIImage *)immediateThumbnail;

@end
