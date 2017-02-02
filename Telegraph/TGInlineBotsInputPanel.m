#import "TGInlineBotsInputPanel.h"

#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGRecentContextBotsSignal.h"

#import "TGDatabase.h"

#import "TGInlineBotsSettingsCell.h"
#import "TGInlineBotsInputCell.h"

#import "TGHacks.h"

@interface TGInlineBotsInputPanel () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource> {
    UIView *_bottomSeparatorView;
    UIView *_contentView;
    
    TGUser *_currentBot;
    
    SMetaDisposable *_recentBotsDisposable;
    
    NSArray<TGUser *> *_users;
    TGUser *_temporaryUser;
    
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *_collectionLayout;
    
    CGFloat _barOffset;
}

@end

@implementation TGInlineBotsInputPanel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 45.0f)];
    if (self != nil) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = UIColorRGB(0xf7f7f7);
        UIView *topSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 1.0f / TGScreenScaling())];
        topSeparatorView.backgroundColor = UIColorRGB(0xcdccd3);
        topSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_contentView addSubview:topSeparatorView];
        [self addSubview:_contentView];
        
        _collectionLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_collectionLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = nil;
        _collectionView.opaque = false;
        _collectionView.showsVerticalScrollIndicator = false;
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.delaysContentTouches = false;
        [_collectionView registerClass:[TGInlineBotsSettingsCell class] forCellWithReuseIdentifier:@"TGInlineBotsSettingsCell"];
        [_collectionView registerClass:[TGInlineBotsInputCell class] forCellWithReuseIdentifier:@"TGInlineBotsInputCell"];
        [_contentView addSubview:_collectionView];
        
        _bottomSeparatorView = [[UIView alloc] init];
        _bottomSeparatorView.backgroundColor = UIColorRGB(0xcdccd3);
        [self addSubview:_bottomSeparatorView];
        
        self.clipsToBounds = true;
        
        _recentBotsDisposable = [[SMetaDisposable alloc] init];
        
        SSignal *recentBots = [[TGRecentContextBotsSignal recentBots] mapToSignal:^SSignal *(NSArray *userIds) {
            return [TGDatabaseInstance() modify:^id{
                NSMutableArray *users = [[NSMutableArray alloc] init];
                for (NSNumber *nUid in userIds) {
                    TGUser *user = [TGDatabaseInstance() loadUser:[nUid intValue]];
                    if (user != nil) {
                        [users addObject:user];
                    }
                }
                return users;
            }];
        }];
        __weak TGInlineBotsInputPanel *weakSelf = self;
        [_recentBotsDisposable setDisposable:[[recentBots deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *users) {
            __strong TGInlineBotsInputPanel *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf setUsers:users];
            }
        }]];
    }
    return self;
}

- (void)dealloc {
    [_recentBotsDisposable dispose];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat separatorHeight = 1.0f / TGScreenScaling();
    _bottomSeparatorView.frame = CGRectMake(0.0f, self.frame.size.height - separatorHeight, self.frame.size.width, separatorHeight);
    
    _contentView.frame = CGRectMake(0.0f, MIN(45.0, MAX(0.0, _barOffset)), self.frame.size.width, self.frame.size.height);
    _collectionView.frame = _contentView.bounds;
}

- (void)animateIn {
    _contentView.frame = CGRectOffset(self.bounds, 0.0f, self.bounds.size.height);
    [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^{
        _contentView.frame = self.bounds;
    } completion:nil];
}

- (void)animateOut:(void (^)())completion {
    [_recentBotsDisposable setDisposable:nil];
    [UIView animateWithDuration:0.15 delay:0.0 options:0 animations:^{
        _contentView.frame = CGRectOffset(self.bounds, 0.0f, self.bounds.size.height);
    } completion:^(__unused BOOL finished) {
        completion();
    }];
}

