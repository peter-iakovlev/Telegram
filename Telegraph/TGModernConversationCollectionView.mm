#import "TGModernConversationCollectionView.h"

#import "Freedom.h"

#import "TGImageUtils.h"

#import "TGHacks.h"

#import "TGModernCollectionCell.h"
#import "TGModernConversationViewLayout.h"
#import "TGMessageModernConversationItem.h"

#import "TGModernViewStorage.h"
#import "TGModernDateHeaderView.h"
#import "TGModernUnreadHeaderView.h"

#import "TGAudioSliderButton.h"

#import "TGDoubleTapGestureRecognizer.h"
#import "TGModernConversationCollectionTouchBehaviour.h"
#import "TGModernConversationCollectionViewInstantPreviewRecognizer.h"

#import <objc/message.h>

#import <map>
#import <set>
#import <algorithm>

static void TGModernConversationCollectionViewUpdate0(id self, SEL _cmd, BOOL needsUpdate, BOOL withLayoutAttributes);

@interface TGModernConversationCollectionView () <UIGestureRecognizerDelegate, TGModernConversationCollectionViewInstantPreviewRecognizerDelegate>
{
    CGFloat _indicatorInset;
    
    bool _delayVisibleItemsUpdate;
    CGFloat _lastRelativeBoundsReport;
    
    bool _disableDecorationViewUpdates;
    std::map<NSInteger, UIView<TGModernView> *> _currentVisibleDecorationViews;
    
    TGModernViewStorage *_viewStorage;
    __weak id<TGModernConversationCollectionTouchBehaviour> _currentInstantPreviewTarget;
    
    NSTimeInterval _ignoreBackgroundTouchBeforeDate;
}

@property (nonatomic, copy) void (^touchCompletion)();

@end

@implementation TGModernConversationCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self != nil)
    {
        _indicatorInset = iosMajorVersion() >= 7 ? (TGIsRetina() ? 7.5f : 8.0f) : 9.0f;
        
        _lastRelativeBoundsReport = FLT_MAX;
        _viewStorage = [[TGModernViewStorage alloc] init];
        
        UIEdgeInsets contentInset = self.contentInset;
        self.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, contentInset.bottom, frame.size.width - _indicatorInset);
        
        TGModernConversationCollectionViewInstantPreviewRecognizer *previewRecognizer = [[TGModernConversationCollectionViewInstantPreviewRecognizer alloc] initWithTarget:self action:@selector(instantPreviewGesture:)];
        previewRecognizer.delegate = self;
        [self addGestureRecognizer:previewRecognizer];
        
        self.exclusiveTouch = true;
    }
    return self;
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        freedomInit();
        if (iosMajorVersion() < 7 || iosMajorVersion() >= 8)
        {
            FreedomDecoration instanceDecorations[] = {
                { .name = 0xfe9aa61dU,
                  .imp = (IMP)&TGModernConversationCollectionViewUpdate0,
                  .newIdentifier = FreedomIdentifierEmpty,
                  .newEncoding = FreedomIdentifierEmpty
                }
            };
            
            freedomClassAutoDecorate(0xdbbc992fU, NULL, 0, instanceDecorations, sizeof(instanceDecorations) / sizeof(instanceDecorations[0]));
        }
    });
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    if ([view isKindOfClass:[TGAudioSliderButton class]])
        return false;
    
    for (id gestureRecognizer in view.gestureRecognizers)
    {
        if ([gestureRecognizer isKindOfClass:[TGDoubleTapGestureRecognizer class]])
        {
            if (![(TGDoubleTapGestureRecognizer *)gestureRecognizer canScrollViewStealTouches])
                return false;
        }
    }
    
    return true;
}

- (void)instantPreviewGesture:(TGModernConversationCollectionViewInstantPreviewRecognizer *)__unused recognizer
{
}

- (void)instantPreviewGestureDidBegin
{
    id<TGModernConversationCollectionTouchBehaviour> touchBehaviour = _currentInstantPreviewTarget;
    if (touchBehaviour != nil)
    {
        //TGLog(@"begin with %p", touchBehaviour);
        
        void (^touchCompletion)() = [touchBehaviour forwardTouchToCollectionWithCompletion];
        if (touchCompletion != nil)
        {
            __weak TGModernConversationCollectionView *weakSelf = self;
            self.touchCompletion = ^
            {
                __strong TGModernConversationCollectionView *strongSelf = weakSelf;
                
                touchCompletion();
                
                strongSelf.touchCompletion = nil;
            };
        }
    }
}

- (void)instantPreviewGestureDidEnd
{
    [self endInstantPreviewGesture];
}

