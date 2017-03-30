#import "TGShareSheetSharePeersItemView.h"

#import "TGModernButton.h"
#import "TGFont.h"
#import "TGImageUtils.h"

#import "TGShareSheetSharePeersLayout.h"
#import "TGModernMediaCollectionView.h"
#import "TGShareSheetSharePeersCell.h"
#import "TGShareSheetSharePeersCaptionView.h"

#import "TGChatListSignals.h"

#import "TGDatabase.h"

#import "TGSearchBar.h"

#import "TGGlobalMessageSearchSignals.h"
#import "TGChatSearchController.h"
#import "TGTelegraph.h"

#import "TGPeerIdAdapter.h"

#import "TGShareSheetView.h"

@interface TGShareSheetSharePeersItemView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TGSearchBarDelegate> {
    TGModernButton *_button;
    UIView *_buttonSeparator;
    
    TGSearchBar *_searchBar;
    //TGShareSheetSharePeersCaptionView *_captionView;
    
    UICollectionView *_collectionView;
    TGShareSheetSharePeersLayout *_layout;
    
    NSArray *_recentPeers;
    NSArray *_searchPeers;
    
    id<SDisposable> _chatList;
    NSSet *_selectedPeerIds;
    
    SMetaDisposable *_searchDisposable;
}

@end

@implementation TGShareSheetSharePeersItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _layout = [[TGShareSheetSharePeersLayout alloc] init];
        _layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _collectionView = [[TGModernMediaCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
        _collectionView.backgroundColor = nil;
        _collectionView.opaque = false;
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.showsVerticalScrollIndicator = false;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.delaysContentTouches = false;
        _collectionView.canCancelContentTouches = true;
        
        [_collectionView registerClass:[TGShareSheetSharePeersCell class] forCellWithReuseIdentifier:@"TGAttachmentSheetSharePeersCell"];
        [self addSubview:_collectionView];
        
        _buttonSeparator = [[UIView alloc] init];
        _buttonSeparator.backgroundColor = TGSeparatorColor();
        [self addSubview:_buttonSeparator];
        
        _button = [[TGModernButton alloc] init];
        _button.exclusiveTouch = true;
        [_button setTitleColor:TGAccentColor() forState:UIControlStateNormal];
        [_button setTitleColor:UIColorRGB(0x8e8e93) forState:UIControlStateDisabled];
        _button.titleLabel.font = TGSystemFontOfSize(20.0f + TGRetinaPixel);
        [_button addTarget:self action:@selector(_buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_button setHighlightImage:[TGShareSheetView selectionBackgroundWithFirst:false last:true]];
        _button.stretchHighlightImage = true;
        _button.highlighted = false;
        [self addSubview:_button];
        
        [_button setTitle:(_selectedPeerIds.count == 0 && _copyShareLink != nil) ? TGLocalized(@"ShareMenu.CopyShareLink") : TGLocalized(@"ShareMenu.Send") forState:UIControlStateNormal];
        _button.enabled = _selectedPeerIds.count != 0 || _copyShareLink != nil;
        
        _searchBar = [[TGSearchBar alloc] initWithFrame:CGRectZero style:TGSearchBarStyleLightAlwaysPlain];
        _searchBar.clipsToBounds = true;
        _searchBar.delegate = self;
        _searchBar.hidesCancelButton = true;
        [_searchBar setAlwaysExtended:false];
        _searchBar.placeholder = TGLocalized(@"Common.Search");
        [_searchBar sizeToFit];
        _searchBar.delayActivity = false;
        [self addSubview:_searchBar];
        
        __weak TGShareSheetSharePeersItemView *weakSelf = self;
        
        /*_captionView = [[TGShareSheetSharePeersCaptionView alloc] init];
        _captionView.heightChanged = ^(CGFloat height) {
            __strong TGShareSheetSharePeersItemView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf updateCaptionHeight:height];
            }
        };
        [self addSubview:_captionView];*/
        
        _chatList = [[[[TGChatListSignals chatListWithLimit:64] map:^id(NSArray<TGConversation *> *next) {
            __strong TGShareSheetSharePeersItemView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                return [strongSelf processedPeers:next];
            }
            return nil;
        }] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *next) {
            __strong TGShareSheetSharePeersItemView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf setPeers:next];
            }
        }];
        
        _searchDisposable = [[SMetaDisposable alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_chatList dispose];
    
    [_searchDisposable dispose];
}