- (void)setUsers:(NSArray *)users {
    _users = users;
    
    [self updateCurrentBot:true];
    [_collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)__unused collectionView {
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else if (section == 1) {
        return _temporaryUser == nil ? 0 : 1;
    } else if (section == 2) {
        return _users.count;
    } else {
        return 0;
    }
}

- (CGSize)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout * )__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(41.0f, 45.0f);
    } else {
        return CGSizeMake(48.0f, 45.0f);
    }
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)__unused section {
    return 4.0f;
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)__unused section {
    return 0.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == 1) {
        return UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 4.0f);
    } else if (section == 2) {
        return UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 12.0f);
    }
    return UIEdgeInsetsZero;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TGInlineBotsSettingsCell *cell = (TGInlineBotsSettingsCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TGInlineBotsSettingsCell" forIndexPath:indexPath];
        __weak TGInlineBotsInputPanel *weakSelf = self;
        cell.pressed = ^{
            __strong TGInlineBotsInputPanel *strongSelf = weakSelf;
            if (strongSelf != nil) {
            }
        };
        return cell;
    } else if (indexPath.section == 1 || indexPath.section == 2) {
        TGInlineBotsInputCell *cell = (TGInlineBotsInputCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TGInlineBotsInputCell" forIndexPath:indexPath];
        
        TGUser *user = nil;
        if (indexPath.section == 1) {
            user = _temporaryUser;
        } else {
            user = _users[indexPath.item];
        }
        __weak TGInlineBotsInputPanel *weakSelf = self;
        cell.tapped = ^(TGUser *user) {
            __strong TGInlineBotsInputPanel *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf->_botSelected) {
                strongSelf->_botSelected(user);
            }
        };
        [cell setUser:user];
        [cell setFocused:_currentBot != nil && user.uid == _currentBot.uid animated:false];
        
        return cell;
    }
    return nil;
}

- (void)setCurrentBot:(TGUser *)currentBot {
    if (_currentBot.uid != currentBot.uid) {
        _currentBot = currentBot;
        
        [self updateCurrentBot:false];
    }
}

- (void)updateCurrentBot:(bool)willReload {
    bool hadUser = _temporaryUser != nil;
    if (_currentBot != nil) {
        bool found = false;
        for (TGUser *user in _users) {
            if (user.uid == _currentBot.uid) {
                found = true;
                break;
            }
        }
        if (found) {
            _temporaryUser = nil;
        } else {
            _temporaryUser = _currentBot;
        }
    } else {
        _temporaryUser = nil;
    }
    
    if (!willReload) {
        if (hadUser != (_temporaryUser != nil)) {
            @try {
                if (_temporaryUser != nil) {
                    NSMutableArray<NSArray *> *cellsWithFrames = [[NSMutableArray alloc] init];
                    for (UIView *cell in _collectionView.visibleCells) {
                        [cellsWithFrames addObject:@[cell, [NSValue valueWithCGRect:cell.frame]]];
                    }
                    if (iosMajorVersion() >= 7) {
                        [TGHacks setSecondaryAnimationDurationFactor:0.0f];
                    } else {
                        [TGHacks setAnimationDurationFactor:0.0f];
                    }
                    [_collectionView performBatchUpdates:^{
                        [_collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]]];
                    } completion:nil];
                    if (iosMajorVersion() >= 7) {
                        [TGHacks setSecondaryAnimationDurationFactor:1.0f];
                    } else {
                        [TGHacks setAnimationDurationFactor:1.0f];
                    }
                    
                    [_collectionView layoutSubviews];
                    NSMutableArray<NSArray *> *updatedCellsWithFrames = [[NSMutableArray alloc] init];
                    for (UIView *cell in _collectionView.visibleCells) {
                        for (NSArray *previous in cellsWithFrames) {
                            if (previous[0] == cell) {
                                [updatedCellsWithFrames addObject:@[cell, [NSValue valueWithCGRect:cell.frame]]];
                                cell.frame = ((NSValue *)previous[1]).CGRectValue;
                                [cell.layer removeAllAnimations];
                                break;
                            }
                        }
                    }
                    
                    [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^{
                        for (UIView *cell in _collectionView.visibleCells) {
                            for (NSArray *previous in updatedCellsWithFrames) {
                                if (previous[0] == cell) {
                                    cell.frame = ((NSValue *)previous[1]).CGRectValue;
                                    break;
                                }
                            }
                        }
                    } completion:nil];
                    
                    TGInlineBotsInputCell *cell = (TGInlineBotsInputCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
                    [cell setFocused:true animated:false];
                    [cell animateIn];
                } else {
                    TGInlineBotsInputCell *cell = (TGInlineBotsInputCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
                    [cell animateOut];
                    
                    if (iosMajorVersion() >= 7) {
                        [TGHacks setSecondaryAnimationDurationFactor:0.5f];
                        [TGHacks setForceSystemCurve:true];
                    }
                    else
                        [TGHacks setAnimationDurationFactor:0.5f];
                    [_collectionView performBatchUpdates:^{
                        [_collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]]];
                    } completion:nil];
                    if (iosMajorVersion() >= 7) {
                        [TGHacks setForceSystemCurve:false];
                        [TGHacks setSecondaryAnimationDurationFactor:1.0f];
                    }
                    else
                        [TGHacks setAnimationDurationFactor:1.0f];
                }
            } @catch(NSException *e) {
                TGLog(@"%@", e);
                
            }
        } else if (_temporaryUser != nil) {
            TGInlineBotsInputCell *cell = (TGInlineBotsInputCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
            if (cell != nil) {
                [cell setUser:_temporaryUser];
            }
        }
        
        [self updateFocusedBot:true];
    }
}

