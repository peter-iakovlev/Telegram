/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

typedef enum {
    TGLabelVericalAlignmentCenter = 0,
    TGLabelVericalAlignmentTop = 1
} TGLabelVericalAlignment;

@interface TGLabel : UILabel

@property (nonatomic, strong) NSString *reuseIdentifier;

@property (nonatomic, strong) UIColor *normalShadowColor;
@property (nonatomic, strong) UIColor *highlightedShadowColor;

@property (nonatomic, strong) UIFont *portraitFont;
@property (nonatomic, strong) UIFont *landscapeFont;

@property (nonatomic, strong) UIColor *persistentBackgroundColor;

@property (nonatomic) TGLabelVericalAlignment verticalAlignment;
@property (nonatomic) float verticalOffset;
@property (nonatomic) float verticalOffsetMultiplier;

@property (nonatomic) CGPoint customDrawingOffset;
@property (nonatomic) CGSize customDrawingSize;

- (void)setLandscape:(bool)landscape;

@end
