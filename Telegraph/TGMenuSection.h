/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "TGActionMenuItem.h"
#import "TGSwitchItem.h"
#import "TGButtonMenuItem.h"
#import "TGVariantMenuItem.h"

@interface TGMenuSection : NSObject

@property (nonatomic) int tag;
@property (nonatomic) NSString *title;
@property (nonatomic, strong) NSMutableArray *items;

@end
