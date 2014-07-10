/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernView.h"

@class ASHandle;

@interface TGInstantPreviewTouchAreaView : UIView <TGModernView>

@property (nonatomic, strong) ASHandle *notificationHandle;
@property (nonatomic, strong) NSString *touchesBeganAction;
@property (nonatomic, strong) NSDictionary *touchesBeganOptions;
@property (nonatomic, strong) NSString *touchesCompletedAction;
@property (nonatomic, strong) NSDictionary *touchesCompletedOptions;

@end
