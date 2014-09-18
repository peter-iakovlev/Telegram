/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "TGMediaItem.h"

#import "ActionStage.h"

#import "TGImageViewControllerCompanion.h"

#import "TGContentViewController.h"

@interface TGImageViewController : UIViewController <ASWatcher, TGContentViewController>

@property (nonatomic, strong) ASHandle *actionHandle;
@property (nonatomic, strong) ASHandle *watcherHandle;

@property (nonatomic, strong) id<TGImageViewControllerCompanion> imageViewCompanion;

@property (nonatomic, strong) NSMutableDictionary *tags;
@property (nonatomic, strong) id currentItemId;

@property (nonatomic) bool reverseOrder;

@property (nonatomic) bool keepAspect;
@property (nonatomic) bool hideDates;

@property (nonatomic) bool saveToGallery;
@property (nonatomic) int ignoreSaveToGalleryUid;
@property (nonatomic) int64_t groupIdForDownloadingItems;
@property (nonatomic) bool disableActions;

@property (nonatomic) UIStatusBarStyle currentStatusBarStyle;

@property (nonatomic) bool autoplay;

@property (nonatomic) bool isDisappearing;

- (id)initWithImageItem:(id<TGMediaItem>)imageItem placeholder:(UIImage *)placeholder;

- (void)animateAppear:(UIView *)containerForImage anchorForImage:(UIView *)anchorForImage fromRect:(CGRect)fromRect fromImage:(UIImage *)fromImage start:(dispatch_block_t)start;
- (void)animateAppear:(UIView *)containerForImage anchorForImage:(UIView *)anchorForImage transform:(CGAffineTransform)transform fromRect:(CGRect)fromRect fromImage:(UIImage *)fromImage start:(dispatch_block_t)start;
- (void)animateDisappear:(UIView *)containerForImage anchorForImage:(UIView *)anchor toRect:(CGRect)rectInWindowSpace toImage:(UIImage *)toImage swipeVelocity:(float)swipeVelocity completion:(dispatch_block_t)completion;
- (void)animateDisappear:(UIView *)containerForImage anchorForImage:(UIView *)anchor transform:(CGAffineTransform)transform toRect:(CGRect)rectInWindowSpace toImage:(UIImage *)toImage swipeVelocity:(float)swipeVelocity completion:(dispatch_block_t)completion;

- (void)setCustomTitle:(NSString *)customTitle;
- (void)positionInformationChanged:(int)position totalCount:(int)totalCount;
- (void)itemsChanged:(NSArray *)items totalCount:(int)totalCount canLoadMore:(bool)canLoadMore;
- (void)itemsChanged:(NSArray *)items totalCount:(int)totalCount tryToStayOnItemId:(bool)tryToStayOnItemId;
- (void)applyCurrentItem:(int)position;

- (void)acquireRotationLock;
- (void)releaseRotationLock;

@end
