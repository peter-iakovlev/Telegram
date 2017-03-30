//
//  STPSwitchTableViewCell.h
//  Stripe
//
//  Created by Jack Flintermann on 5/6/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPTheme.h"

@class STPSwitchTableViewCell;

@protocol STPSwitchTableViewCellDelegate <NSObject>

- (void)switchTableViewCell:(STPSwitchTableViewCell *)cell
            didToggleSwitch:(BOOL)on;

@end

@interface STPSwitchTableViewCell : UITableViewCell

@property(nonatomic)BOOL on;
@property(nonatomic)STPTheme *theme;

- (void)configureWithLabel:(NSString *)label
                  delegate:(id<STPSwitchTableViewCellDelegate>)delegate;

@end