- (void)instantPreviewGestureDidMove
{
    if (self.touchCompletion != nil)
    {
        id<TGModernConversationCollectionTouchBehaviour> currentInstantPreviewTarget = _currentInstantPreviewTarget;
        if (currentInstantPreviewTarget == nil || [currentInstantPreviewTarget scrollingShouldCancelInstantPreview])
            [self endInstantPreviewGesture];
        else
            self.scrollEnabled = false;
    }
}

- (void)endInstantPreviewGesture
{
    //TGLog(@"end with %p", _currentInstantPreviewTarget);
    
    if (self.touchCompletion != nil)
    {
        self.touchCompletion();
        self.touchCompletion = nil;
        self.scrollEnabled = true;
        
        _ignoreBackgroundTouchBeforeDate = CACurrentMediaTime() + 0.1;
    }
    
    _currentInstantPreviewTarget = nil;
}

- (id<TGModernConversationCollectionTouchBehaviour>)touchBehaviourForViewOrSuperviews:(UIView *)view
{
    if (view == nil)
        return nil;
    
    if ([view conformsToProtocol:@protocol(TGModernConversationCollectionTouchBehaviour)])
        return (id<TGModernConversationCollectionTouchBehaviour>)view;
    
    return [self touchBehaviourForViewOrSuperviews:view.superview];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *result = [super hitTest:point withEvent:event];
    
    id<TGModernConversationCollectionTouchBehaviour> touchBehaviour = [self touchBehaviourForViewOrSuperviews:result];
    if (touchBehaviour != nil)
    {
        id<TGModernConversationCollectionTouchBehaviour> currentTouchBehaviour = _currentInstantPreviewTarget;
        if (currentTouchBehaviour != touchBehaviour)
        {
            [self endInstantPreviewGesture];
        }
        
        _currentInstantPreviewTarget = touchBehaviour;
        
        return self;
    }
    
    return result;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    UIEdgeInsets contentInset = self.contentInset;
    self.scrollIndicatorInsets = UIEdgeInsetsMake(contentInset.top, 0, contentInset.bottom, frame.size.width - _indicatorInset);
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    [super setContentInset:contentInset];
    
    self.scrollIndicatorInsets = UIEdgeInsetsMake(contentInset.top, 0, contentInset.bottom, self.frame.size.width - _indicatorInset);
    
    [self updateVisibleDecorationViews];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (CACurrentMediaTime() < _ignoreBackgroundTouchBeforeDate) {
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(touchedTableBackground)]) {
        [self.delegate performSelector:@selector(touchedTableBackground)];
    }
#pragma clang diagnostic pop
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(tableTouchesCancelled)])
        [self.delegate performSelector:@selector(tableTouchesCancelled)];
#pragma clang diagnostic pop
}

- (void)setDelayVisibleItemsUpdate:(bool)delay
{
    _delayVisibleItemsUpdate = delay;
}

static void TGModernConversationCollectionViewUpdate0(id self, SEL _cmd, BOOL needsUpdate, BOOL withLayoutAttributes)
{
    static void (*nativeImpl)(id, SEL, BOOL, BOOL) = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        nativeImpl = (void (*)(id, SEL, BOOL, BOOL))freedomNativeImpl(object_getClass(self), _cmd);
    });
    
    if (!((TGModernConversationCollectionView *)self)->_delayVisibleItemsUpdate && nativeImpl != NULL)
        nativeImpl(((TGModernConversationCollectionView *)self), _cmd, needsUpdate, withLayoutAttributes);
}

- (void)updateVisibleItemsNow
{
    CGRect bounds = self.bounds;
    [self setBounds:CGRectOffset(bounds, 0.0f, 0.1f)];
    [self setBounds:bounds];
    [self layoutSubviews];
}

- (void)setBounds:(CGRect)bounds
{
    if (!CGSizeEqualToSize(bounds.size, self.bounds.size))
        _lastRelativeBoundsReport = FLT_MAX;
    
    [super setBounds:bounds];
}

- (void)reloadData
{
    _lastRelativeBoundsReport = FLT_MAX;
    
    [super reloadData];
    [self updateVisibleItemsNow];
    [self layoutSubviews];
}

- (void)scrollToTopIfNeeded
{
    if (self.contentSize.height > self.frame.size.height - self.contentInset.top - self.contentInset.bottom)
    {
        [self setContentOffset:CGPointMake(0.0f, MIN(self.contentOffset.y + self.bounds.size.height * 3.0f, self.contentSize.height + self.contentInset.bottom - self.bounds.size.height)) animated:true];
    }
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    [super setContentOffset:contentOffset animated:animated];
}

