#import "TGGenericPeerMediaGalleryGroupSliderView.h"

#import "TGAppDelegate.h"

#import <LegacyComponents/TGImageView.h>
#import <LegacyComponents/TGImageUtils.h>

#import <LegacyComponents/TGImageMediaAttachment.h>
#import <LegacyComponents/TGVideoMediaAttachment.h>

#import "TGGenericPeerGalleryGroupItem.h"

#import "TGSharedPhotoSignals.h"
#import "TGSharedMediaUtils.h"

const CGSize TGGroupSliderItemSize = { 23.0f, 42.0f };
const CGFloat TGGroupSliderSmallMargin = 1.0f;
const CGFloat TGGroupSliderLargeMargin = 9.0f;
const CGFloat TGGroupSliderMaxWidth = 75.0f;

@interface TGGenericPeerMediaGalleryGroupSliderView () <UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    int64_t _groupedId;
    NSArray<TGGenericPeerGalleryGroupItem *> *_items;
    
    UIScrollView *_scrollView;
    bool _panning;
    CGFloat _transitionProgress;
    
    NSInteger _currentItemIndex;
}
@end

@implementation TGGenericPeerMediaGalleryGroupSliderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _currentItemIndex = NSNotFound;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = false;
        _scrollView.showsHorizontalScrollIndicator = false;
        [self addSubview:_scrollView];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [_scrollView addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:_scrollView];
    for (UIView *view in _scrollView.subviews)
    {
        if (CGRectContainsPoint(view.frame, location))
        {
            [self setCurrentItemIndex:view.tag animated:true];
            if (self.itemChanged != nil)
                self.itemChanged(_items[_currentItemIndex], true);
            break;
        }
    }
}

- (void)layoutScrollView
{
    if (fabs(_scrollView.frame.size.width - self.bounds.size.width) > FLT_EPSILON || _scrollView.frame.size.height < FLT_EPSILON)
    {
        _scrollView.frame = self.bounds;
        _scrollView.contentInset = UIEdgeInsetsMake(0.0f, _scrollView.frame.size.width / 2.0f, 0.0f, 0.0f);
        
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width - _scrollView.contentInset.left + (TGGroupSliderItemSize.width + TGGroupSliderSmallMargin) * (_items.count - 1), TGGroupSliderItemSize.height);
        
        CGPoint center = CGPointMake(_currentItemIndex * (TGGroupSliderItemSize.width + TGGroupSliderSmallMargin), self.frame.size.height / 2.0f);
        _scrollView.contentOffset = CGPointMake(-_scrollView.contentInset.left + center.x, 0.0f);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.isDragging)
    {
        if (!_panning)
        {
            _panning = true;
            [UIView animateWithDuration:0.2 delay:0.0 options:7 << 16 animations:^
            {
                [self layoutSubviews];
            } completion:nil];
        }
    }
    
    CGFloat pos = scrollView.contentOffset.x + scrollView.contentInset.left;
    NSInteger index = (NSInteger)round(pos / (CGFloat)(TGGroupSliderItemSize.width + TGGroupSliderSmallMargin));
    index = MAX(0, MIN((NSInteger)_items.count - 1, index));
    
    if (index != _currentItemIndex)
    {
        if (_scrollView.isDragging || _scrollView.isDecelerating)
        {
            _currentItemIndex = index;
            
            if (self.itemChanged != nil)
                self.itemChanged(_items[_currentItemIndex], false);
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)__unused scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
        _panning = false;
    
    CGPoint center = CGPointMake(_currentItemIndex * (TGGroupSliderItemSize.width + TGGroupSliderSmallMargin), self.frame.size.height / 2.0f);
    [UIView animateWithDuration:0.2 delay:0.0 options:7 << 16 animations:^
    {
        [self layoutSubviews];
        
        if (!decelerate)
            _scrollView.contentOffset = CGPointMake(-_scrollView.contentInset.left + center.x, 0.0f);
    } completion:nil];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.isTracking)
        return;
    
    CGPoint center = CGPointMake(_currentItemIndex * (TGGroupSliderItemSize.width + TGGroupSliderSmallMargin), self.frame.size.height / 2.0f);
    [UIView animateWithDuration:0.2 delay:0.0 options:7 << 16 animations:^
    {
        if (_panning)
        {
            _panning = false;
            [self layoutSubviews];
        }
        _scrollView.contentOffset = CGPointMake(-_scrollView.contentInset.left + center.x, 0.0f);
    } completion:nil];
}

