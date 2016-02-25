#import "TGMenuSheetView.h"
#import "TGMenuSheetItemView.h"

#import "TGImageUtils.h"
#import "TGAppDelegate.h"

NSString *const TGMenuDividerTop = @"top";
NSString *const TGMenuDividerBottom = @"bottom";

const bool TGMenuSheetUseEffectView = false;

const CGFloat TGMenuSheetCornerRadius = 14.5f;
const UIEdgeInsets TGMenuSheetPhoneEdgeInsets = { 10.0f, 10.0f, 10.0f, 10.0f };
const CGFloat TGMenuSheetInterSectionSpacing = 8.0f;

@interface TGMenuSheetScrollView : UIScrollView

@end

@implementation TGMenuSheetScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.showsHorizontalScrollIndicator = false;
        self.showsVerticalScrollIndicator = false;
    }
    return self;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)__unused view
{
    return true;
}

@end

@interface TGMenuSheetBackgroundView : UIView
{
    UIVisualEffectView *_effectView;
    UIImageView *_imageView;
}
@end

@implementation TGMenuSheetBackgroundView

- (instancetype)initWithFrame:(CGRect)frame sizeClass:(UIUserInterfaceSizeClass)sizeClass
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.clipsToBounds = true;
        
        if (TGMenuSheetUseEffectView)
        {
            self.layer.cornerRadius = TGMenuSheetCornerRadius;
            
            _effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
            _effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _effectView.frame = self.bounds;
            [self addSubview:_effectView];
        }
        else
        {
            static dispatch_once_t onceToken;
            static UIImage *backgroundImage;
            dispatch_once(&onceToken, ^
            {
                CGRect rect = CGRectMake(0, 0, TGMenuSheetCornerRadius * 2 + 1, TGMenuSheetCornerRadius * 2 + 1);
                UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                
                CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:TGMenuSheetCornerRadius] fill];
                
                backgroundImage = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(TGMenuSheetCornerRadius, TGMenuSheetCornerRadius, TGMenuSheetCornerRadius, TGMenuSheetCornerRadius)];
                UIGraphicsEndImageContext();
            });
            
            _imageView = [[UIImageView alloc] initWithImage:backgroundImage];
            _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _imageView.frame = self.bounds;
            [self addSubview:_imageView];
        }
        
        [self updateTraitsWithSizeClass:sizeClass];
        
        [self setMaskEnabled:true];
    }
    return self;
}

- (void)setMaskEnabled:(bool)enabled
{
    if (TGMenuSheetUseEffectView)
        return;
    
    if (!enabled)
        return;
    
    self.layer.cornerRadius = enabled ? TGMenuSheetCornerRadius : 0.0f;
}

- (void)updateTraitsWithSizeClass:(UIUserInterfaceSizeClass)sizeClass
{
    bool hidden = (sizeClass == UIUserInterfaceSizeClassRegular);
    _effectView.hidden = hidden;
    _imageView.hidden = hidden;
}

@end

@interface TGMenuSheetView ()
{
    TGMenuSheetBackgroundView *_headerBackgroundView;
    TGMenuSheetBackgroundView *_mainBackgroundView;
    TGMenuSheetBackgroundView *_footerBackgroundView;
    
    TGMenuSheetScrollView *_scrollView;
    
    NSMutableArray *_itemViews;
    NSMutableDictionary *_dividerViews;
    
    UIUserInterfaceSizeClass _sizeClass;
}
@end

@implementation TGMenuSheetView

- (instancetype)initWithItemViews:(NSArray *)itemViews sizeClass:(UIUserInterfaceSizeClass)sizeClass
{
    self = [super initWithFrame:CGRectZero];
    if (self != nil)
    {
        self.backgroundColor = [UIColor clearColor];
        
        _itemViews = [[NSMutableArray alloc] init];
        _dividerViews = [[NSMutableDictionary alloc] init];
        
        _sizeClass = sizeClass;
        
        [self addItemViews:itemViews];
    }
    return self;
}

#pragma mark -

- (void)addItemsView:(TGMenuSheetItemView *)itemView
{
    [self addItemView:itemView hasHeader:self.hasHeader hasFooter:self.hasFooter];
}

