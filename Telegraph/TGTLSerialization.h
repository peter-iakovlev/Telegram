/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <MTProtoKit/MTSerialization.h>

#import "TL/TLMetaScheme.h"

@interface TGTLSerialization : NSObject <MTSerialization>

+ (NSData *)serializeMessage:(id)message;
+ (id)parseResponse:(NSData *)data request:(TLMetaRpc *)request;

@end
