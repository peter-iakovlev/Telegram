/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCollectionMenuController.h"

@class TGAlertSoundController;

@protocol TGAlertSoundControllerDelegate <NSObject>

@optional

- (void)alertSoundController:(TGAlertSoundController *)alertSoundController didFinishPickingWithSoundInfo:(NSDictionary *)soundInfo;

@end

@interface TGAlertSoundController : TGCollectionMenuController

@property (nonatomic, weak) id<TGAlertSoundControllerDelegate> delegate;

- (id)initWithTitle:(NSString *)title soundInfoList:(NSArray *)soundInfoList;

@end
