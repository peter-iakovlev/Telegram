/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGActor.h"

#import "tl/TLMetaScheme.h"

#import "ASWatcher.h"

@interface TGConversationChangePhotoActor : TGActor <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

@property (nonatomic, strong) id currentImage;

- (void)conversationUpdateAvatarSuccess:(TLUpdates *)result;
- (void)conversationUpdateAvatarFailed;

@end
