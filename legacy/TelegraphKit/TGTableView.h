/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@class TGTableView;

typedef void (^TGTableViewBlock)(TGTableView *tableView);

@interface TGTableView : UITableView

@property (nonatomic) UIEdgeInsets scrollInsets;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style reversed:(bool)reversed;

@property (nonatomic, copy) TGTableViewBlock didLayoutBlock;

@end