- (void)setDisableDecorationViewUpdates:(bool)disableDecorationViewUpdates
{
    _disableDecorationViewUpdates = disableDecorationViewUpdates;
}

- (bool)disableDecorationViewUpdates
{
    return _disableDecorationViewUpdates;
}

- (UIView *)viewForDecorationAtIndex:(int)index
{
    auto it = _currentVisibleDecorationViews.find(index);
    if (it != _currentVisibleDecorationViews.end())
        return it->second;
    return nil;
}

- (NSArray *)visibleDecorations
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:_currentVisibleDecorationViews.size()];
    for (auto it : _currentVisibleDecorationViews)
    {
        [array addObject:it.second];
    }
    return array;
}

- (void)updateDecorationAssets
{
    for (auto it : _currentVisibleDecorationViews)
    {
        [((TGModernDateHeaderView *)it.second) updateAssets];
    }
    
    [_viewStorage clear];
}

- (CGFloat)implicitTopInset
{
    return _headerView.frame.size.height;
}

- (CGRect)headerViewFrame
{
    CGRect frame = _headerView.frame;
    frame.origin.x = CGFloor((self.frame.size.width - frame.size.width) / 2.0f);
    frame.origin.y = ((TGModernConversationViewLayout *)self.collectionViewLayout).collectionViewContentSize.height;
    frame.origin.y = MAX(frame.origin.y,  CGFloor((self.frame.size.height - self.contentInset.top - self.contentInset.bottom) / 2.0f));
    return frame;
}

- (void)updateVisibleDecorationViews
{
    if (_disableDecorationViewUpdates || _delayVisibleItemsUpdate)
        return;
    
    std::set<NSInteger> currentIndices;
    
    std::vector<TGDecorationViewAttrubutes> *pAttributes = [(TGModernConversationViewLayout *)self.collectionViewLayout allDecorationViewAttributes];
    if (pAttributes == NULL)
        return;
    
    CGRect bounds = self.bounds;
    
    TGDecorationViewAttrubutes lowerAttributes = {.index = 0, .frame = CGRectMake(0, bounds.origin.y - 30.0f, 0.0f, 0.0f)};
    TGDecorationViewAttrubutes upperAttributes = {.index = 0, .frame = CGRectMake(0, bounds.origin.y + bounds.size.height, 0.0f, 0.0f)};
    
    auto lowerIt = std::lower_bound(pAttributes->begin(), pAttributes->end(), lowerAttributes, TGDecorationViewAttrubutesComparator());
    auto upperIt = std::upper_bound(pAttributes->begin(), pAttributes->end(), upperAttributes, TGDecorationViewAttrubutesComparator());
    
    if (lowerIt != pAttributes->end())
    {
        for (auto it = lowerIt; it != upperIt; it++)
        {
            currentIndices.insert(it->index);
            
            auto viewIt = _currentVisibleDecorationViews.find(it->index);
            if (viewIt == _currentVisibleDecorationViews.end())
            {
                [UIView performWithoutAnimation:^
                {
                    if (it->index != INT_MIN)
                    {
                        TGModernDateHeaderView *view = (TGModernDateHeaderView *)[_viewStorage dequeueViewWithIdentifier:@"_date" viewStateIdentifier:[[NSString alloc] initWithFormat:@"date/%d", it->index]];
                        if (view == nil)
                            view = [[TGModernDateHeaderView alloc] initWithFrame:it->frame];
                        view.frame = it->frame;
                        view.alpha = 1.0f;
                        [view setDate:it->index];
                        _currentVisibleDecorationViews[it->index] = view;
                        [self insertSubview:view atIndex:0];
                        [view layoutSubviews];
                    }
                    else
                    {
                        TGModernUnreadHeaderView *view = (TGModernUnreadHeaderView *)[_viewStorage dequeueViewWithIdentifier:@"_unread" viewStateIdentifier:nil];
                        if (view == nil)
                            view = [[TGModernUnreadHeaderView alloc] initWithFrame:it->frame];
                        view.frame = it->frame;
                        view.alpha = 1.0f;
                        _currentVisibleDecorationViews[it->index] = view;
                        [self insertSubview:view atIndex:0];
                        [view layoutSubviews];
                    }
                }];
            }
            else if (!CGRectEqualToRect(it->frame, viewIt->second.frame))
                viewIt->second.frame = it->frame;
        }
    }
    
    for (auto it = _currentVisibleDecorationViews.begin(); it != _currentVisibleDecorationViews.end(); )
    {
        if (currentIndices.find(it->first) == currentIndices.end())
        {
            [it->second removeFromSuperview];
            [_viewStorage enqueueView:it->second];
            _currentVisibleDecorationViews.erase(it++);
        }
        else
            ++it;
    }
    
    [self updateHeaderView];
    
    //if (_currentVisibleDecorationViews.size() != previousCount)
    //    TGLog(@"new size: %ld", _currentVisibleDecorationViews.size());
}

