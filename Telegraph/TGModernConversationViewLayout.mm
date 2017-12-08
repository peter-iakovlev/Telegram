#import "TGModernConversationViewLayout.h"

#import <LegacyComponents/LegacyComponents.h>
#import "TGTelegraph.h"

#import "TGMessageModernConversationItem.h"
#import "TGMessageViewModel.h"

#import "TGModernConversationCollectionView.h"

#import "TGTelegramNetworking.h"

#import <algorithm>

@interface TGModernConversationViewLayout ()
{
    UIDynamicAnimator *_dynamicAnimator;
    
    NSMutableArray *_layoutAttributes;
    CGSize _contentSize;
    
    int _dateOffset;
    
    NSMutableArray *_insertIndexPaths;
    NSMutableArray *_deleteIndexPaths;
    
    NSMutableDictionary *_cachedGroupedLayouts;
    
    std::vector<TGDecorationViewAttrubutes> _decorationViewAttributes;
}

@end

@implementation TGModernConversationViewLayout

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _layoutAttributes = [[NSMutableArray alloc] init];
        
        _dateOffset = (int)[[TGTelegramNetworking instance] timeOffset];
        
        if (iosMajorVersion() >= 7 && cpuCoreCount() > 1)
            _dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
        
        _cachedGroupedLayouts = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (CGFloat)contentHeight
{
    return _contentSize.height;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    // Keep track of insert and delete index paths
    [super prepareForCollectionViewUpdates:updateItems];
    
    _deleteIndexPaths = [NSMutableArray array];
    _insertIndexPaths = [NSMutableArray array];
    
    for (UICollectionViewUpdateItem *update in updateItems)
    {
        if (update.updateAction == UICollectionUpdateActionDelete)
        {
            [_deleteIndexPaths addObject:update.indexPathBeforeUpdate];
        }
        else if (update.updateAction == UICollectionUpdateActionInsert)
        {
            [_insertIndexPaths addObject:update.indexPathAfterUpdate];
        }
    }
}

- (void)finalizeCollectionViewUpdates
{
    [super finalizeCollectionViewUpdates];
    // release the insert and delete index paths
    _deleteIndexPaths = nil;
    _insertIndexPaths = nil;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    // Must call super
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    if ([_insertIndexPaths containsObject:itemIndexPath])
    {
        // only change attributes on inserted cells
        if (!attributes)
            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        
        attributes = [attributes copy];
        
        attributes.transform3D = CATransform3DMakeTranslation(0.0f, -attributes.frame.size.height - 4.0f, 0.0f);
        
        if (itemIndexPath.item != 0 || iosMajorVersion() < 7 || self.collectionView.contentOffset.y < -self.collectionView.contentInset.top - FLT_EPSILON)
        {
            attributes.alpha = 0.0f;
        }
        else
        {
            attributes.alpha = 1.0f;
            attributes.bounds = CGRectMake(0, 0, attributes.frame.size.width, 24.0);
        }
    }
    
    return attributes;
}

// Note: name of method changed
// Also this gets called for all visible cells (not just the deleted ones) and
// even gets called when inserting cells!
- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    // So far, calling super hasn't been strictly necessary here, but leaving it in
    // for good measure
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    
    if ([_deleteIndexPaths containsObject:itemIndexPath])
    {
        // only change attributes on deleted cells
        if (!attributes)
        {
            //attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        }
        
        attributes = [attributes copy];
        
        // Configure attributes ...
        attributes.alpha = 0.0;
    }
    
    return attributes;
}

static inline CGFloat addDate(CGFloat currentHeight, CGFloat containerWidth, int date, std::vector<TGDecorationViewAttrubutes> *pAttributes)
{
    if (pAttributes != NULL)
        pAttributes->push_back((TGDecorationViewAttrubutes){.index = date, .frame = CGRectMake(0, currentHeight, containerWidth, 27.0f)});
    
    return 27.0f;
}

