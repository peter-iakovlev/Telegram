/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

@protocol TGModernView;

@interface TGModernViewStorage : NSObject

- (UIView<TGModernView> *)dequeueViewWithIdentifier:(NSString *)identifier viewStateIdentifier:(NSString *)viewStateIdentifier;
- (void)enqueueView:(UIView<TGModernView> *)view;

- (void)allowResurrectionForOperations:(dispatch_block_t)block;

- (void)clear;

@end
