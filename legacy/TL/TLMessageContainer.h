/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "TLObject.h"


@interface TLMessageContainer : NSObject <TLObject>

@property (nonatomic, retain) NSArray *messages;

- (void)TLserialize:(NSOutputStream *)os;

@end

@interface TLMessageContainer$msg_container : TLMessageContainer


@end

