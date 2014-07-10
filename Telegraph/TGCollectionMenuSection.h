/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "TGCollectionItem.h"

@interface TGCollectionMenuSection : NSObject

@property (nonatomic, readonly, strong) NSArray *items;

@property (nonatomic) UIEdgeInsets insets;

- (instancetype)initWithItems:(NSArray *)items;

@end