- (void)addItemView:(TGMenuSheetItemView *)itemView hasHeader:(bool)hasHeader hasFooter:(bool)hasFooter
{
    TGMenuSheetItemView *previousItemView = nil;
    
    itemView.tag = _itemViews.count;
    
    switch (itemView.type)
    {
        case TGMenuSheetItemTypeDefault:
        {
            if (hasFooter)
                [_itemViews insertObject:itemView atIndex:_itemViews.count - 1];
            else
                [_itemViews addObject:itemView];
            
            if (_mainBackgroundView == nil)
            {
                _mainBackgroundView = [[TGMenuSheetBackgroundView alloc] initWithFrame:CGRectZero sizeClass:_sizeClass];
                [self insertSubview:_mainBackgroundView atIndex:0];
                
                _scrollView = [[TGMenuSheetScrollView alloc] initWithFrame:CGRectZero];
                [_mainBackgroundView addSubview:_scrollView];
            }
            
            UIView *divider = [self createDividerForItemView:itemView previousItemView:previousItemView];
            if (divider != nil)
                [_scrollView addSubview:divider];
            
            [_scrollView addSubview:itemView];
        }
            break;
        
        case TGMenuSheetItemTypeHeader:
        {
            if (hasHeader)
                return;
            
            [_itemViews insertObject:itemView atIndex:0];
            
            if (_headerBackgroundView == nil)
            {
                _headerBackgroundView = [[TGMenuSheetBackgroundView alloc] initWithFrame:CGRectZero sizeClass:_sizeClass];
                [self insertSubview:_headerBackgroundView atIndex:0];
            }
            
            [_headerBackgroundView addSubview:itemView];
        }
            break;
            
        case TGMenuSheetItemTypeFooter:
        {
            if (hasFooter)
                return;
            
            [_itemViews addObject:itemView];
            
            if (_footerBackgroundView == nil)
            {
                _footerBackgroundView = [[TGMenuSheetBackgroundView alloc] initWithFrame:CGRectZero sizeClass:_sizeClass];
                [self insertSubview:_footerBackgroundView atIndex:0];
            }
            
            [_footerBackgroundView addSubview:itemView];
        }
            break;
            
        default:
            break;
    }
    
    __weak TGMenuSheetView *weakSelf = self;
    itemView.layoutUpdateBlock = ^
    {
        __strong TGMenuSheetView *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf layoutSubviews];
        if (strongSelf.menuRelayout != nil)
            strongSelf.menuRelayout();
    };
    
    __weak TGMenuSheetItemView *weakItemView = itemView;
    itemView.highlightUpdateBlock = ^(bool highlighted)
    {
        __strong TGMenuSheetView *strongSelf = weakSelf;
        __strong TGMenuSheetItemView *strongItemView = weakItemView;
        if (strongSelf != nil && weakItemView != nil)
        {
            switch (strongItemView.type)
            {
                case TGMenuSheetItemTypeHeader:
                    [strongSelf->_headerBackgroundView setMaskEnabled:highlighted];
                    break;
                
                case TGMenuSheetItemTypeFooter:
                    [strongSelf->_footerBackgroundView setMaskEnabled:highlighted];
                    break;
                
                default:
                    [strongSelf->_mainBackgroundView setMaskEnabled:highlighted];
                    break;
            }
        };
    };
}

- (void)addItemViews:(NSArray *)itemViews
{
    bool hasHeader = self.hasHeader;
    bool hasFooter = self.hasFooter;
    
    for (TGMenuSheetItemView *itemView in itemViews)
    {
        [self addItemView:itemView hasHeader:hasHeader hasFooter:hasFooter];
        
        if (itemView.type == TGMenuSheetItemTypeHeader)
            hasHeader = true;
        else if (itemView.type == TGMenuSheetItemTypeFooter)
            hasFooter = true;
    }
}

- (UIView *)createDividerForItemView:(TGMenuSheetItemView *)itemView previousItemView:(TGMenuSheetItemView *)previousItemView
{
    if (!itemView.requiresDivider)
        return nil;
    
    UIView *topDivider = nil;
    if (previousItemView != nil)
        topDivider = _dividerViews[@(previousItemView.tag)][TGMenuDividerBottom];
        
    UIView *bottomDivider = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, TGIsRetina() ? 0.5f : 1.0f)];
    bottomDivider.backgroundColor = TGSeparatorColor();
    
    NSMutableDictionary *dividers = [[NSMutableDictionary alloc] init];
    if (topDivider != nil)
        dividers[TGMenuDividerTop] = topDivider;
    dividers[TGMenuDividerBottom] = bottomDivider;
    _dividerViews[@(itemView.tag)] = dividers;
    
    return bottomDivider;
}

#pragma mark -

