/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernViewModel.h"

#import "TGModernViewContext.h"

extern CGFloat TGModernFlatteningViewModelTilingLimit;

@interface TGModernFlatteningViewModel : TGModernViewModel

@property (nonatomic, assign) bool allowSpecialUserInteraction;

- (id)initWithContext:(TGModernViewContext *)context;

- (void)setTiledMode:(bool)tiledMode;

- (void)animateWithSnapshot;

- (void)setNeedsSubmodelContentsUpdate;
- (bool)needsSubmodelContentsUpdate;
- (void)updateSubmodelContentsIfNeeded;
- (void)updateSubmodelContentsForVisibleRect:(CGRect)rect;

@end
