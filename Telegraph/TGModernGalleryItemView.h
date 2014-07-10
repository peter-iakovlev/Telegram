/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "TGModernGalleryItem.h"

@class TGModernGalleryItemView;

@protocol TGModernGalleryItemViewDelegate <NSObject>

- (void)itemViewIsReadyForScheduledDismiss:(TGModernGalleryItemView *)itemView;

@end

@interface TGModernGalleryItemView : UIView

@property (nonatomic, weak) id<TGModernGalleryItemViewDelegate> delegate;

@property (nonatomic) NSUInteger index;
@property (nonatomic, strong) id<TGModernGalleryItem> item;

- (void)prepareForRecycle;
- (void)prepareForReuse;

- (bool)wantsHeader;
- (bool)wantsFooter;
- (UIView *)headerView;
- (UIView *)footerView;

- (bool)dismissControllerNowOrSchedule;

@end