static inline CGFloat addUnreadHeader(CGFloat currentHeight, CGFloat containerWidth, std::vector<TGDecorationViewAttrubutes> *pAttributes)
{
    if (pAttributes != NULL)
        pAttributes->push_back((TGDecorationViewAttrubutes){.index = INT_MIN, .frame = CGRectMake(0, currentHeight, containerWidth, 31.0f)});
    
    return 31.0f;
}

- (NSArray *)layoutAttributesForItems:(NSArray *)items containerWidth:(CGFloat)containerWidth maxHeight:(CGFloat)maxHeight decorationViewAttributes:(std::vector<TGDecorationViewAttrubutes> *)decorationViewAttributes contentHeight:(CGFloat *)contentHeight viewStorage:(TGModernViewStorage *)viewStorage
{
    return [TGModernConversationViewLayout layoutAttributesForItems:items containerWidth:containerWidth maxHeight:maxHeight dateOffset:_dateOffset decorationViewAttributes:decorationViewAttributes contentHeight:contentHeight unreadMessageRange:((TGModernConversationCollectionView *)self.collectionView).unreadMessageRange viewStorage:viewStorage cachedGroupedLayouts:_cachedGroupedLayouts];
}

+ (NSArray *)layoutAttributesForItems:(NSArray *)items containerWidth:(CGFloat)containerWidth maxHeight:(CGFloat)maxHeight dateOffset:(int)dateOffset decorationViewAttributes:(std::vector<TGDecorationViewAttrubutes> *)decorationViewAttributes contentHeight:(CGFloat *)contentHeight unreadMessageRange:(TGMessageRange)unreadMessageRange viewStorage:(TGModernViewStorage *)viewStorage cachedGroupedLayouts:(NSMutableDictionary *)cachedGroupedLayouts
{
    NSMutableArray *layoutAttributes = [[NSMutableArray alloc] init];
    
    CGFloat bottomInset = 0.0f;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        bottomInset = 4.0f;
    else
        bottomInset = 14.0f;
    
    CGFloat currentHeight = bottomInset;
    int lastMessageDay = INT_MIN;
    
    int count = (int)items.count;
    int index = 0;
    
    bool lastCollapse = false;
    bool lastInsideUnreadRange = false;
    bool didAddUnreadHeader = false;
    
    bool unreadRangeIsEmpty = TGMessageRangeIsEmpty(unreadMessageRange);
    
    NSMutableDictionary *groupedLayouts = [[NSMutableDictionary alloc] init];
    
    int groupCollapseFlags = 0;
    int64_t lastGroupedId = 0;
    for (index = 0; index < count; index++)
    {
        TGMessageModernConversationItem *messageItem = items[index];
        
        if (!unreadRangeIsEmpty)
        {
            int messageDate = (int32_t)messageItem->_message.date;
            bool currentInsideUnreadRange = TGMessageRangeContains(unreadMessageRange, ABS(messageItem->_message.mid), messageDate);
            if (lastInsideUnreadRange && !currentInsideUnreadRange && !didAddUnreadHeader)
            {
                didAddUnreadHeader = true;
                currentHeight += addUnreadHeader(currentHeight, containerWidth, decorationViewAttributes);
                lastCollapse = false;
            }
            
            lastInsideUnreadRange = currentInsideUnreadRange;
        }
        
        int currentMessageDay = (((int)messageItem->_message.date) + dateOffset) / (24 * 60 * 60);
        if (messageItem->_message.hole != nil || messageItem->_message.group != nil) {
            for (int nextIndex = index + 1; nextIndex < count; nextIndex++) {
                TGMessage *message = ((TGMessageModernConversationItem *)items[nextIndex])->_message;
                if (message.hole == nil && message.group == nil) {
                    currentMessageDay = (((int)message.date) + dateOffset) / (24 * 60 * 60);
                    break;
                }
            }
        }
        if (lastMessageDay != INT_MIN && currentMessageDay != lastMessageDay)
            currentHeight += addDate(currentHeight, containerWidth, lastMessageDay, decorationViewAttributes);
        lastMessageDay = currentMessageDay;
        
        int collapseFlags = 0;
        if (lastCollapse)
            collapseFlags |= TGModernConversationItemCollapseBottom;
        
        int64_t groupedId = messageItem->_message.groupedId;
        if (groupedId != lastGroupedId)
        {
            if (groupedId != 0)
            {
                for (int i = index + 1; i < count; i++)
                {
                    TGMessageModernConversationItem *nextItem = items[index + 1];
                    if (nextItem->_message.groupedId != groupedId)
                    {
                        int nextMessageDay = (((int)nextItem->_message.date) + dateOffset) / (24 * 60 * 60);
                        if (lastMessageDay != INT_MIN && nextMessageDay != lastMessageDay)
                            lastCollapse = false;
                        else
                        {
                            lastCollapse = [nextItem collapseWithItem:messageItem forContainerSize:CGSizeMake(containerWidth, 0.0f)];
                            if (lastCollapse && !unreadRangeIsEmpty)
                            {
                                int nextMessageDate = (int32_t)nextItem->_message.date;
                                bool nextInsideUnreadRange = TGMessageRangeContains(unreadMessageRange, nextItem->_message.mid, nextMessageDate);
                                if (lastInsideUnreadRange && !nextInsideUnreadRange)
                                    lastCollapse = false;
                            }
                        }
                        
                        if (lastCollapse)
                            collapseFlags |= TGModernConversationItemCollapseTop;
                        
                        break;
                    }
                }
                
                groupCollapseFlags = collapseFlags;
            }
            else
            {
                groupCollapseFlags = 0;
            }
            
            lastGroupedId = groupedId;
        }
        else
        {
            if (index + 1 < count)
            {
                TGMessageModernConversationItem *nextItem = items[index + 1];
                
                int nextMessageDay = (((int)nextItem->_message.date) + dateOffset) / (24 * 60 * 60);
                if (lastMessageDay != INT_MIN && nextMessageDay != lastMessageDay)
                    lastCollapse = false;
                else
                {
                    lastCollapse = [nextItem collapseWithItem:messageItem forContainerSize:CGSizeMake(containerWidth, 0.0f)];
                    if (lastCollapse && !unreadRangeIsEmpty)
                    {
                        int nextMessageDate = (int32_t)nextItem->_message.date;
                        bool nextInsideUnreadRange = TGMessageRangeContains(unreadMessageRange, nextItem->_message.mid, nextMessageDate);
                        if (lastInsideUnreadRange && !nextInsideUnreadRange)
                            lastCollapse = false;
                    }
                }
                
                if (lastCollapse)
                    collapseFlags |= TGModernConversationItemCollapseTop;
            }
        }
        
        CGSize itemSize = CGSizeZero;
        CGFloat groupHeight = 0.0f;
        if (groupedId != 0)
        {
            TGMessageGroupedLayout *groupedLayout = groupedLayouts[@(groupedId)];
            if (groupedLayout == nil)
            {
                NSMutableArray *groupedMessages = [[NSMutableArray alloc] initWithObjects:messageItem->_message, nil];
                for (int groupIndex = index + 1; groupIndex < count; groupIndex++)
                {
                    TGMessageModernConversationItem *groupItem = items[groupIndex];
                    if (groupItem->_message.groupedId != groupedId)
                        break;
                    
                    [groupedMessages insertObject:groupItem->_message atIndex:0];
                }
                
                if (groupedMessages.count > 1 && groupedMessages.count <= 10)
                {
                    TGMessageGroupedLayout *cachedGroupedLayout = cachedGroupedLayouts[@(groupedId)];
                    if (cachedGroupedLayout == nil || cachedGroupedLayout.count != groupedMessages.count || [cachedGroupedLayout positionForMessageId:messageItem->_message.mid] == 0)
                    {
                        
                        bool larger = (TGPeerIdIsUser(messageItem->_message.cid) || [messageItem.currentAuthorPeer isKindOfClass:[TGConversation class]]) && messageItem->_message.cid != TGTelegraphInstance.clientUserId;
                        groupedLayout = [[TGMessageGroupedLayout alloc] initWithMessages:groupedMessages larger:larger];
                        groupedLayouts[@(groupedId)] = groupedLayout;
                        
                        cachedGroupedLayouts[@(groupedId)] = groupedLayout;
                    }
                    else
                    {
                        groupedLayout = cachedGroupedLayout;
                        groupedLayouts[@(groupedId)] = groupedLayout;
                    }
                }
                else
                {
                    groupedId = 0;
                }
            }
            
            if (groupedLayout != nil)
            {
                messageItem.collapseFlags = groupCollapseFlags;
                [messageItem updateGroupedLayout:groupedLayout];
                
                itemSize = [messageItem sizeForContainerSize:CGSizeMake(containerWidth, 0.0f) viewStorage:viewStorage];
                
                TGMessageGroupPositionFlags position = [groupedLayout positionForMessageId:messageItem->_message.mid];
                if (position & TGMessageGroupPositionTop && position & TGMessageGroupPositionLeft)
                    groupHeight = itemSize.height;
            }
            else
            {
                messageItem.collapseFlags = collapseFlags;
                [messageItem updateGroupedLayout:nil];
                
                itemSize = [messageItem sizeForContainerSize:CGSizeMake(containerWidth, 0.0f) viewStorage:viewStorage];
            }
        }
        else
        {
            messageItem.collapseFlags = collapseFlags;
            itemSize = [messageItem sizeForContainerSize:CGSizeMake(containerWidth, 0.0f) viewStorage:viewStorage];
        }
        
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        attributes.frame = CGRectMake(0, currentHeight, itemSize.width, itemSize.height);
        attributes.zIndex = NSIntegerMax - index;
        [layoutAttributes addObject:attributes];
        
        if (groupedId == 0)
            currentHeight += itemSize.height;
        else if (groupHeight > FLT_EPSILON)
            currentHeight += groupHeight;
        
        if (currentHeight >= maxHeight)
            break;
    }
    
    if (lastMessageDay != INT_MIN && index == (int)items.count)
        currentHeight += addDate(currentHeight, containerWidth, lastMessageDay, decorationViewAttributes);
    
    if (lastInsideUnreadRange)
        currentHeight += addUnreadHeader(currentHeight, containerWidth, decorationViewAttributes);
    
    currentHeight += 4.0f;
    
    if (contentHeight != NULL)
        *contentHeight = currentHeight;
    
    return layoutAttributes;
}

