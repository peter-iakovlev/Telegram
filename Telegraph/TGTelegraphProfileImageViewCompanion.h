/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "ASWatcher.h"

#import "TGImageViewControllerCompanion.h"

#import "TGMediaItem.h"

#import "TGImageMediaAttachment.h"

@interface TGTelegraphProfileImageViewCompanion : NSObject <TGImageViewControllerCompanion, ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;
@property (nonatomic, strong) ASHandle *watcherHandle;

@property (nonatomic, weak) TGImageViewController *imageViewController;
@property (nonatomic) bool reverseOrder;

- (id)initWithUid:(int)uid photoItem:(id<TGMediaItem>)photoItem loadList:(bool)loadList;

@end

@interface TGProfileImageItem : NSObject <TGMediaItem>

@property (nonatomic) TGMediaItemType type;

- (id)initWithProfilePhoto:(TGImageMediaAttachment *)image;
- (void)setExplicitItemId:(id)itemId;

@end