- (void)setHeaderView:(UIView *)headerView
{
    [_headerView removeFromSuperview];
    _headerView = headerView;
    if (_headerView != nil)
    {
        _headerView.transform = CGAffineTransformMakeRotation((CGFloat)M_PI);
        [self addSubview:_headerView];
    }
}

- (void)updateHeaderView
{
    if (_headerView != nil)
    {
        CGRect headerViewFrame = [self headerViewFrame];
        if (!CGRectEqualToRect(_headerView.frame, headerViewFrame))
        {
            _headerView.frame = headerViewFrame;
        }
    }
}

- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL))completion
{
    [self performBatchUpdates:updates completion:completion beforeDecorations:nil animated:true animationFactor:0.7f];
}

- (bool)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL))completion beforeDecorations:(void (^)())beforeDecorations animated:(bool)animated animationFactor:(float)animationFactor {
    return [self performBatchUpdates:updates completion:completion beforeDecorations:beforeDecorations animated:animated animationFactor:animationFactor insideAnimation:nil];
}

- (bool)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL))completion beforeDecorations:(void (^)())beforeDecorations animated:(bool)animated animationFactor:(float)animationFactor insideAnimation:(void (^)())insideAnimation
{
    std::map<NSInteger, CGRect> previousDecorationViewFrames;
    NSMutableDictionary *removedViews = [[NSMutableDictionary alloc] init];
    
    CGRect previousHeaderViewFrame = _headerView.frame;
    
    if (animated)
    {
        std::vector<TGDecorationViewAttrubutes> *pAttributes = [(TGModernConversationViewLayout *)self.collectionViewLayout allDecorationViewAttributes];
        if (pAttributes != NULL)
        {
            for (auto it = pAttributes->begin(); it != pAttributes->end(); it++)
            {
                previousDecorationViewFrames[it->index] = it->frame;
            }
        }
        
        for (auto it = _currentVisibleDecorationViews.begin(); it != _currentVisibleDecorationViews.end(); it++)
        {
            removedViews[@(it->first)] = it->second;
        }
    }
    
    bool decorationUpdatesWereDisabled = _disableDecorationViewUpdates;
    _disableDecorationViewUpdates = true;
    
    UIEdgeInsets previousInset = self.contentInset;
    
    ((TGModernConversationViewLayout *)self.collectionViewLayout).animateLayout = true;
    
    [super performBatchUpdates:updates completion:completion];
    
    ((TGModernConversationViewLayout *)self.collectionViewLayout).animateLayout = false;
    
    if (beforeDecorations)
        beforeDecorations();
    
    _disableDecorationViewUpdates = decorationUpdatesWereDisabled;
    
    if (animated)
    {
        [self updateVisibleDecorationViews];
        
        std::map<NSInteger, CGRect> currentDecorationViewFrames;
        
        std::vector<TGDecorationViewAttrubutes> *pAttributes = [(TGModernConversationViewLayout *)self.collectionViewLayout allDecorationViewAttributes];
        if (pAttributes != NULL)
        {
            for (auto it = pAttributes->begin(); it != pAttributes->end(); it++)
            {
                currentDecorationViewFrames[it->index] = it->frame;
            }
        }
        
        CGFloat insetDifference = self.contentInset.top - previousInset.top;
        
        for (auto it = _currentVisibleDecorationViews.begin(); it != _currentVisibleDecorationViews.end(); it++)
        {
            [removedViews enumerateKeysAndObjectsUsingBlock:^(id key, UIView *obj, BOOL *stop)
            {
                if (it->second == obj)
                {
                    [removedViews removeObjectForKey:key];
                    *stop = true;
                }
            }];
            
            auto previousIt = previousDecorationViewFrames.find(it->first);
            auto currentIt = currentDecorationViewFrames.find(it->first);
            
            if (previousIt != previousDecorationViewFrames.end())
                it->second.frame = previousIt->second;
            else if (currentIt != currentDecorationViewFrames.end())
            {
                it->second.frame = CGRectMake(0, currentIt->second.origin.y - currentIt->second.size.height + insetDifference, currentIt->second.size.width, currentIt->second.size.height);
                it->second.alpha = 0.0f;
            }
            
            [it->second layoutSubviews];
        }
        
        [removedViews enumerateKeysAndObjectsUsingBlock:^(id key, UIView *view, __unused BOOL *stop)
        {
            if (previousDecorationViewFrames.find([key intValue]) != previousDecorationViewFrames.end())
            {
                if ([key intValue] == INT_MIN)
                {
                    if (view == [_viewStorage dequeueViewWithIdentifier:@"_unread" viewStateIdentifier:nil])
                    {
                        [self insertSubview:view atIndex:0];
                    }
                }
                else
                {
                    if (view == [_viewStorage dequeueViewWithIdentifier:@"_date" viewStateIdentifier:[[NSString alloc] initWithFormat:@"date/%d", [key intValue]]])
                    {
                        [self insertSubview:view atIndex:0];
                    }
                }
            }
        }];
        
        _headerView.frame = previousHeaderViewFrame;
        
        [UIView animateWithDuration:iosMajorVersion() >= 7 ? 0.3 : 0.3 * animationFactor delay:0 options:0 animations:^
        {
            for (auto it = _currentVisibleDecorationViews.begin(); it != _currentVisibleDecorationViews.end(); it++)
            {
                auto currentIt = currentDecorationViewFrames.find(it->first);
                
                if (currentIt != currentDecorationViewFrames.end())
                    it->second.frame = currentIt->second;
                it->second.alpha = 1.0f;
                
                [it->second layoutSubviews];
            }
            
            [removedViews enumerateKeysAndObjectsUsingBlock:^(id key, UIView *view, __unused BOOL *stop)
            {
                auto currentIt = currentDecorationViewFrames.find([key intValue]);
                
                if (currentIt == currentDecorationViewFrames.end())
                    view.alpha = 0.0f;
                else
                    view.frame = currentIt->second;
                
                [view layoutSubviews];
            }];
            
            [self updateHeaderView];
            
            if (insideAnimation) {
                insideAnimation();
            }
        } completion:^(__unused BOOL finished)
        {
            [removedViews enumerateKeysAndObjectsUsingBlock:^(__unused id key, UIView *view, __unused BOOL *stop)
            {
                [_viewStorage enqueueView:view];
                [view removeFromSuperview];
            }];
        }];
    }
    
    return true;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    if (ABS(bounds.origin.y - _lastRelativeBoundsReport) > 5.0f)
    {
        if ([self updateRelativeBounds])
            _lastRelativeBoundsReport = bounds.origin.y;
    }
    
    [self updateVisibleDecorationViews];
}

