/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@class TGModernViewStorage;

@protocol TGModernCollectionRelativeBoundsObserver <NSObject>

- (void)relativeBoundsUpdated:(id)cell bounds:(CGRect)bounds;

@end

@interface TGModernCollectionCell : UICollectionViewCell
{
    @public
    bool _needsRelativeBoundsUpdateNotifications;
}

@property (nonatomic, strong) id boundItem;

- (void)relativeBoundsUpdated:(CGRect)bounds;

- (void)setEditing:(bool)editing animated:(bool)animated viewStorage:(TGModernViewStorage *)viewStorage;

- (UIView *)contentViewForBinding;

@end
