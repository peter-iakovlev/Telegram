/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGActor.h"

#import "TL/TLMetaScheme.h"

#import "TGTelegraphProtocols.h"

@interface TGContactRequestActionActor : TGActor

- (void)sendRequestSuccess:(TLcontacts_SentLink *)link;
- (void)sendRequestFailed;

- (void)acceptRequestSuccess:(TLcontacts_Link *)link;
- (void)acceptRequestFailed;

- (void)declineRequestSuccess:(TLcontacts_Link *)link;
- (void)declineRequestFailed;

@end
