#import "TGStickerPreviewPagingScrollView.h"

#import "TGStickerPreviewPage.h"
#import "TGStickerPack.h"

@interface TGStickerPreviewPagingScrollView ()
{
    CGFloat _pageGap;
    TGStickerPack *_stickerPack;
    NSMutableArray *_visiblePages;
    NSMutableArray *_pageQueue;
}

@end

@implementation TGStickerPreviewPagingScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _pageGap = 19.0f;
        _visiblePages = [[NSMutableArray alloc] init];
        _pageQueue = [[NSMutableArray alloc] init];
        self.showsVerticalScrollIndicator = false;
        self.showsHorizontalScrollIndicator = false;
        self.alwaysBounceHorizontal = false;
        self.alwaysBounceVertical = false;
        self.pagingEnabled = true;
    }
    return self;
}

- (void)setStickerPack:(TGStickerPack *)stickerPack
{
    _stickerPack = stickerPack;
}

- (NSUInteger)pageCount
{
    return _stickerPack.documents.count / 9 + (_stickerPack.documents.count % 9 == 0 ? 0 : 1);
}

- (void)enqueuePage:(TGStickerPreviewPage *)page
{
    [page prepareForReuse];
    [page removeFromSuperview];
    [_pageQueue addObject:page];
}

- (TGStickerPreviewPage *)dequeuePage
{
    TGStickerPreviewPage *page = [_pageQueue lastObject];
    if (page != nil)
    {
        [_pageQueue removeLastObject];
        return page;
    }
    
    page = [[TGStickerPreviewPage alloc] init];
    return page;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    if (bounds.size.width > FLT_EPSILON)
    {
        NSUInteger pageCount = [self pageCount];
        CGFloat fuzzyPage = MAX(0.0f, MIN(pageCount, bounds.origin.x / bounds.size.width));
        if (_pageChanged)
            _pageChanged(fuzzyPage);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect visibleBounds = self.bounds;
    
    NSUInteger pageCount = [self pageCount];
    
    self.contentSize = CGSizeMake(visibleBounds.size.width * pageCount, visibleBounds.size.height);
    
    for (NSInteger i = 0; i < (NSInteger)_visiblePages.count; i++)
    {
        TGStickerPreviewPage *page = _visiblePages[i];
        if (!CGRectIntersectsRect(page.frame, visibleBounds))
        {
            [_visiblePages removeObjectAtIndex:i];
            i--;
        }
    }
    
    for (NSUInteger i = 0; i < pageCount; i++)
    {
        CGRect pageFrame = CGRectMake(i * visibleBounds.size.width + _pageGap, 0.0f, visibleBounds.size.width - _pageGap * 2.0f, visibleBounds.size.height);
        if (CGRectIntersectsRect(pageFrame, visibleBounds))
        {
            bool found = false;
            for (TGStickerPreviewPage *page in _visiblePages)
            {
                if (page.pageIndex == i)
                {
                    found = true;
                    break;
                }
            }
            
            if (!found)
            {
                TGStickerPreviewPage *page = [self dequeuePage];
                page.pageIndex = i;
                page.frame = pageFrame;
                NSMutableArray *pageDocuments = [[NSMutableArray alloc] init];
                for (NSUInteger j = i * 9; j < _stickerPack.documents.count && j < i * 9 + 9; j++)
                {
                    [pageDocuments addObject:_stickerPack.documents[j]];
                }
                [page setDocuments:pageDocuments stickerAssociations:_stickerPack.stickerAssociations];
                [_visiblePages addObject:page];
                [self addSubview:page];
            }
        }
    }
}

@end
