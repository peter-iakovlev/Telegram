/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

@class TGImageViewController;

@protocol TGImageViewControllerCompanion <NSObject>

@property (nonatomic, weak) TGImageViewController *imageViewController;
@property (nonatomic) bool reverseOrder;

- (void)forceDismiss;

- (void)updateItems:(id)currentItemId;
- (void)loadMoreItems;
- (void)preloadCount;

- (void)deleteItem:(id)itemId;
- (void)forwardItem:(id)itemId;

- (bool)manualSavingEnabled;
- (bool)deletionEnabled;
- (bool)forwardingEnabled;
- (bool)editingEnabled;
- (bool)mediaSavingEnabled;

@optional

- (void)activateEditing;
- (bool)shouldDeleteItemFromList:(id)itemId;

@end
