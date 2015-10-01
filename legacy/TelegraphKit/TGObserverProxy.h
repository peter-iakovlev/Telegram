/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

@interface TGObserverProxy : NSObject

@property (nonatomic) NSUInteger numberOfRunLoopPassesToDelayTargetNotifications;

- (instancetype)initWithTarget:(id)target targetSelector:(SEL)targetSelector name:(NSString *)name;
- (instancetype)initWithTarget:(id)target targetSelector:(SEL)targetSelector name:(NSString *)name object:(id)object;

@end
