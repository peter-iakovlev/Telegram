/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernViewModel.h"

#import <SSignalKit/SSignalKit.h>

@class TGMusicPlayerStatus;

@interface TGAudioSliderViewModel : TGModernViewModel

@property (nonatomic) int64_t audioId;
@property (nonatomic) int64_t localAudioId;
@property (nonatomic) bool incoming;
@property (nonatomic) int32_t duration;
@property (nonatomic) bool manualPositionAdjustmentEnabled;
@property (nonatomic) bool listenedStatus;
@property (nonatomic, strong) TGMusicPlayerStatus *status;

@property (nonatomic, strong) SSignal *waveformSignal;

@end
