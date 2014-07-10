/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

//
//  CNSHockeyBaseViewController.h
//  HockeySDK
//
//  Created by Andreas Linde on 04.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BITHockeyBaseViewController : UITableViewController

@property (nonatomic, readwrite) BOOL modalAnimated;

- (instancetype)initWithModalStyle:(BOOL)modal;
- (instancetype)initWithStyle:(UITableViewStyle)style modal:(BOOL)modal;

@end
