#import "TGAppearancePreviewCollectionItemView.h"

#import <LegacyComponents/TGUser.h>

#import "TGModernConversationViewLayout.h"
#import "TGModernConversationCollectionView.h"
#import "TGModernCollectionCell.h"

#import "TGModernViewStorage.h"
#import "TGModernConversationItem.h"
#import "TGMessageModernConversationItem.h"
#import "TGModernConversationViewContext.h"

#import <LegacyComponents/LegacyComponentsGlobals.h>

@interface TGAppearancePreviewCollectionItemView () <UICollectionViewDataSource, UICollectionViewDelegate>
{
    UIImageView *_backgroundView;
    TGModernConversationViewLayout *_collectionLayout;
    TGModernConversationCollectionView *_collectionView;
    NSMutableSet *_collectionRegisteredIdentifiers;
    
    NSArray *_items;
    TGModernViewStorage *_viewStorage;
    TGModernConversationViewContext *_viewContext;
}
@end

@implementation TGAppearancePreviewCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.clipsToBounds = true;
        _backgroundView = [[UIImageView alloc] init];
        _backgroundView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_backgroundView];
        
        _viewContext = [[TGModernConversationViewContext alloc] init];
        
        [self _reset];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    bool hadPresentation = self.presentation != nil;
    [super setPresentation:presentation];
    
    _viewContext.presentation = presentation;
    
    if (hadPresentation)
    {
        [self _reset];
        [self setMessages:_messages];
        
        [_collectionView reloadData];
        [_collectionView layoutSubviews];
    }
}

- (void)reset
{
    [self _reset];
    [self setMessages:_messages];
    
    [_collectionView reloadData];
    [_collectionView layoutSubviews];
}

- (void)_reset
{
    [_collectionView removeFromSuperview];
    _collectionView = nil;
 
    _collectionRegisteredIdentifiers = [[NSMutableSet alloc] init];
    _viewStorage = [[TGModernViewStorage alloc] init];
    
    _collectionLayout = [[TGModernConversationViewLayout alloc] init];
    _collectionLayout.inhibitDateHeaders = true;
    _collectionLayout.viewStorage = _viewStorage;
    _collectionView = [[TGModernConversationCollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height) collectionViewLayout:_collectionLayout];
    if (iosMajorVersion() >= 11)
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    _collectionView.transform = CGAffineTransformMakeRotation((CGFloat)M_PI);
    _collectionView.backgroundColor = nil;
    _collectionView.opaque = false;
    _collectionView.scrollsToTop = false;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.userInteractionEnabled = false;
    [_collectionView registerClass:[TGModernCollectionCell class] forCellWithReuseIdentifier:@"_empty"];
    [self addSubview:_collectionView];
}

- (void)refreshMetrics
{
    for (TGMessageModernConversationItem *item in _items)
    {
        [item refreshMetrics];
    }
    
    [_collectionLayout invalidateLayout];
    [_collectionView layoutSubviews];
    [_collectionView updateRelativeBounds];
}

- (CGFloat)contentHeight
{
    return _collectionView.contentSize.height;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        TGModernConversationItem *item = indexPath.row < (NSInteger)_items.count ? [_items objectAtIndex:indexPath.row] : nil;
        
        if (item != nil)
        {
            __block TGModernCollectionCell *cell = nil;
            cell = [item dequeueCollectionCell:collectionView registeredIdentifiers:_collectionRegisteredIdentifiers forIndexPath:indexPath];
            if (cell.boundItem != nil)
            {
                TGModernConversationItem *item = cell.boundItem;
                [item unbindCell:_viewStorage];
            }
                 
            [self _bindItem:item toCell:cell atIndexPath:indexPath];
        
            return cell;
        }
    }
    
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"_empty" forIndexPath:indexPath];
}

- (NSArray *)items
{
    return _items;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (collectionView == _collectionView)
        return 1;
    
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == _collectionView && section == 0)
        return _items.count;
    return 0;
}

#pragma mark -

- (void)_bindItem:(TGModernConversationItem *)item toCell:(TGModernCollectionCell *)cell atIndexPath:(NSIndexPath *)__unused indexPath
{
    bool movedFromTemporaryContainer = false;
    
    if (!movedFromTemporaryContainer)
    {
        if (item.boundCell != nil)
            [item unbindCell:_viewStorage];
        
        [item bindCell:cell viewStorage:_viewStorage];
    }
}

#pragma mark -

- (void)setFontSize:(int32_t)fontSize
{
    _fontSize = fontSize;
}

- (void)updateWallpaper
{
    _backgroundView.image = [[LegacyComponentsGlobals provider] currentWallpaperImage];
}

- (void)setMessages:(NSArray *)messages
{
    _messages = messages;
    
    TGUser *replyAuthor = [[TGUser alloc] init];
    replyAuthor.firstName = TGLocalized(@"Appearance.PreviewReplyAuthor");
    replyAuthor.uid = 2;
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (TGMessage *message in messages)
    {
        TGMessageModernConversationItem *messageItem = [[TGMessageModernConversationItem alloc] initWithMessage:message context:_viewContext];
        messageItem->_additionalUsers = @[replyAuthor];
        [messageItem sizeForContainerSize:CGSizeMake(_collectionView.frame.size.width, 0.0f) viewStorage:nil];
        
        [items addObject:messageItem];
    }
    
    _items = items;
    [_collectionView reloadData];
    [_collectionView layoutSubviews];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _backgroundView.frame = self.bounds;
    _collectionView.frame = CGRectMake(self.safeAreaInset.left, 0.0f, self.frame.size.width - self.safeAreaInset.left - self.safeAreaInset.right, self.frame.size.height);
}

@end