- (bool)updateRelativeBounds
{
    bool anyUpdated = false;
    Class cellClass = [TGModernCollectionCell class];
    CGRect bounds = self.bounds;
    for (UIView *subview in self.subviews)
    {
        if ([subview isKindOfClass:cellClass] && ((TGModernCollectionCell *)subview)->_needsRelativeBoundsUpdateNotifications)
        {
            anyUpdated = true;
            CGPoint subviewPosition = subview.frame.origin;
            [(TGModernCollectionCell *)subview relativeBoundsUpdated:CGRectOffset(bounds, -subviewPosition.x, -subviewPosition.y)];
        }
    }
    
    return anyUpdated;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)__unused otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[TGModernConversationCollectionViewInstantPreviewRecognizer class]])
        return true;
    
    return false;
}

- (UIView *)resizableSnapshotViewFromRect:(CGRect)rect afterScreenUpdates:(BOOL)afterUpdates withCapInsets:(UIEdgeInsets)capInsets
{
    UIView *snapshotView = nil;
    CGRect viewport = [self convertRect:self.bounds toView:self];
    viewport.origin.y += self.contentInset.top;
    viewport.size.height -= self.contentInset.top + self.contentInset.bottom;
    
    if (CGRectGetMinY(rect) <= CGRectGetMinY(viewport) || CGRectGetMaxX(rect) >= CGRectGetMaxY(viewport))
    {
        for (UICollectionViewCell *cell in self.visibleCells)
        {
            if (CGRectIntersectsRect(rect, cell.frame))
            {
                snapshotView = [cell resizableSnapshotViewFromRect:CGRectMake(rect.origin.x, rect.origin.y - cell.frame.origin.y, rect.size.width, rect.size.height) afterScreenUpdates:afterUpdates withCapInsets:UIEdgeInsetsZero];
                break;
            }
        }
    }
    
    if (snapshotView == nil)
        snapshotView = [super resizableSnapshotViewFromRect:rect afterScreenUpdates:afterUpdates withCapInsets:capInsets];
    
    snapshotView.transform = self.transform;
    return snapshotView;
}

@end
