#import "TGInstantPageSlideshowView.h"

#import "TGImageUtils.h"

#import "TGInstantPageMedia.h"
#import "TGInstantPageImageView.h"

#import "TGModernGalleryTransitionView.h"
#import "TGPagerView.h"

@interface TGInstantPageSlideshowView () <UIScrollViewDelegate, TGModernGalleryTransitionView> {
    UIScrollView *_scrollView;
    NSMutableDictionary<NSNumber *, TGInstantPageImageView *> *_visibleItemViews;
    CGSize _currentSize;
    void (^_openMedia)(id);
    TGPagerView *_pagerView;
}

@end

@implementation TGInstantPageSlideshowView

- (instancetype)initWithFrame:(CGRect)frame medias:(NSArray<TGInstantPageMedia *> *)medias {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _medias = medias;
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = true;
        _scrollView.backgroundColor = [UIColor blackColor];
        _scrollView.showsHorizontalScrollIndicator = false;
        [self addSubview:_scrollView];
        _pagerView = [[TGPagerView alloc] initWithDotColors:@[[UIColor whiteColor]] normalDotColor:[UIColor colorWithWhite:1.0f alpha:0.5f] dotSpacing:16.0f dotSize:7.0f shadowWidth:TGScreenPixel];
        [self addSubview:_pagerView];
        _visibleItemViews = [[NSMutableDictionary alloc] init];
        [self updateLayout];
    }
    return self;
}

- (void)setIsVisible:(bool)__unused isVisible {
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    if (!CGSizeEqualToSize(_currentSize, size)) {
        [self updateLayout];
    }
}

- (void)updateLayout {
    CGSize size = self.bounds.size;
    _currentSize = size;
    _scrollView.frame = self.bounds;
    _scrollView.contentSize = CGSizeMake(_medias.count * size.width, size.height);
    [self updateVisibleItems];
    
    _pagerView.transform = CGAffineTransformIdentity;
    [_pagerView setPagesCount:(int)_medias.count];
    [_pagerView sizeToFit];
    
    CGFloat maxWidth = size.width - 40.0f;
    if (_pagerView.frame.size.width > maxWidth)
    {
        CGFloat scale = maxWidth / _pagerView.frame.size.width;
        _pagerView.transform = CGAffineTransformMakeScale(scale, scale);
    }
    
    _pagerView.center = CGPointMake(size.width / 2.0f, size.height - 19.0f + _pagerView.frame.size.height / 2.0f);
}

- (void)updateVisibleItems {
    NSMutableSet *visibleItemIndices = [[NSMutableSet alloc] init];
    
    CGRect visibleBounds = _scrollView.bounds;
    NSInteger index = -1;
    for (TGInstantPageMedia *media in _medias) {
        index++;
        CGRect itemFrame = CGRectMake(index * visibleBounds.size.width, 0.0f, visibleBounds.size.width, visibleBounds.size.height);
        CGRect adjustedItemFrame = itemFrame;
        adjustedItemFrame.origin.x -= visibleBounds.size.width / 2.0f;
        adjustedItemFrame.size.width += visibleBounds.size.width;
        if (CGRectIntersectsRect(visibleBounds, adjustedItemFrame)) {
            [visibleItemIndices addObject:@(index)];
            TGInstantPageImageView *itemView = _visibleItemViews[@(index)];
            if (itemView == nil) {
                TGInstantPageImageView *itemView = [[TGInstantPageImageView alloc] initWithFrame:itemFrame media:media arguments:[[TGInstantPageImageMediaArguments alloc] initWithInteractive:true roundCorners:false fit:false]];
                if ([itemView respondsToSelector:@selector(setOpenMedia:)]) {
                    __weak TGInstantPageSlideshowView *weakSelf = self;
                    [itemView setOpenMedia:^(id media) {
                        __strong TGInstantPageSlideshowView *strongSelf = weakSelf;
                        if (strongSelf != nil && strongSelf->_openMedia) {
                            strongSelf->_openMedia(media);
                        }
                    }];
                }
                [_scrollView addSubview:itemView];
                _visibleItemViews[@(index)] = itemView;
            } else if (!CGRectEqualToRect(itemView.frame, itemFrame)) {
                itemView.frame = itemFrame;
            }
        }
    }
    
    CGFloat scrollCenter = _scrollView.contentOffset.x + _scrollView.bounds.size.width / 2.0f;
    __block CGFloat closestScrollCenter = CGFLOAT_MAX;
    __block TGInstantPageImageView *closestItemView = nil;
    __block int closestIndex = 0;
    NSMutableArray *removeItemIndices = [[NSMutableArray alloc] init];
    [_visibleItemViews enumerateKeysAndObjectsUsingBlock:^(NSNumber *nIndex, TGInstantPageImageView *itemView, __unused BOOL *stop) {
        if (![visibleItemIndices containsObject:nIndex]) {
            [itemView removeFromSuperview];
            [removeItemIndices addObject:nIndex];
        }
        if (ABS(itemView.center.x - scrollCenter) < closestScrollCenter || closestItemView == nil) {
            closestScrollCenter = ABS(itemView.center.x - scrollCenter);
            closestItemView = itemView;
            closestIndex = [nIndex intValue];
        }
    }];
    [_pagerView setPage:closestIndex];
    [_visibleItemViews removeObjectsForKeys:removeItemIndices];
}

- (void)scrollViewDidScroll:(UIScrollView *)__unused scrollView {
    [self updateVisibleItems];
}

- (void)setOpenMedia:(void (^)(id))openMedia {
    _openMedia = [openMedia copy];
}

- (UIView *)transitionViewForMedia:(TGInstantPageMedia *)media {
    __block UIView *resultView = nil;
    [_visibleItemViews enumerateKeysAndObjectsUsingBlock:^(__unused NSNumber *key, TGInstantPageImageView *itemView, BOOL *stop) {
        UIView *result = [itemView transitionViewForMedia:media];
        if (result != nil) {
            resultView = self;
            *stop = true;
        }
    }];
    return resultView;
}

- (void)updateHiddenMedia:(TGInstantPageMedia *)media {
    [_visibleItemViews enumerateKeysAndObjectsUsingBlock:^(__unused NSNumber *key, TGInstantPageImageView *itemView, __unused BOOL *stop) {
        [itemView updateHiddenMedia:media];
    }];
}

- (UIImage *)transitionImage {
    CGFloat scrollCenter = _scrollView.contentOffset.x + _scrollView.bounds.size.width / 2.0f;
    __block CGFloat closestScrollCenter = CGFLOAT_MAX;
    __block TGInstantPageImageView *closestItemView = nil;
    [_visibleItemViews enumerateKeysAndObjectsUsingBlock:^(__unused NSNumber *key, TGInstantPageImageView *itemView, __unused BOOL *stop) {
        if (ABS(itemView.center.x - scrollCenter) < closestScrollCenter || closestItemView == nil) {
            closestScrollCenter = ABS(itemView.center.x - scrollCenter);
            closestItemView = itemView;
        }
    }];
    if (closestItemView != nil && [closestItemView conformsToProtocol:@protocol(TGModernGalleryTransitionView)]) {
        return [(id<TGModernGalleryTransitionView>)closestItemView transitionImage];
    } else {
        return nil;
    }
}

@end
