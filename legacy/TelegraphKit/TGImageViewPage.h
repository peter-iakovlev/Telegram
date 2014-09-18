/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "TGMediaItem.h"

#import "TGRemoteImageView.h"

#import "ActionStage.h"

#import "TGImageScrollView.h"

@protocol TGImageViewPageDelegate <NSObject>

- (void)pageWillBeginDragging:(UIScrollView *)scrollView;
- (void)pageDidScroll:(UIScrollView *)scrollView;
- (void)pageDidEndDragging:(UIScrollView *)scrollView;

@end

@protocol TGMediaPlayerRecycler <NSObject>

- (void)recycleMediaPlayer:(id)mediaPlayer;

@end

@interface TGImageViewPage : UIView <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;
@property (nonatomic, strong) ASHandle *interfaceHandle;
@property (nonatomic, strong) ASHandle *watcherHandle;

@property (nonatomic, strong) id<TGMediaItem> imageItem;
@property (nonatomic) id<NSCopying> itemId;
@property (nonatomic) int pageIndex;

@property (nonatomic) bool saveToGallery;
@property (nonatomic) int ignoreSaveToGalleryUid;
@property (nonatomic) int64_t groupIdForDownloadingItems;

@property (nonatomic, strong) TGCache *customCache;

@property (nonatomic, weak) id<TGImageViewPageDelegate> delegate;

@property (nonatomic) float bottomAnimationPadding;

@property (nonatomic) float statusBarHeight;
@property (nonatomic) CGSize referenceScreenSize;

- (id)initWithFrame:(CGRect)frame;

- (void)loadItem:(id<TGMediaItem>)mediaItem placeholder:(UIImage *)placeholder willAnimateAppear:(bool)willAnimateAppear;
- (void)createScrollView;
- (void)resetScrollView;

- (void)pauseMedia;
- (void)resetMedia;
- (void)prepareToPlay;
- (void)playMedia;

- (bool)isScrubbing;
- (bool)isPlaying;
- (bool)isZoomed;
- (void)offsetContent:(CGPoint)offset;

- (void)controlsAlphaUpdated:(float)alpha;
- (void)updateControlsOffset:(float)offsetY;

- (UIImage *)currentImage;
- (CGRect)currentImageFrameInView:(UIView *)view;
- (NSString *)currentImageUrl;
- (NSString *)currentVideoUrl;

- (void)willAnimateRotation;
- (void)didAnimateRotation;

- (void)animateAppearFromImage:(UIImage *)image fromView:(UIView *)fromView aboveView:(UIView *)aboveView fromRect:(CGRect)fromRect toInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation completion:(dispatch_block_t)completion keepAspect:(bool)keepAspect;
- (void)animateAppearFromImage:(UIImage *)image fromView:(UIView *)fromView aboveView:(UIView *)aboveView transform:(CGAffineTransform)transform fromRect:(CGRect)fromRect toInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation completion:(dispatch_block_t)completion keepAspect:(bool)keepAspect;
- (void)animateAppearFromImage:(UIImage *)image fromView:(UIView *)fromView aboveView:(UIView *)aboveView transform:(CGAffineTransform)transform fromRect:(CGRect)fromRect toInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation completion:(dispatch_block_t)completion keepAspect:(bool)keepAspect duration:(NSTimeInterval)duration;

- (void)animateDisappearToImage:(UIImage *)toImage toView:(UIView *)toView aboveView:(UIView *)aboveView toRect:(CGRect)toRect toContainerImage:(UIImage *)toContainerImage toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation keepAspect:(bool)keepAspect backgroundAlpha:(float)backgroundAlpha swipeVelocity:(float)swipeVelocity completion:(dispatch_block_t)completion;
- (void)animateDisappearToImage:(UIImage *)toImage toView:(UIView *)toView aboveView:(UIView *)aboveView transform:(CGAffineTransform)transform toRect:(CGRect)toRect toContainerImage:(UIImage *)toContainerImage toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation keepAspect:(bool)keepAspect backgroundAlpha:(float)backgroundAlpha swipeVelocity:(float)swipeVelocity completion:(dispatch_block_t)completion;
- (void)animateDisappearToImage:(UIImage *)__unused toImage toView:(UIView *)toView aboveView:(UIView *)aboveView transform:(CGAffineTransform)transform toRect:(CGRect)toRect toContainerImage:(UIImage *)toContainerImage toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation keepAspect:(bool)keepAspect backgroundAlpha:(float)backgroundAlpha swipeVelocity:(float)swipeVelocity completion:(dispatch_block_t)completion duration:(NSTimeInterval)duration;

@end
