#import "TGAppearancePreviewCollectionItem.h"

#import "TGAppearancePreviewCollectionItemView.h"

@interface TGAppearancePreviewCollectionItem ()
{
    CGFloat _cachedHeight;
}
@end

@implementation TGAppearancePreviewCollectionItem

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.highlightable = false;
        self.selectable = false;
    }
    return self;
}

- (void)bindView:(TGAppearancePreviewCollectionItemView *)view
{
    [super bindView:view];
    
    view.messages = _messages;
    view.fontSize = _fontSize;
    [view updateWallpaper];
    
    if (fabs(view.contentHeight - _cachedHeight) > FLT_EPSILON)
    {
        _cachedHeight = view.contentHeight;
        if (self.heightChanged)
            self.heightChanged();
    }
}

- (void)unbindView
{
    [super unbindView];
}

- (void)setMessages:(NSArray *)messages
{
    _messages = messages;
    
    TGAppearancePreviewCollectionItemView *view = (TGAppearancePreviewCollectionItemView *)self.boundView;
    [view setMessages:messages];
    
    if (fabs(view.contentHeight - _cachedHeight) > FLT_EPSILON)
    {
        _cachedHeight = view.contentHeight;
        if (self.heightChanged)
            self.heightChanged();
    }
}

- (void)setFontSize:(int32_t)fontSize
{
    _fontSize = fontSize;
    
    TGAppearancePreviewCollectionItemView *view = (TGAppearancePreviewCollectionItemView *)self.boundView;
    [view setFontSize:fontSize];

    if (fabs(view.contentHeight - _cachedHeight) > FLT_EPSILON)
    {
        _cachedHeight = view.contentHeight;
        if (self.heightChanged)
            self.heightChanged();
    }
}

- (void)updateWallpaper
{
    TGAppearancePreviewCollectionItemView *view = (TGAppearancePreviewCollectionItemView *)self.boundView;
    [view updateWallpaper];
}

- (void)reset
{
    TGAppearancePreviewCollectionItemView *view = (TGAppearancePreviewCollectionItemView *)self.boundView;
    [view reset];
}

- (void)refreshMetrics
{
    TGAppearancePreviewCollectionItemView *view = (TGAppearancePreviewCollectionItemView *)self.boundView;
    [view refreshMetrics];
    
    if (fabs(view.contentHeight - _cachedHeight) > FLT_EPSILON)
    {
        _cachedHeight = view.contentHeight;
        if (self.heightChanged)
            self.heightChanged();
    }
}

- (Class)itemViewClass
{
    return [TGAppearancePreviewCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    if (_cachedHeight < FLT_EPSILON)
    {
        TGAppearancePreviewCollectionItemView *view = (TGAppearancePreviewCollectionItemView *)self.boundView;
        _cachedHeight = view.contentHeight;
    }
    return CGSizeMake(containerSize.width, _cachedHeight);
}

@end
