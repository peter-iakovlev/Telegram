/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCollectionMenuController.h"

@class TGTextSizeController;

@protocol TGTextSizeControllerDelegate <NSObject>

@optional

- (void)textSizeController:(TGTextSizeController *)textSizeController didFinishPickingWithTextSize:(int)textSize;

@end

@interface TGTextSizeController : TGCollectionMenuController

@property (nonatomic, weak) id<TGTextSizeControllerDelegate> delegate;

- (id)initWithTextSize:(int)textSize;

@end
