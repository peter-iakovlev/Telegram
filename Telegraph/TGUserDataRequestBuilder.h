/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "ASActor.h"

#import "TL/TLMetaScheme.h"

@interface TGUserDataRequestBuilder : ASActor

+ (NSString *)genericPath;

+ (void)executeUserLinkUpdates:(NSArray *)usersLinks;

+ (void)executeUserObjectsUpdate:(NSArray *)userObjects;
+ (void)executeUserDataUpdate:(NSArray *)users;

- (void)userDataRequestSuccess:(NSArray *)users;
- (void)userDataRequestFailed;

@end
