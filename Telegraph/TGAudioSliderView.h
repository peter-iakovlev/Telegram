/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernView.h"

#import <SSignalKit/SSignalKit.h>

@class TGAudioSliderView;
@class TGMusicPlayerStatus;

typedef enum
{
    TGAudioSliderViewStyleOutgoing,
    TGAudioSliderViewStyleIncoming,
    TGAudioSliderViewStyleNotification
} TGAudioSliderViewStyle;

@protocol TGAudioSliderViewDelegate <NSObject>

@optional

- (void)audioSliderViewDidBeginPositionAdjustment:(TGAudioSliderView *)audioSliderView;
- (void)audioSliderViewDidEndPositionAdjustment:(TGAudioSliderView *)audioSliderView atPosition:(CGFloat)position smallChange:(bool)smallChange;
- (void)audioSliderViewDidCancelPositionAdjustment:(TGAudioSliderView *)audioSliderView;

@end

@interface TGAudioSliderView : UIView <TGModernView>

@property (nonatomic, weak) id<TGAudioSliderViewDelegate> delegate;

@property (nonatomic) TGAudioSliderViewStyle style;
@property (nonatomic) int32_t duration;
@property (nonatomic) bool manualPositionAdjustmentEnabled;
@property (nonatomic) bool listenedStatus;

- (void)setStatus:(TGMusicPlayerStatus *)status;
- (void)setWaveformSignal:(SSignal *)waveformSignal;

@end
