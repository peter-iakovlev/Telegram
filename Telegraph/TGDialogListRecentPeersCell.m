#import "TGDialogListRecentPeersCell.h"
#import "TGModernMediaCollectionView.h"

#import "TGShareSheetSharePeersLayout.h"

#import "TGShareSheetSharePeersCell.h"

#import <SSignalKit/SSignalKit.h>

#import "TGDialogListRecentPeers.h"

#import "TGUser.h"
#import "TGConversation.h"
#import "TGModernButton.h"
#import "TGFont.h"

@interface TGDialogListRecentPeersCell () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource> {
    NSArray *_recentPeers;
    NSDictionary *_unreadCounts;
    NSSet *_selectedPeerIds;
    
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *_collectionLayout;
    
    UIView *_headerBackground;
    UILabel *_headerLabel;
    TGModernButton *_expandButton;
}

@end

@implementation TGDialogListRecentPeersCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self != nil) {
        self.clipsToBounds = true;
        
        _unreadCounts = [[NSDictionary alloc] init];
        
        _headerBackground = [[UIView alloc] init];
        _headerBackground.backgroundColor = UIColorRGB(0xf7f7f7);
        [self addSubview:_headerBackground];
        
        _headerLabel = [[UILabel alloc] init];
        _headerLabel.backgroundColor = UIColorRGB(0xf7f7f7);
        _headerLabel.opaque = true;
        _headerLabel.textColor = UIColorRGB(0x8e8e93);
        _headerLabel.font = TGBoldSystemFontOfSize(12.0f);
        [self addSubview:_headerLabel];
        
        _expandButton = [[TGModernButton alloc] init];
        _expandButton.exclusiveTouch = true;
        [_expandButton setTitle:TGLocalized(@"DialogList.RecentPeersExpand") forState:UIControlStateNormal];
        [_expandButton setTitleColor:UIColorRGB(0x8f8f94)];
        _expandButton.titleLabel.font = TGSystemFontOfSize(12.0f);
        _expandButton.contentEdgeInsets = UIEdgeInsetsMake(5.0, 8.0f, 5.0f, 15.0f);
        [_expandButton sizeToFit];
        [_expandButton addTarget:self action:@selector(expandButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        //[self addSubview:_expandButton];
        
        _collectionLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_collectionLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.opaque = false;
        _collectionView.backgroundColor = nil;
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.showsVerticalScrollIndicator = false;
        [_collectionView registerClass:[TGShareSheetSharePeersCell class] forCellWithReuseIdentifier:@"TGShareSheetSharePeersCell"];
        [self addSubview:_collectionView];
    }
    return self;
}

- (void)dealloc {
}

- (void)setRecentPeers:(TGDialogListRecentPeers *)recentPeers unreadCounts:(NSDictionary *)unreadCounts {
    _unreadCounts = unreadCounts;
    [self setPeers:recentPeers.peers];
    _headerLabel.text = [recentPeers.title uppercaseString];
    [_headerLabel sizeToFit];
    [self setNeedsLayout];
}

- (void)setPeers:(NSArray<TGConversation *> *)peers {
    _recentPeers = peers;
    [_collectionView reloadData];
}

- (void)updateUnreadCounts:(NSDictionary *)unreadCounts
{
    NSMutableDictionary *updatedUnreadCounts = [_unreadCounts mutableCopy];
    [updatedUnreadCounts addEntriesFromDictionary:unreadCounts];
    _unreadCounts = updatedUnreadCounts;
    
    for (NSIndexPath *indexPath in _collectionView.indexPathsForVisibleItems)
    {
        TGShareSheetSharePeersCell *cell = (TGShareSheetSharePeersCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        if (cell == nil)
            continue;
        
        id item = _recentPeers[indexPath.item];
        int64_t peerId = 0;
        if ([item isKindOfClass:[TGConversation class]])
            peerId = ((TGConversation *)item).conversationId;
        else if ([item isKindOfClass:[TGUser class]])
            peerId = ((TGUser *)item).uid;
        
        [cell setUnreadCount:[_unreadCounts[@(peerId)] int32Value]];
    }
}

- (void)updateSelectedPeerIds:(NSArray *)peerIds {
    _selectedPeerIds = [NSSet setWithArray:peerIds];
    for (NSIndexPath *indexPath in _collectionView.indexPathsForVisibleItems)
    {
        TGShareSheetSharePeersCell *cell = (TGShareSheetSharePeersCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        if (cell == nil)
            continue;
        
        [cell updateSelectedPeerIds:_selectedPeerIds animated:false];
    }
}

+ (UIEdgeInsets)insets {
    return UIEdgeInsetsMake(8.0f, 9.0f, 5.0f, 9.0f);
}

+ (CGSize)itemSize {
    return CGSizeMake(70.0f, 80.0f);
}

+ (CGFloat)horizontalSpacing {
    return 4.0f;
}

+ (CGFloat)verticalSpacing {
    return 15.0f;
}

- (void)setExpanded:(bool)expanded {
    _expanded = expanded;
    
    CGRect previousFrame = _expandButton.frame;
    [_expandButton setTitle:expanded ? TGLocalized(@"DialogList.RecentPeersCollapse") : TGLocalized(@"DialogList.RecentPeersExpand") forState:UIControlStateNormal];
    [_expandButton sizeToFit];
    _expandButton.frame = CGRectOffset(previousFrame, previousFrame.size.width - _expandButton.frame.size.width, 0.0f);
    
    [self setNeedsLayout];
}

+ (NSInteger)maxRowCount:(bool)expanded {
    return expanded ? 3 : 1;
}

+ (CGFloat)heightForWidth:(CGFloat)width count:(NSInteger)count expanded:(bool)expanded {
    UIEdgeInsets insets = [TGDialogListRecentPeersCell insets];
    CGSize itemSize = [TGDialogListRecentPeersCell itemSize];
    CGFloat horizontalSpacing = [TGDialogListRecentPeersCell verticalSpacing];
    CGFloat verticalSpacing = [TGDialogListRecentPeersCell verticalSpacing];
    
    NSInteger columnCount = (NSInteger)((width - insets.left - insets.right + horizontalSpacing) / (itemSize.width + horizontalSpacing));
    NSInteger rowCount = MIN([self maxRowCount:expanded], count / columnCount + (count % columnCount == 0 ? 0 : 1));
    
    return 27.0f + rowCount * itemSize.height + MAX(0, rowCount - 1) * verticalSpacing + insets.top + insets.bottom;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    static Class separatorClass = nil;
    static dispatch_once_t onceToken2;
    dispatch_once(&onceToken2, ^{
        separatorClass = NSClassFromString(TGEncodeText(@"`VJUbcmfWjfxDfmmTfqbsbupsWjfx", -1));
    });
    for (UIView *subview in self.subviews) {
        if (subview.class == separatorClass) {
            CGRect frame = subview.frame;
            frame.size.width = self.bounds.size.width;
            frame.origin.x = 0.0f;

            if (!CGRectEqualToRect(subview.frame, frame)) {
                subview.frame = frame;
            }
            break;
        }
    }
    
    _headerBackground.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, 27.0f);
    _headerLabel.frame = CGRectMake(14.0f, 6.0f, _headerLabel.frame.size.width, _headerLabel.frame.size.height);
    _expandButton.frame = CGRectMake(self.frame.size.width - _expandButton.frame.size.width, 0.0f, _expandButton.frame.size.width, _expandButton.frame.size.height);
    
    _collectionView.frame = CGRectMake(0.0f, 27.0f, self.frame.size.width, self.frame.size.height - 27.0f);
    
    /*UIEdgeInsets insets = [TGDialogListRecentPeersCell insets];
    CGSize itemSize = [TGDialogListRecentPeersCell itemSize];
    CGFloat horizontalSpacing = [TGDialogListRecentPeersCell verticalSpacing];
    CGFloat verticalSpacing = [TGDialogListRecentPeersCell verticalSpacing];
    NSInteger maxRowCount = [TGDialogListRecentPeersCell maxRowCount:true];
    
    NSInteger columnCount = (NSInteger)((self.frame.size.width - insets.left - insets.right + horizontalSpacing) / (itemSize.width + horizontalSpacing));
    if (columnCount == 0) {
        return;
    }
    
    CGFloat adjustedHorizontalSpacing = CGFloor((self.frame.size.width - insets.left - insets.right - columnCount * itemSize.width) / (columnCount - 1));
    
    NSInteger maxPeerIndex = -1;
    for (NSInteger i = 0; i < (NSInteger)_recentPeers.count; i++) {
        NSInteger rowIndex = i / columnCount;
        if (rowIndex >= maxRowCount) {
            break;
        }
        
        maxPeerIndex = i;
        
        CGFloat columnOffset = insets.left + (i % columnCount) * (itemSize.width + adjustedHorizontalSpacing);
        CGFloat rowOffset = insets.top + 27.0f + (i / columnCount) * (itemSize.height + verticalSpacing);
        
        TGShareSheetSharePeersCell *cell = nil;
        if (i < (NSInteger)_peerViews.count) {
            cell = _peerViews[i];
        } else {
            cell = [[TGShareSheetSharePeersCell alloc] initWithFrame:CGRectMake(columnOffset, rowOffset, itemSize.width, itemSize.height)];
            [_peerViews addObject:cell];
            [self addSubview:cell];
        }
        if (cell.toggleSelected == nil) {
            __weak TGDialogListRecentPeersCell *weakSelf = self;
            cell.toggleSelected = ^(int64_t peerId) {
                __strong TGDialogListRecentPeersCell *strongSelf = weakSelf;
                if (strongSelf != nil && strongSelf.peerSelected) {
                    for (id peer in strongSelf->_recentPeers) {
                        int64_t currentPeerId = 0;
                        if ([peer isKindOfClass:[TGUser class]]) {
                            currentPeerId = ((TGUser *)peer).uid;
                        } else if ([peer isKindOfClass:[TGConversation class]]) {
                            currentPeerId = ((TGConversation *)peer).conversationId;
                        }
                        if (peerId == currentPeerId) {
                            strongSelf.peerSelected(peer);
                            break;
                        }
                    }
                }
            };
        }
        [cell setPeer:_recentPeers[i]];
        cell.frame = CGRectMake(columnOffset, rowOffset, itemSize.width, itemSize.height);
    }
    
    NSInteger count = (NSInteger)_recentPeers.count;
    NSInteger rowCount = MIN(maxRowCount, count / columnCount + (count % columnCount == 0 ? 0 : 1));
    _expandButton.hidden = !self.expanded && rowCount < 2;
    
    for (NSInteger i = (NSInteger)_peerViews.count - 1; i > maxPeerIndex; i--) {
        [_peerViews[i] removeFromSuperview];
        [_peerViews removeObjectAtIndex:i];
    }*/
}

- (void)expandButtonPressed {
    if (_toggleExpand) {
        _toggleExpand();
        self.expanded = !self.expanded;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)__unused collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return _recentPeers.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TGShareSheetSharePeersCell *cell = (TGShareSheetSharePeersCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TGShareSheetSharePeersCell" forIndexPath:indexPath];
    if (cell.toggleSelected == nil) {
        __weak TGDialogListRecentPeersCell *weakSelf = self;
        cell.toggleSelected = ^(int64_t peerId) {
            __strong TGDialogListRecentPeersCell *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf.peerSelected) {
                for (id peer in strongSelf->_recentPeers) {
                    int64_t currentPeerId = 0;
                    if ([peer isKindOfClass:[TGUser class]]) {
                        currentPeerId = ((TGUser *)peer).uid;
                    } else if ([peer isKindOfClass:[TGConversation class]]) {
                        currentPeerId = ((TGConversation *)peer).conversationId;
                    }
                    if (peerId == currentPeerId) {
                        strongSelf.peerSelected(peer);
                        break;
                    }
                }
            }
        };
        cell.longTap = ^(int64_t peerId) {
            __strong TGDialogListRecentPeersCell *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf.peerLongTap) {
                for (id peer in strongSelf->_recentPeers) {
                    int64_t currentPeerId = 0;
                    if ([peer isKindOfClass:[TGUser class]]) {
                        currentPeerId = ((TGUser *)peer).uid;
                    } else if ([peer isKindOfClass:[TGConversation class]]) {
                        currentPeerId = ((TGConversation *)peer).conversationId;
                    }
                    if (peerId == currentPeerId) {
                        strongSelf.peerLongTap(peer);
                        break;
                    }
                }
            }
        };
    }
    
    id item = _recentPeers[indexPath.item];
    int64_t peerId = 0;
    if ([item isKindOfClass:[TGConversation class]])
        peerId = ((TGConversation *)item).conversationId;
    else if ([item isKindOfClass:[TGUser class]])
        peerId = ((TGUser *)item).uid;
    
    [cell setPeer:item];
    [cell updateSelectedPeerIds:_selectedPeerIds animated:false];
    [cell setUnreadCount:[_unreadCounts[@(peerId)] int32Value]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout*)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)__unused indexPath {
    return CGSizeMake(70.0f, 80.0f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout insetForSectionAtIndex:(NSInteger)__unused section {
    return [TGDialogListRecentPeersCell insets];
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)__unused section {
    return [TGDialogListRecentPeersCell verticalSpacing];
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)__unused section {
    return [TGDialogListRecentPeersCell horizontalSpacing];
}

- (int64_t)peerAtPoint:(CGPoint)point frame:(CGRect *)frame {
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:[self convertPoint:point toView:_collectionView]];
    if (indexPath != nil) {
        TGShareSheetSharePeersCell *cell = (TGShareSheetSharePeersCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        if (cell != nil) {
            if (frame) {
                *frame = [self convertRect:cell.frame fromView:_collectionView];
            }
            return [cell peerId];
        }
    }
    return 0;
}

@end
