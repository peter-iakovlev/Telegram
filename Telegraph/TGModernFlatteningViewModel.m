#import "TGModernFlatteningViewModel.h"

#import "TGModernFlatteningView.h"

#import "TGImageUtils.h"

CGFloat TGModernFlatteningViewModelTilingLimit = 512.0f;

@interface TGModernFlatteningViewModel ()
{
    bool _needsContentUpdate;
    TGModernViewContext *_context;
    
    bool _tiledMode;
    TGModernViewStorage *_viewStorage;
    NSMutableArray *_tiledPartViews;
}

@end

@implementation TGModernFlatteningViewModel

- (instancetype)init
{
    return [self initWithContext:nil];
}

- (id)initWithContext:(TGModernViewContext *)context
{
    self = [super init];
    if (self != nil)
    {
        _context = context;
        self.disableSubmodelAutomaticBinding = 1;
    }
    return self;
}

- (Class)viewClass
{
    return [TGModernFlatteningView class];
}

- (void)setTiledMode:(bool)tiledMode
{
    if (tiledMode != _tiledMode)
    {
        _tiledMode = tiledMode;
        
        if ([self boundView] != nil)
        {
            if (_tiledMode)
            {
                if (_tiledPartViews == nil)
                    _tiledPartViews = [[NSMutableArray alloc] init];
                
                if (_context == nil || !_context.contentUpdatesDisabled)
                    [self boundView].layer.contents = nil;
            }
            else
            {
                if (_context == nil || !_context.contentUpdatesDisabled)
                    [self _dropTiledPartViews];
            }
        }
    }
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    TGModernFlatteningView *view = (TGModernFlatteningView *)[self boundView];
    view.specialUserInteraction = self.allowSpecialUserInteraction;
    
    _viewStorage = viewStorage;
    
    [self _updateSubmodelContents];
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    [super unbindView:viewStorage];
    
    [self _dropTiledPartViews];
    
    _needsContentUpdate = false;
}

- (void)_dropTiledPartViews
{
    if (_tiledPartViews != nil)
    {
        for (TGModernFlatteningView *tileView in _tiledPartViews)
        {
            [tileView removeFromSuperview];
            [_viewStorage enqueueView:tileView];
        }
        
        [_tiledPartViews removeAllObjects];
    }
}

+ (CGContextRef)_createContentContext:(CGSize)size
{
    CGSize contextSize = size;
    CGFloat scaling = TGScreenScaling();

    contextSize.width *= scaling;
    contextSize.height *= scaling;
    
    size_t bytesPerRow = 4 * (int)contextSize.width;
    bytesPerRow = (bytesPerRow + 15) & ~15;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
    
    CGContextRef context = CGBitmapContextCreate(NULL, (int)contextSize.width, (int)contextSize.height, 8, bytesPerRow, colorSpace, bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    
    CGContextScaleCTM(context, scaling, scaling);
    
    return context;
}

- (void)animateWithSnapshot
{
    TGModernFlatteningView *view = (TGModernFlatteningView *)[self boundView];
    if (view != nil && !CGRectIsEmpty(self.frame) && view.layer.contents != nil)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage alloc] initWithCGImage:(__bridge CGImageRef)view.layer.contents]];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.frame = self.frame;
        [view.superview addSubview:imageView];
        
        imageView.alpha = 1.0f;
        view.alpha = 0.0f;
        [UIView animateWithDuration:0.3 animations:^
        {
            view.alpha = 1.0f;
            imageView.alpha = 0.0f;
        } completion:^(__unused BOOL finished)
        {
            [imageView removeFromSuperview];
        }];
    }
}

