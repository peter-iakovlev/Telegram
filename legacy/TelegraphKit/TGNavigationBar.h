/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@class TGNavigationController;
@class TGMusicPlayerView;

@interface TGNavigationBar : UINavigationBar

@property (nonatomic, weak) TGNavigationController *navigationController;

@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, assign) CGFloat verticalOffset;
@property (nonatomic, weak) UIView *additionalView;

@property (nonatomic) bool keepAlpha;

- (id)initWithFrame:(CGRect)frame barStyle:(UIBarStyle)barStyle;

- (void)setHiddenState:(bool)hidden animated:(bool)animated;

- (bool)shouldAddBackdropBackground;
- (unsigned int)indexAboveBackdropBackground;

@property (nonatomic, assign) CGFloat musicPlayerOffset;
@property (nonatomic, strong) TGMusicPlayerView *musicPlayerView;
@property (nonatomic) bool minimizedMusicPlayer;

- (void)showMusicPlayerView:(bool)show animation:(void (^)())animation;

@end

@interface TGBlackNavigationBar : TGNavigationBar

@end

@interface TGWhiteNavigationBar : TGNavigationBar

@end

@interface TGTransparentNavigationBar : TGNavigationBar

@end