- (void)setGroupedId:(int64_t)groupedId items:(NSArray *)items
{
    if (_groupedId == groupedId && _items.count == items.count)
        return;
    
    _currentItemIndex = NSNotFound;
    _groupedId = groupedId;
    _items = items;
    
    if (_groupedId == 0)
        return;
    
    [self setupWithItems:items];
}

- (void)setupWithItems:(NSArray *)items
{
    for (UIView *view in _scrollView.subviews)
        [view removeFromSuperview];
    
    [items enumerateObjectsUsingBlock:^(TGGenericPeerGalleryGroupItem *item, NSUInteger index, __unused BOOL *stop)
    {
        TGImageView *itemView = [[TGImageView alloc] initWithFrame:CGRectMake(index * (TGGroupSliderItemSize.width + TGGroupSliderSmallMargin), 0.0f, TGGroupSliderItemSize.width, TGGroupSliderItemSize.height)];
        itemView.clipsToBounds = true;
        itemView.contentMode = UIViewContentModeScaleAspectFill;
        itemView.backgroundColor = UIColorRGB(0x0d0d0d);
        itemView.layer.cornerRadius = 3.0f;
        itemView.tag = index;
        if (item.isVideo)
        {
            TGVideoMediaAttachment *videoMediaAttachment = (TGVideoMediaAttachment *)item.media;
            
            NSString *legacyVideoFilePath = [self filePathForVideoId:videoMediaAttachment.videoId != 0 ? videoMediaAttachment.videoId : videoMediaAttachment.localVideoId local:videoMediaAttachment.videoId == 0];
            NSString *legacyThumbnailCacheUri = [videoMediaAttachment.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
    
            NSMutableString *previewUri = nil;
            if (videoMediaAttachment.videoId != 0 || videoMediaAttachment.localVideoId != 0)
            {
                previewUri = [[NSMutableString alloc] initWithString:@"media-gallery-video-preview://?"];
                if (videoMediaAttachment.videoId != 0)
                    [previewUri appendFormat:@"id=%" PRId64 "", videoMediaAttachment.videoId];
                else
                    [previewUri appendFormat:@"local-id=%" PRId64 "", videoMediaAttachment.localVideoId];
                
                CGSize size = TGScaleToFill(videoMediaAttachment.dimensions, CGSizeMake(TGGroupSliderItemSize.height, TGGroupSliderItemSize.height));
                [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)size.width, (int)size.height, (int)size.width, (int)size.height];
                
                [previewUri appendFormat:@"&legacy-video-file-path=%@", legacyVideoFilePath];
                if (legacyThumbnailCacheUri != nil)
                    [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUri];
                
                [previewUri appendFormat:@"&messageId=%" PRId32 "", (int32_t)item.keyId];
                [previewUri appendFormat:@"&conversationId=%" PRId64 "", (int64_t)item.peerId];
            }
            
            [itemView loadUri:previewUri withOptions:nil];
        }
        else
        {
            [itemView setSignal:[self signalForImageItem:item]];
        }
        [_scrollView addSubview:itemView];
    }];
    
    [self layoutSubviews];
}

- (SSignal *)signalForImageItem:(TGGenericPeerGalleryGroupItem *)item
{
    CGSize size = [self constrainedSize:item.imageSize];
    return [TGSharedPhotoSignals squarePhotoThumbnail:(TGImageMediaAttachment *)item.media ofSize:size threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:nil downloadLargeImage:false inhibitBlur:true placeholder:nil];
}

