/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGDialogListCompanion.h"

#import "ActionStage.h"

@class TGDialogListController;

@interface TGTelegraphDialogListCompanion : TGDialogListCompanion <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

@property (nonatomic, strong) ASHandle *conversatioSelectedWatcher;

@end
