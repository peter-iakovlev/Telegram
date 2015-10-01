/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGViewController.h"

#import "ActionStage.h"
#import "TGUser.h"

@interface TGMapViewController : TGViewController <ASWatcher>

@property (nonatomic, strong) ASHandle *watcher;
@property (nonatomic, strong) ASHandle *actionHandle;

@property (nonatomic, strong) id message;

@property (nonatomic, strong) id activityHolder;

- (id)initInPickingMode;
- (id)initInMapModeWithLatitude:(double)latitude longitude:(double)longitude user:(TGUser *)user;

@end
