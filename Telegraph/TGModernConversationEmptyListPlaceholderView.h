/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@class TGModernConversationEmptyListPlaceholderView;

@protocol TGModernConversationEmptyListPlaceholderViewDelegate <NSObject>

- (CGSize)messageAreaSizeForInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end

@interface TGModernConversationEmptyListPlaceholderView : UIView

@property (nonatomic, weak) id<TGModernConversationEmptyListPlaceholderViewDelegate> delegate;

- (void)adjustLayoutForOrientation:(UIInterfaceOrientation)orientation contentInsets:(UIEdgeInsets)contentInsets duration:(NSTimeInterval)duration curve:(int)curve;

@end