- (void)updateTraitsWithSizeClass:(UIUserInterfaceSizeClass)sizeClass
{
    _sizeClass = sizeClass;
    
    bool hideNonRegularItems = (_sizeClass == UIUserInterfaceSizeClassRegular);
    
    for (TGMenuSheetItemView *itemView in _itemViews)
    {
        itemView.sizeClass = sizeClass;
        if (itemView.type == TGMenuSheetItemTypeHeader || itemView.type == TGMenuSheetItemTypeFooter)
            [itemView setHidden:hideNonRegularItems animated:false];
    }
    
    [_headerBackgroundView updateTraitsWithSizeClass:sizeClass];
    [_mainBackgroundView updateTraitsWithSizeClass:sizeClass];
    [_footerBackgroundView updateTraitsWithSizeClass:sizeClass];
}

#pragma mark -

- (UIEdgeInsets)edgeInsets
{
    if (_sizeClass == UIUserInterfaceSizeClassRegular)
        return UIEdgeInsetsZero;

    return TGMenuSheetPhoneEdgeInsets;
}

- (CGFloat)interSectionSpacing
{
    return TGMenuSheetInterSectionSpacing;
}

- (CGSize)menuSize
{
    return CGSizeMake(self.menuWidth, self.menuHeight);
}

- (CGFloat)menuHeight
{
    CGFloat maxHeight = TGAppDelegateInstance.rootController.applicationBounds.size.height;
    return MIN(maxHeight, [self menuHeightForWidth:self.menuWidth - self.edgeInsets.left - self.edgeInsets.right]);
}

- (CGFloat)menuHeightForWidth:(CGFloat)width
{
    CGFloat height = 0.0f;
    CGFloat screenHeight = TGAppDelegateInstance.rootController.applicationBounds.size.height;
    UIEdgeInsets edgeInsets = self.edgeInsets;
    
    bool hasRegularItems = false;
    bool hasHeader = false;
    bool hasFooter = false;
    
    for (TGMenuSheetItemView *itemView in self.itemViews)
    {
        bool skip = false;
        
        switch (itemView.type)
        {
            case TGMenuSheetItemTypeDefault:
                hasRegularItems = true;
                break;
                
            case TGMenuSheetItemTypeHeader:
                if (_sizeClass == UIUserInterfaceSizeClassRegular)
                    skip = true;
                else
                    hasHeader = true;
                break;
                
            case TGMenuSheetItemTypeFooter:
                if (_sizeClass == UIUserInterfaceSizeClassRegular)
                    skip = true;
                else
                    hasFooter = true;
                break;
                
            default:
                break;
        }
        
        if (!skip)
        {
            height += [itemView preferredHeightForWidth:width screenHeight:screenHeight];
            height += itemView.contentHeightCorrection;
        }
    }
    
    if (hasRegularItems || hasHeader || hasFooter)
        height += self.edgeInsets.top + self.edgeInsets.bottom;
    
    if ((hasRegularItems && hasHeader) || (hasRegularItems && hasFooter) || (hasHeader && hasFooter))
        height += self.interSectionSpacing;
    
    if (hasHeader && hasFooter && hasRegularItems)
        height += self.interSectionSpacing;
    
    if (fabs(height - screenHeight) <= edgeInsets.top)
        height = screenHeight;
    
    return height;
}

- (CGFloat)contentHeightCorrection
{
    CGFloat height = 0.0f;
    
    for (TGMenuSheetItemView *itemView in self.itemViews)
        height += itemView.contentHeightCorrection;
    
    return height;
}

#pragma mark - 

- (TGMenuSheetItemView *)headerItemView
{
    if (_sizeClass == UIUserInterfaceSizeClassRegular)
        return nil;
    
    if ([(TGMenuSheetItemView *)self.itemViews.firstObject type] == TGMenuSheetItemTypeHeader)
        return self.itemViews.firstObject;
    
    return nil;
}

- (TGMenuSheetItemView *)footerItemView
{
    if (_sizeClass == UIUserInterfaceSizeClassRegular)
        return nil;
    
    if ([(TGMenuSheetItemView *)self.itemViews.lastObject type] == TGMenuSheetItemTypeFooter)
        return self.itemViews.lastObject;
    
    return nil;
}

- (bool)hasHeader
{
    if (_sizeClass == UIUserInterfaceSizeClassRegular)
        return nil;
    
    return (self.headerItemView != nil);
}

- (bool)hasFooter
{
    if (_sizeClass == UIUserInterfaceSizeClassRegular)
        return nil;
    
    return (self.footerItemView != nil);
}

- (NSValue *)mainFrame
{
    if (_mainBackgroundView != nil)
        return [NSValue valueWithCGRect:_mainBackgroundView.frame];
    
    return nil;
}

- (NSValue *)headerFrame
{
    if (_headerBackgroundView != nil)
        return [NSValue valueWithCGRect:_headerBackgroundView.frame];
    
    return nil;
}

- (NSValue *)footerFrame
{
    if (_footerBackgroundView != nil)
        return [NSValue valueWithCGRect:_footerBackgroundView.frame];
    
    return nil;
}

