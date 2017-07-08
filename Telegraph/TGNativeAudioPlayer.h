/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface TGNativeAudioPlayer : TGAudioPlayer

@property (nonatomic, readonly) AVPlayer *player;

- (instancetype)initWithPath:(NSString *)path music:(bool)music controlAudioSession:(bool)controlAudioSession;

@end
