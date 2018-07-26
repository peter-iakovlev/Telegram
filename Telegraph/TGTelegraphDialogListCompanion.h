/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGDialogListCompanion.h"

#import <LegacyComponents/ActionStage.h>

typedef enum {
    TGDialogListStateNormal = 0,
    TGDialogListStateConnecting = 1,
    TGDialogListStateConnectingToProxy = 2,
    TGDialogListStateUpdating = 3,
    TGDialogListStateWaitingForNetwork = 4,
    TGDialogListStateHasProxyIssues = 5,
} TGDialogListState;

@class TGDialogListController;

@interface TGTelegraphDialogListCompanion : TGDialogListCompanion <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

@property (nonatomic, strong) ASHandle *conversatioSelectedWatcher;

@end