#pragma mark -

- (void)menuWillAppearAnimated:(bool)animated
{
    for (TGMenuSheetItemView *itemView in self.itemViews)
        [itemView menuView:self willAppearAnimated:animated];
}

- (void)menuDidAppearAnimated:(bool)animated
{
    for (TGMenuSheetItemView *itemView in self.itemViews)
        [itemView menuView:self didAppearAnimated:animated];
}

- (void)menuWillDisappearAnimated:(bool)animated
{
    for (TGMenuSheetItemView *itemView in self.itemViews)
        [itemView menuView:self willDisappearAnimated:animated];
}

- (void)menuDidDisappearAnimated:(bool)animated
{
    for (TGMenuSheetItemView *itemView in self.itemViews)
        [itemView menuView:self didDisappearAnimated:animated];
}

- (void)layoutSubviews
{
    CGFloat width = self.menuWidth - self.edgeInsets.left - self.edgeInsets.right;
    CGFloat maxHeight = TGAppDelegateInstance.rootController.applicationBounds.size.height;
    CGFloat screenHeight = maxHeight;

    if (self.headerItemView != nil)
        maxHeight -= [self.headerItemView preferredHeightForWidth:width screenHeight:screenHeight] + self.interSectionSpacing;
    
    if (self.footerItemView != nil)
        maxHeight -= [self.footerItemView preferredHeightForWidth:width screenHeight:screenHeight] + self.interSectionSpacing;
    
    CGFloat contentHeight = 0;
    bool hasRegularItems = false;
    
    NSUInteger i = 0;
    for (TGMenuSheetItemView *itemView in self.itemViews)
    {
        if (itemView.type == TGMenuSheetItemTypeDefault)
        {
            hasRegularItems = true;
            
            CGFloat height = [itemView preferredHeightForWidth:width screenHeight:screenHeight];
            itemView.screenHeight = screenHeight;
            itemView.frame = CGRectMake(0, contentHeight, width, height);
            contentHeight += height;
            
            if (itemView.requiresDivider && i != self.itemViews.count - 2)
            {
                UIView *divider = _dividerViews[@(itemView.tag)][TGMenuDividerBottom];
                if (divider != nil)
                    divider.frame = CGRectMake(0, CGRectGetMaxY(itemView.frame) - divider.frame.size.height, width, divider.frame.size.height);
            }
        }
        i++;
    }
    contentHeight += self.contentHeightCorrection;
    
    UIEdgeInsets edgeInsets = self.edgeInsets;
    CGSize statusBarSize = [UIApplication sharedApplication].statusBarFrame.size;
    CGFloat statusBarHeight = MIN(statusBarSize.width, statusBarSize.height);
    statusBarHeight = MAX(statusBarHeight, 20.0f);
    
    if (contentHeight > (maxHeight - edgeInsets.top - edgeInsets.bottom))
        edgeInsets.top = statusBarHeight;
    
    CGFloat bottomCorrection = 0.0f;
    if (fabs(contentHeight - maxHeight + edgeInsets.bottom) <= statusBarHeight)
    {
        edgeInsets.top = statusBarHeight;
        bottomCorrection += edgeInsets.bottom;
    }
    
    maxHeight -= edgeInsets.top + edgeInsets.bottom;
    
    CGFloat topInset = edgeInsets.top;
    if (self.headerItemView != nil)
    {
        _headerBackgroundView.frame = CGRectMake(edgeInsets.left, topInset, width, [self.headerItemView preferredHeightForWidth:width screenHeight:screenHeight]);
        self.headerItemView.frame = _headerBackgroundView.bounds;
        
        topInset = CGRectGetMaxY(_headerBackgroundView.frame) + TGMenuSheetInterSectionSpacing;
    }
    
    if (hasRegularItems)
    {
        _mainBackgroundView.frame = CGRectMake(edgeInsets.left, topInset, width, MIN(contentHeight, maxHeight));
        _scrollView.frame = _mainBackgroundView.bounds;
        _scrollView.contentSize = CGSizeMake(width, contentHeight);
    }
    
    if (self.footerItemView != nil)
    {
        CGFloat height = [self.footerItemView preferredHeightForWidth:width screenHeight:screenHeight];
        CGFloat top = self.menuHeight - edgeInsets.bottom - height;
        if (hasRegularItems)
            top = CGRectGetMaxY(_mainBackgroundView.frame) + TGMenuSheetInterSectionSpacing;
    
        _footerBackgroundView.frame = CGRectMake(edgeInsets.left, top, width, height);
        self.footerItemView.frame = _footerBackgroundView.bounds;
    }
}

@end
