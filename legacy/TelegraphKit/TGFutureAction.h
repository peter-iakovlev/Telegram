/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

@interface TGFutureAction : NSObject

@property (nonatomic) int64_t uniqueId;
@property (nonatomic) int type;
@property (nonatomic) int randomId;

- (id)initWithType:(int)type;

- (NSData *)serialize;
- (TGFutureAction *)deserialize:(NSData *)data;
- (void)prepareForDeletion;

@end
