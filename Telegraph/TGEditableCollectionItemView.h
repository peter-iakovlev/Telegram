/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCollectionItemView.h"

@class TGCollectionMenuView;

typedef enum {
    TGEditableCollectionItemViewIndicatorDelete,
    TGEditableCollectionItemViewIndicatorAdd
} TGEditableCollectionItemViewIndicator;

@interface TGEditableCollectionItemView : TGCollectionItemView

@property (nonatomic, readonly) UIView *editingContentView;

@property (nonatomic) TGEditableCollectionItemViewIndicator indicatorMode;
@property (nonatomic) bool showsDeleteIndicator;

@property (nonatomic) bool enableEditing;
@property (nonatomic, strong) NSString *optionText;

@property (nonatomic) CGPoint optionsOffset;

@property (nonatomic) bool disableControls;
@property (nonatomic, copy) void (^customOpenControls)();

- (void)setShowsDeleteIndicator:(bool)showsDeleteIndicator animated:(bool)animated;
- (void)setShowsEditingOptions:(bool)showsEditingOptions animated:(bool)animated;
- (void)setEnableEditing:(bool)enableEditing animated:(bool)animated;

- (void)deleteAction;

- (void)_requestSelection;

- (UIView *)hitTestDeleteIndicator:(CGPoint)point;

- (TGCollectionMenuView *)_collectionMenuView;

@end
