/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGActor.h"

#import "TL/TLMetaScheme.h"

#import "ASWatcher.h"

@interface TGSynchronizeServiceActionsActor : TGActor <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

- (void)changePeerNotificationSettingsSuccess:(TLPeerNotifySettings *)settings;
- (void)changePeerNotificationSettingsFailed;

- (void)resetPeerNotificationSettingsSuccess;
- (void)resetPeerNotificationSettingsFailed;

- (void)changePrivacySettingsSuccess;
- (void)changePrivacySettingsFailed;

- (void)changePeerBlockStatusSuccess;
- (void)changePeerBlockStatusFailed;

- (void)deleteProfilePhotosSucess:(NSArray *)items;
- (void)deleteProfilePhotosFailed:(NSArray *)items;

- (void)sendEncryptedServiceMessageSuccess:(int)date;
- (void)sendEncryptedServiceMessageFailed;

@end
