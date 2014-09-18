/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "ASWatcher.h"

#import "TGDateLabel.h"
#import "TGUser.h"
#import "TGToolbar.h"
#import "TGButton.h"
#import "TGModernBackToolbarButton.h"

@interface TGImageViewControllerInterfaceView : UIView <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;
@property (nonatomic, strong) ASHandle *watcherHandle;
@property (nonatomic, strong) ASHandle *pageHandle;

@property (nonatomic, strong) TGToolbar *navigationBar;
@property (nonatomic, strong) TGModernBackToolbarButton *doneButton;
@property (nonatomic, strong) TGModernToolbarButton *editButton;
@property (nonatomic, strong) TGToolbar *bottomPanelView;
@property (nonatomic, strong) TGButton *actionButton;
@property (nonatomic, strong) TGButton *deleteButton;
@property (nonatomic, strong) UILabel *counterLabel;

@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *progressAuthorLabel;
@property (nonatomic, strong) TGDateLabel *dateLabel;

@property (nonatomic) int totalCount;
@property (nonatomic) int loadedCount;
@property (nonatomic) int currentIndex;
@property (nonatomic) bool reversed;
@property (nonatomic, strong) TGUser *author;
@property (nonatomic) int date;

@property (nonatomic) bool enableEditing;

@property (nonatomic, strong) NSString *customTitle;

- (float)controlsAlpha;

- (void)setActive:(bool)active duration:(NSTimeInterval)duration;
- (void)setActive:(bool)active duration:(NSTimeInterval)duration statusBar:(bool)statusBar;
- (void)setCurrentIndex:(int)currentIndex totalCount:(int)totalCount loadedCount:(int)loadedCount author:(TGUser *)author date:(int)date;
- (void)setPlayerControlsVisible:(bool)visible paused:(bool)paused;
- (void)setTotalCount:(int)totalCount loadedCount:(int)loadedCount;
- (void)setCurrentIndex:(int)currentIndex author:(TGUser *)author date:(int)date;
- (void)toggleShowHide;
- (void)doneButtonPressed;

- (id)initWithFrame:(CGRect)frame enableEditing:(bool)enableEditing disableActions:(bool)disableActions;

@end
