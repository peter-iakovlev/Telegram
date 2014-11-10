/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGViewController.h"

#import "ASWatcher.h"

#import "TGImagePickerController.h"

@interface TGImageSearchController : TGViewController <ASWatcher>

@property (nonatomic, weak) id<TGImagePickerControllerDelegate> delegate;

@property (nonatomic, strong) ASHandle *actionHandle;
@property (nonatomic, strong) ASHandle *watcherHandle;

@property (nonatomic) bool autoActivateSearch;
@property (nonatomic) bool hideSearchControls;

- (id)initWithAvatarSelection:(bool)avatarSelection;

@end