- (void)updateFocusedBot:(bool)animated {
    for (id cell in [_collectionView visibleCells]) {
        if ([cell isKindOfClass:[TGInlineBotsInputCell class]]) {
            TGInlineBotsInputCell *inputCell = cell;
            if (inputCell.user.uid != _currentBot.uid) {
                [cell setFocused:false animated:animated];
            }
        }
    }
    
    if (_currentBot.uid != 0) {
        if (_temporaryUser.uid == _currentBot.uid) {
            TGInlineBotsInputCell *cell = (TGInlineBotsInputCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
            [cell setFocused:true animated:animated];
            [_collectionView scrollRectToVisible:CGRectMake(0.0f, 0.0f, 1.0f, 1.0f) animated:true];
        } else {
            for (NSUInteger i = 0; i < _users.count; i++) {
                if (_users[i].uid == _currentBot.uid) {
                    TGInlineBotsInputCell *cell = (TGInlineBotsInputCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:2]];
                    [cell setFocused:true animated:animated];
                    UICollectionViewLayoutAttributes *attributes = [_collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:2]];
                    if (attributes != nil) {
                        CGRect frame = attributes.frame;
                        CGRect bounds = _collectionView.bounds;
                        CGFloat leftBound = MAX(0.0f, frame.origin.x - CGFloor(frame.size.width * 0.5f));
                        CGFloat rightBound = MAX(0.0f, MIN(_collectionView.contentSize.width, frame.origin.x + CGFloor(frame.size.width * 1.5f)) - bounds.size.width);
                        if (leftBound < bounds.origin.x) {
                            [_collectionView setContentOffset:CGPointMake(leftBound, 0.0f) animated:true];
                        } else if (rightBound > bounds.origin.x) {
                            [_collectionView setContentOffset:CGPointMake(rightBound, 0.0f) animated:true];
                        }
                    }
                    
                    //[_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:2] atScrollPosition:UICollectionViewScrollPositionNone animated:true];
                    
                    break;
                }
            }
        }
    }
}

- (void)setBarOffset:(CGFloat)barOffset {
    _barOffset = barOffset;
    _contentView.frame = CGRectMake(0.0f, MIN(45.0f, MAX(0.0f, _barOffset)), self.frame.size.width, self.frame.size.height);
}

@end
