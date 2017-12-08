/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <LegacyComponents/LegacyComponents.h>

#import "TL/TLMetaScheme.h"

#ifdef __cplusplus
extern "C" {
#endif

void extractUserPhoto(TLUserProfilePhoto *photo, TGUser *target);
TGUserPresence extractUserPresence(TLUserStatus *status);
int extractUserLink(TLcontacts_Link *link);
int extractUserLinkFromUpdate(TLUpdate$updateContactLink *linkUpdate);

#ifdef __cplusplus
}
#endif

@class TGNotificationPrivacyAccountSetting;

@interface TGUser (Telegraph)

- (id)initWithTelegraphUserDesc:(TLUser *)user;

- (TGUser *)applyPrivacyRules:(TGNotificationPrivacyAccountSetting *)privacyRules currentTime:(NSTimeInterval)currentTime;

@end