- (NSString *)filePathForVideoId:(int64_t)videoId local:(bool)local
{
    static NSString *videosDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSString *documentsDirectory = [TGAppDelegate documentsPath];
        videosDirectory = [documentsDirectory stringByAppendingPathComponent:@"video"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:videosDirectory])
            [[NSFileManager defaultManager] createDirectoryAtPath:videosDirectory withIntermediateDirectories:true attributes:nil error:nil];
    });
    
    return [videosDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@%" PRIx64 ".mov", local ? @"local" : @"remote", videoId]];
}

- (void)setCurrentItemIndex:(NSUInteger)index animated:(bool)animated
{
    _currentItemIndex = index;
    
    CGPoint center = CGPointMake(_currentItemIndex * (TGGroupSliderItemSize.width + TGGroupSliderSmallMargin), self.frame.size.height / 2.0f);
    if (animated)
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:7 << 16 animations:^
        {
            [self layoutSubviews];
            _scrollView.contentOffset = CGPointMake(-_scrollView.contentInset.left + center.x, 0.0f);
        } completion:nil];
    }
    else
    {
        [self layoutSubviews];
        _scrollView.contentOffset = CGPointMake(-_scrollView.contentInset.left + center.x, 0.0f);
    }
}

- (void)setCurrentItemKey:(int64_t)key animated:(bool)animated
{
    if (_items.count == 0)
        return;
    
    __block NSInteger newCurrentItemIndex = 0;
    [_items enumerateObjectsUsingBlock:^(TGGenericPeerGalleryGroupItem *groupItem, NSUInteger index, __unused BOOL *stop)
    {
        if (groupItem.keyId == key)
        {
            newCurrentItemIndex = index;
            *stop = true;
        }
    }];
    
    if (newCurrentItemIndex == _currentItemIndex)
        return;
    
    [self setCurrentItemIndex:newCurrentItemIndex animated:animated];
}

- (void)setTransitionProgress:(CGFloat)progress
{
    progress = MIN(0.5f, MAX(-0.5f, progress));
    if (_currentItemIndex == 0)
        progress = MAX(0.0f, progress);
    else if (_currentItemIndex == (NSInteger)_items.count - 1)
        progress = MIN(0.0f, progress);
    _transitionProgress = progress;
    
    if (_items.count == 0)
        return;
    
    if (fabs(progress) > FLT_EPSILON)
    {
        CGPoint center = CGPointMake((_currentItemIndex + progress) * (TGGroupSliderItemSize.width + TGGroupSliderSmallMargin), self.frame.size.height / 2.0f);
        _scrollView.contentOffset = CGPointMake(-_scrollView.contentInset.left + center.x, 0.0f);
    }
    
    [self setNeedsLayout];
}

- (CGSize)constrainedSize:(CGSize)size
{
    CGSize constrainedSize = TGScaleToFill(size, TGGroupSliderItemSize);
    if (constrainedSize.height > TGGroupSliderItemSize.height)
        constrainedSize = TGGroupSliderItemSize;
    constrainedSize.width = MIN(constrainedSize.width , TGGroupSliderMaxWidth);
    return constrainedSize;
}

