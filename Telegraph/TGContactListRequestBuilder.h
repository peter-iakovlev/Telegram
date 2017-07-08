/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "ASActor.h"

#import "TGUser.h"

#import "TL/TLMetaScheme.h"

#import "TGTelegraphProtocols.h"

#import "TGSynchronizeContactsActor.h"

@interface TGContactListRequestBuilder : ASActor

+ (NSString *)genericPath;

+ (void)dispatchNewContactList;
+ (void)dispatchNewPhonebook;

+ (NSDictionary *)cachedPhonebook;
+ (NSDictionary *)cachedInvitees;
+ (NSDictionary *)synchronousContactList;
+ (void)clearCache;

@end
