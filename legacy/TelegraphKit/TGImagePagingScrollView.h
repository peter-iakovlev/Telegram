/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "TGImageViewPage.h"

#import "ActionStage.h"

@class TGImageViewPage;

@protocol TGImagePagingScrollViewDelegate <NSObject>

- (void)scrollViewCurrentPageChanged:(int)currentPage imageItem:(id<TGMediaItem>)imageItem;
- (void)pageWillBeginDragging:(UIScrollView *)scrollView;
- (void)pageDidScroll:(UIScrollView *)scrollView;
- (void)pageDidEndDragging:(UIScrollView *)scrollView;
- (id)actionsSender;

- (float)controlsAlpha;

@end

@interface TGImagePagingScrollView : UIScrollView <TGImageViewPageDelegate, TGMediaPlayerRecycler>

@property (nonatomic) float pageGap;

@property (nonatomic) bool reverseOrder;

@property (nonatomic, strong) TGCache *customCache;

@property (nonatomic) bool saveToGallery;
@property (nonatomic) int ignoreSaveToGalleryUid;
@property (nonatomic) int64_t groupIdForDownloadingItems;

@property (nonatomic, strong) ASHandle *actionHandle;
@property (nonatomic, strong) ASHandle *interfaceHandle;

@property (nonatomic, strong) NSMutableArray *visiblePages;
@property (nonatomic, strong) NSMutableArray *pageViewQueue;

@property (nonatomic, strong) NSArray *pageList;

@property (nonatomic) CGSize validSize;

@property (nonatomic) bool canLoadMore;
@property (nonatomic) bool loadingMore;

@property (nonatomic) int currentPageIndex;
@property (nonatomic) int lastPageIndex;

@property (nonatomic, weak) id<TGImagePagingScrollViewDelegate> pagingDelegate;

- (void)setCurrentPageIndex:(int)currentPageIndex;
- (void)setCurrentPageIndex:(int)currentPageIndex force:(bool)force;
- (void)setPageList:(NSArray *)pageList;
- (void)setInitialPageState:(TGImageViewPage *)page;
- (void)resetOffsetForIndex:(int)index;
- (void)itemsChanged:(NSArray *)items canLoadMore:(bool)canLoadMore;
- (TGImageViewPage *)pageForIndex:(int)index;

- (void)willAnimateRotation;
- (void)didAnimateRotation;

- (void)recyclePlayers;

- (void)updateControlsAlpha:(float)alpha;

@end