- (void)_updateSubmodelContents
{
    TGModernFlatteningView *view = (TGModernFlatteningView *)[self boundView];
    if (view != nil && !CGRectIsEmpty(self.frame))
    {
        if (_context != nil && _context.contentUpdatesDisabled)
            _needsContentUpdate = true;
        else if (!_tiledMode)
        {
            [self _updateSubmodelContentsForLayer:view.layer visibleRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            _needsContentUpdate = false;
        }
        else
        {
            view.layer.contents = nil;
            
            [self _dropTiledPartViews];
            _needsContentUpdate = false;
        }
    }
}

- (void)setNeedsSubmodelContentsUpdate
{
    _needsContentUpdate = true;
}

- (bool)needsSubmodelContentsUpdate
{
    return _needsContentUpdate;
}

- (void)updateSubmodelContentsIfNeeded
{
    if (_needsContentUpdate)
        [self _updateSubmodelContents];
}

- (void)updateSubmodelContentsForVisibleRect:(CGRect)rect
{
    if (_tiledMode && (_context == nil || !_context.contentUpdatesDisabled) && [self boundView] != nil)
    {
        [UIView performWithoutAnimation:^
        {
            TGModernFlatteningView *view = (TGModernFlatteningView *)[self boundView];
            CGSize tiledViewSize = CGSizeMake(view.frame.size.width, TGModernFlatteningViewModelTilingLimit);
            
            CGRect frame = self.frame;
            for (CGFloat originY = 0.0f; originY < frame.size.height; originY += tiledViewSize.height)
            {
                NSInteger compareOriginY = (NSInteger)originY;
                int foundTileIndex = -1;
                
                if (_tiledPartViews == nil)
                    _tiledPartViews = [[NSMutableArray alloc] init];
                
                int index = -1;
                for (TGModernFlatteningView *tileView in _tiledPartViews)
                {
                    index++;
                    NSInteger tileOriginY = (NSInteger)tileView.frame.origin.y;
                    if (tileOriginY == compareOriginY)
                    {
                        foundTileIndex = index;
                        break;
                    }
                }
                
                CGRect possibleRect = CGRectMake(rect.origin.x, originY, rect.size.width, tiledViewSize.height);
                if (!CGRectIsNull(CGRectIntersection(rect, possibleRect)))
                {
                    if (foundTileIndex == -1)
                    {
                        static NSString *tileViewIdentifier = @"TGModernFlatteningView";
                        
                        TGModernFlatteningView *tileView = (TGModernFlatteningView *)[_viewStorage dequeueViewWithIdentifier:tileViewIdentifier viewStateIdentifier:nil];
                        if (tileView == nil)
                        {
                            tileView = [[TGModernFlatteningView alloc] init];
                            tileView.viewIdentifier = tileViewIdentifier;
                        }
                        
                        CGRect tileFrame = CGRectMake(0.0f, originY, tiledViewSize.width, MIN(tiledViewSize.height, frame.size.height - originY));
                        
                        tileView.frame = tileFrame;
                        [_tiledPartViews addObject:tileView];
                        [view addSubview:tileView];
                        
                        [self _updateSubmodelContentsForLayer:tileView.layer visibleRect:tileFrame];
                    }
                }
                else if (foundTileIndex != -1)
                {
                    TGModernFlatteningView *tileView = _tiledPartViews[foundTileIndex];
                    [tileView removeFromSuperview];
                    [_viewStorage enqueueView:tileView];
                    [_tiledPartViews removeObjectAtIndex:foundTileIndex];
                }
            }
        }];
    }
}

- (void)_updateSubmodelContentsForLayer:(CALayer *)layer visibleRect:(CGRect)visibleRect
{
    CGRect clipRect = CGRectIntersection(visibleRect, CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height));
    if (clipRect.size.height < FLT_EPSILON)
        return;
    
    CGSize contextSize = clipRect.size;
    CGContextRef context = [TGModernFlatteningViewModel _createContentContext:contextSize];
    UIGraphicsPushContext(context);
    
    CGContextTranslateCTM(context, contextSize.width / 2.0f, contextSize.height / 2.0f);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGContextTranslateCTM(context, -contextSize.width / 2.0f, -contextSize.height / 2.0f);
    
    if (visibleRect.origin.y > FLT_EPSILON)
        CGContextTranslateCTM(context, 0.0f, -visibleRect.origin.y);
    
    [self drawSubmodelsInContext:context];
    
    UIGraphicsPopContext();
    
    CGImageRef contextImageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    layer.contents = (__bridge id)(contextImageRef);
    CGImageRelease(contextImageRef);
}

@end