- (CGFloat)preferredHeightForMaximumHeight:(CGFloat)maximumHeight {
    CGFloat maxHeight = 357.0f;
    
    return MIN(maxHeight, maximumHeight - 0.0f);
}

- (bool)followsKeyboard {
    return true;
}

- (void)updateCaptionHeight:(CGFloat)__unused captionHeight {
    [self setPreferredHeightNeedsUpdate];
}

- (NSArray<TGConversation *> *)processedPeers:(NSArray<TGConversation *> *)peers {
    NSMutableSet *existingPeerIds = [[NSMutableSet alloc] init];
    
    NSMutableArray *updatedPeers = [[NSMutableArray alloc] init];
    for (id peer in peers) {
        if ([peer isKindOfClass:[TGConversation class]]) {
            TGConversation *conversation = peer;
            if ([existingPeerIds containsObject:@(conversation.conversationId)]) {
                continue;
            }
            [existingPeerIds addObject:@(conversation.conversationId)];
            
            if (conversation.isChannel) {
                if (![conversation currentUserCanSendMessages]) {
                    continue;
                }
            }
            
            if (conversation.isEncrypted) {
                continue;
            }
            
            TGConversation *updatedConversation = [conversation copy];
            if (!conversation.isChat || conversation.isEncrypted) {
                int32_t userId = 0;
                if (conversation.isEncrypted)
                {
                    if (conversation.chatParticipants.chatParticipantUids.count != 0)
                        userId = [conversation.chatParticipants.chatParticipantUids[0] intValue];
                }
                else
                    userId = (int)conversation.conversationId;
                
                TGUser *user = [TGDatabaseInstance() loadUser:userId];
                if (user != nil) {
                    updatedConversation.additionalProperties = @{@"user": user};
                }
            }
            [updatedPeers addObject:updatedConversation];
        } else if ([peer isKindOfClass:[TGUser class]]) {
            TGUser *user = peer;
            if ([existingPeerIds containsObject:@(user.uid)]) {
                continue;
            }
            [existingPeerIds addObject:@(user.uid)];
            [updatedPeers addObject:user];
        }
    }
    
    return updatedPeers;
}

- (void)setPeers:(NSArray<TGConversation *> *)peers {
    _recentPeers = peers;
    if (_searchPeers == nil) {
        [_collectionView reloadData];
    }
}

- (void)setSearchPeers:(NSArray<TGConversation *> *)peers {
    if (_searchPeers != peers) {
        _searchPeers = peers;
        [_collectionView reloadData];
    }
}

- (void)layoutSubviews {
    CGFloat separatorHeight = TGScreenPixel;
    _buttonSeparator.frame = CGRectMake(0.0f, self.frame.size.height - 57.5f, self.frame.size.width, separatorHeight);
    _button.frame = CGRectMake(0.0f, self.frame.size.height - 57.5f, self.bounds.size.width, 57.5f);
    
    _searchBar.frame = CGRectMake(9.0f, 8.0f, self.bounds.size.width - 9.0f * 2.0f, [_searchBar baseHeight]);
    
    _collectionView.frame = CGRectMake(0.0f, 24.0f + 49.0f, self.bounds.size.width, self.frame.size.height - 57.5f - (24.0f + 49.0f));
}

- (CGSize)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)__unused indexPath
{
    return CGSizeMake(82.0f, 80.0f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout insetForSectionAtIndex:(NSInteger)__unused section
{
    return UIEdgeInsetsMake(4.0f, 5.0f, 0.0f, 5.0f);
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)__unused section
{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)__unused section
{
    return 23.0f;
}

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0)
        return _searchPeers != nil ? _searchPeers.count : _recentPeers.count;
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGShareSheetSharePeersCell *cell = (TGShareSheetSharePeersCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TGAttachmentSheetSharePeersCell" forIndexPath:indexPath];
    
    if (cell.toggleSelected == nil) {
        __weak TGShareSheetSharePeersItemView *weakSelf = self;
        cell.toggleSelected = ^(int64_t peerId) {
            __strong TGShareSheetSharePeersItemView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf togglePeerSelected:peerId];
            }
        };
    }
    
    id peer = nil;
    if (_searchPeers != nil) {
        peer = _searchPeers[indexPath.row];
    } else {
        peer = _recentPeers[indexPath.row];
    }
    [cell setPeer:peer];
    [cell updateSelectedPeerIds:_selectedPeerIds animated:false];
    return cell;
}

