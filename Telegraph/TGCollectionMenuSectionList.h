/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "TGCollectionMenuSection.h"

@interface TGCollectionMenuSectionList : NSObject

@property (nonatomic, readonly) NSArray *sections;

- (void)addSection:(TGCollectionMenuSection *)section;
- (void)insertSection:(TGCollectionMenuSection *)section atIndex:(NSUInteger)index;
- (void)deleteSection:(NSUInteger)section;
- (void)deleteSectionByReference:(TGCollectionMenuSection *)section;

- (void)addItemToSection:(NSUInteger)section item:(TGCollectionItem *)item;
- (void)insertItem:(TGCollectionItem *)item toSection:(NSUInteger)section atIndex:(NSUInteger)index;
- (void)deleteItemFromSection:(NSUInteger)section atIndex:(NSUInteger)index;
- (void)replaceItemInSection:(NSUInteger)section atIndex:(NSUInteger)index withItem:(TGCollectionItem *)item;

- (void)beginRecordingChanges;
- (bool)commitRecordedChanges:(UICollectionView *)collectionView;
- (bool)commitRecordedChanges:(UICollectionView *)collectionView additionalActions:(void (^)())additionalActions;

@end