- (void)layoutSubviews
{
    if (_currentItemIndex == NSNotFound)
        return;
    
    [self layoutScrollView];
    
    CGFloat transitionProgress = _transitionProgress;
    if (_currentItemIndex == 0)
        transitionProgress = MAX(0.0f, transitionProgress);
    else if (_currentItemIndex == (NSInteger)_items.count - 1)
        transitionProgress = MIN(0.0f, transitionProgress);
    CGFloat progress = fabs(transitionProgress);
    
    CGSize imageSize = _items[_currentItemIndex].imageSize;
    CGSize expandedSize = [self constrainedSize:imageSize];
    
    CGSize selectedSize = _panning ? TGGroupSliderItemSize : expandedSize;
    if (selectedSize.width < TGGroupSliderItemSize.width)
        selectedSize = TGGroupSliderItemSize;
    
    CGFloat selectedMargin = _panning ? TGGroupSliderSmallMargin : TGGroupSliderLargeMargin;
    for (TGImageView *view in _scrollView.subviews)
    {
        if (![view isKindOfClass:[TGImageView class]])
            continue;
        
        CGPoint center = CGPointMake(view.tag * (TGGroupSliderItemSize.width + TGGroupSliderSmallMargin), self.frame.size.height / 2.0f);
        if (!_panning && progress > FLT_EPSILON)
        {
            CGSize size = TGGroupSliderItemSize;
            CGFloat currentOffset = (selectedSize.width / 2.0f + selectedMargin) - (TGGroupSliderItemSize.width / 2.0f + TGGroupSliderSmallMargin);
            if (transitionProgress > FLT_EPSILON)
            {
                CGSize nextSize = [self constrainedSize:_items[_currentItemIndex + 1].imageSize];
                CGFloat nextOffset = (nextSize.width / 2.0f + selectedMargin) - (TGGroupSliderItemSize.width / 2.0f + TGGroupSliderSmallMargin);
                
                if (view.tag < _currentItemIndex)
                {
                    center.x -= (currentOffset * (1.0f - progress) + nextOffset * progress);
                }
                else if (view.tag == _currentItemIndex + 1)
                {
                    center.x += currentOffset * (1.0f - progress);
                    size = CGSizeMake(TGGroupSliderItemSize.width + (nextSize.width - TGGroupSliderItemSize.width) * progress, selectedSize.height);
                }
                else if (view.tag > _currentItemIndex)
                {
                    center.x += (currentOffset * (1.0f - progress) + nextOffset * progress);
                }
                else
                {
                    center.x -= nextOffset * progress;
                    size = CGSizeMake(selectedSize.width - (selectedSize.width - TGGroupSliderItemSize.width) * progress, selectedSize.height);
                }
            }
            else
            {
                CGSize previousSize = [self constrainedSize:_items[_currentItemIndex - 1].imageSize];
                CGFloat previousOffset = (previousSize.width / 2.0f + selectedMargin) - (TGGroupSliderItemSize.width / 2.0f + TGGroupSliderSmallMargin);
                
                if (view.tag == _currentItemIndex - 1)
                {
                    center.x -= currentOffset * (1.0f - progress);
                    size = CGSizeMake(TGGroupSliderItemSize.width + (previousSize.width - TGGroupSliderItemSize.width) * progress, selectedSize.height);
                }
                else if (view.tag < _currentItemIndex)
                {
                    center.x -= (currentOffset * (1.0f - progress) + previousOffset * progress);
                }
                else if (view.tag > _currentItemIndex)
                {
                    center.x += (currentOffset * (1.0f - progress) + previousOffset * progress);
                }
                else
                {
                    center.x += previousOffset * progress;
                    size = CGSizeMake(selectedSize.width - (selectedSize.width - TGGroupSliderItemSize.width) * progress, selectedSize.height);
                }
            }
            
            view.frame = CGRectMake(center.x - size.width / 2.0f, 0.0f, size.width, size.height);
        }
        else
        {
            CGFloat offset = (selectedSize.width / 2.0f + selectedMargin) - (TGGroupSliderItemSize.width / 2.0f + TGGroupSliderSmallMargin);
            if (view.tag < _currentItemIndex)
                center.x -= offset;
            else if (view.tag > _currentItemIndex)
                center.x += offset;
            
            CGSize size = view.tag == _currentItemIndex ? selectedSize : TGGroupSliderItemSize;
            view.frame = CGRectMake(center.x - size.width / 2.0f, 0.0f, size.width, size.height);
        }
    }
}

@end
