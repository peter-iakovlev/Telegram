/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGFutureAction.h"

#define TGChangeNotificationSettingsFutureActionType ((int)0xCBF76781)

@interface TGChangeNotificationSettingsFutureAction : TGFutureAction

@property (nonatomic) int muteUntil;
@property (nonatomic) int soundId;
@property (nonatomic) bool previewText;
@property (nonatomic) bool photoNotificationsEnabled;

- (id)initWithPeerId:(int64_t)peerId muteUntil:(int)muteUntil soundId:(int)soundId previewText:(bool)previewText photoNotificationsEnabled:(bool)photoNotificationsEnabled;

@end
