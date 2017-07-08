/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernViewModel.h"

@interface TGModernButtonViewModel : TGModernViewModel

@property (nonatomic, copy) void (^pressed)();

@property (nonatomic, strong) UIImage *supplementaryIcon;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIImage *highlightedBackgroundImage;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *possibleTitles;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *highlightedImage;
@property (nonatomic) UIEdgeInsets extendedEdgeInsets;

@property (nonatomic) UIEdgeInsets titleInset;

@property (nonatomic) bool modernHighlight;
@property (nonatomic) bool displayProgress;

- (void)setDisplayProgress:(bool)displayProgress animated:(bool)animated;

@end
