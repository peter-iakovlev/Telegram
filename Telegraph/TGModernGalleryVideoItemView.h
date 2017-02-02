/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernGalleryItemView.h"

#import "TGModernGalleryZoomableItemView.h"

@class TGImageView;
@class AVPlayer;

@interface TGModernGalleryVideoItemView : TGModernGalleryItemView

@property (nonatomic, strong) TGImageView *imageView;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic) CGSize videoDimensions;

- (bool)shouldLoopVideo:(NSUInteger)currentLoopCount;

- (void)play;
- (void)loadAndPlay;
- (void)hidePlayButton;
- (void)stop;
- (void)stopForOutTransition;

- (void)_willPlay;

@end