- (void)togglePeerSelected:(int64_t)peerId {
    if ([_selectedPeerIds containsObject:@(peerId)]) {
        NSMutableSet *updatedSelectedPeerIds = [[NSMutableSet alloc] initWithSet:_selectedPeerIds];
        [updatedSelectedPeerIds removeObject:@(peerId)];
        _selectedPeerIds = updatedSelectedPeerIds;
    } else {
        NSMutableSet *updatedSelectedPeerIds = [[NSMutableSet alloc] initWithSet:_selectedPeerIds];
        [updatedSelectedPeerIds addObject:@(peerId)];
        _selectedPeerIds = updatedSelectedPeerIds;
    }
    
    for (TGShareSheetSharePeersCell *cell in _collectionView.visibleCells) {
        [cell updateSelectedPeerIds:_selectedPeerIds animated:true];
    }
    
    [_button setTitle:(_selectedPeerIds.count == 0 && _copyShareLink != nil) ? TGLocalized(@"ShareMenu.CopyShareLink") : TGLocalized(@"ShareMenu.Send") forState:UIControlStateNormal];
    _button.enabled = _selectedPeerIds.count != 0 || _copyShareLink != nil;
}

- (void)_buttonPressed {
    if (_selectedPeerIds.count == 0) {
        if (_copyShareLink) {
            _copyShareLink();
        }
    } else {
        if (_shareWithCaption) {
            _shareWithCaption([_selectedPeerIds allObjects], nil);
        }
    }
}

- (void)searchBar:(TGSearchBar *)__unused searchBar willChangeHeight:(CGFloat)__unused newHeight {
}

- (void)searchBar:(UISearchBar *)__unused searchBar textDidChange:(NSString *)searchText {
    [_searchDisposable setDisposable:nil];
    if (searchText.length == 0) {
        [_searchBar setShowActivity:false];
        _searchPeers = nil;
        [_collectionView reloadData];
    } else {
        [_searchBar setShowActivity:true];
        
        __weak TGShareSheetSharePeersItemView *weakSelf = self;
        [_searchDisposable setDisposable:[[[[[TGGlobalMessageSearchSignals searchDialogs:searchText itemMapping:^id(id item) {
            if ([item isKindOfClass:[TGConversation class]])
            {
                TGConversation *conversation = item;
                if (conversation.isBroadcast)
                    return nil;
                
                [TGChatSearchController initializeDialogListData:conversation customUser:nil selfUser:[TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId]];
                return conversation;
            }
            else if ([item isKindOfClass:[TGUser class]])
            {
                return item;
            }
            return nil;
        }] takeLast] map:^id(NSArray<TGConversation *> *next) {
            __strong TGShareSheetSharePeersItemView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                return [strongSelf processedPeers:next];
            }
            return nil;
        }] deliverOn:[SQueue mainQueue]] startWithNext:^(id next) {
            __strong TGShareSheetSharePeersItemView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf setSearchPeers:next];
            }
        } completed:^{
            __strong TGShareSheetSharePeersItemView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf->_searchBar setShowActivity:false];
            }
        }]];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)__unused searchBar {
    [_searchBar setShowsCancelButton:true animated:true];
}

- (void)setCopyShareLink:(void (^)())copyShareLink {
    _copyShareLink = [copyShareLink copy];
    
    [_button setTitle:(_selectedPeerIds.count == 0 && _copyShareLink != nil) ? TGLocalized(@"ShareMenu.CopyShareLink") : TGLocalized(@"ShareMenu.Send") forState:UIControlStateNormal];
    _button.enabled = _selectedPeerIds.count != 0 || _copyShareLink != nil;
}

@end
