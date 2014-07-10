/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernGalleryItemView.h"

@class TGRemoteImageView;
@class AVPlayer;

@interface TGModernGalleryVideoItemView : TGModernGalleryItemView

@property (nonatomic, strong) TGRemoteImageView *imageView;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic) CGSize videoDimenstions;

- (bool)shouldLoopVideo:(NSUInteger)currentLoopCount;

@end