- (bool)hasLayoutAttributes
{
    return _contentSize.height > FLT_EPSILON;
}

- (void)prepareLayout
{
    [_layoutAttributes removeAllObjects];
    _decorationViewAttributes.clear();
    
    __block CGFloat contentHeight = 0.0f;
    dispatch_block_t block = ^
    {
        [_layoutAttributes addObjectsFromArray:[self layoutAttributesForItems:[(id<TGModernConversationViewLayoutDelegate>)self.collectionView.delegate items] containerWidth:self.collectionView.bounds.size.width maxHeight:FLT_MAX decorationViewAttributes:&_decorationViewAttributes contentHeight:&contentHeight viewStorage:_viewStorage]];
    };
    
    if (_animateLayout)
    {
        [UIView animateWithDuration:0.3 * 0.7 delay:0 options:0 animations:^
        {
            block();
        } completion:nil];
    }
    else
        block();
    
    _contentSize = CGSizeMake(self.collectionView.bounds.size.width, contentHeight);
    std::sort(_decorationViewAttributes.begin(), _decorationViewAttributes.end(), TGDecorationViewAttrubutesComparator());
}

- (CGSize)collectionViewContentSize
{
    return _contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (UICollectionViewLayoutAttributes *attributes in _layoutAttributes)
    {
        if (!CGRectIsNull(CGRectIntersection(rect, attributes.frame)))
            [array addObject:attributes];
    }
    
    return array;
}

- (std::vector<TGDecorationViewAttrubutes> *)allDecorationViewAttributes
{
    return &_decorationViewAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= (int)_layoutAttributes.count)
        return nil;
    
    return _layoutAttributes[indexPath.row];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)__unused newBounds
{
    return false;
}

@end
