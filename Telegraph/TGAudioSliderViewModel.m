/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGAudioSliderViewModel.h"

#import "TGAudioSliderView.h"

@interface TGAudioSliderViewModel ()
{
}

@end

@implementation TGAudioSliderViewModel

- (Class)viewClass
{
    return [TGAudioSliderView class];
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    self.viewStateIdentifier = [[NSString alloc] initWithFormat:@"TGAudioSliderViewModel/%lld/%lld", _audioId, _localAudioId];
    
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    ((TGAudioSliderView *)self.boundView).viewStateIdentifier = self.viewStateIdentifier;
    
    ((TGAudioSliderView *)self.boundView).style = _incoming ? TGAudioSliderViewStyleIncoming : TGAudioSliderViewStyleOutgoing;
    ((TGAudioSliderView *)self.boundView).duration = _duration;
    [((TGAudioSliderView *)self.boundView) setStatus:_status];
    ((TGAudioSliderView *)self.boundView).manualPositionAdjustmentEnabled = _manualPositionAdjustmentEnabled;
    ((TGAudioSliderView *)self.boundView).listenedStatus = _listenedStatus;
    [((TGAudioSliderView *)self.boundView) setWaveformSignal:_waveformSignal];
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    [super unbindView:viewStorage];
}

- (void)setIncoming:(bool)incoming
{
    _incoming = incoming;
    
    ((TGAudioSliderView *)self.boundView).style = _incoming ? TGAudioSliderViewStyleIncoming : TGAudioSliderViewStyleOutgoing;
}

- (void)setDuration:(int32_t)duration
{
    _duration = duration;
    
    ((TGAudioSliderView *)self.boundView).duration = _duration;
}

- (void)setListenedStatus:(bool)listenedStatus
{
    _listenedStatus = listenedStatus;
    
    ((TGAudioSliderView *)self.boundView).listenedStatus = _listenedStatus;
}
- (void)setStatus:(TGMusicPlayerStatus *)status {
    _status = status;
    [((TGAudioSliderView *)self.boundView) setStatus:status];
}

- (void)setManualPositionAdjustmentEnabled:(bool)manualPositionAdjustmentEnabled
{
    _manualPositionAdjustmentEnabled = manualPositionAdjustmentEnabled;
    
    ((TGAudioSliderView *)self.boundView).manualPositionAdjustmentEnabled = _manualPositionAdjustmentEnabled;
}


- (void)setWaveformSignal:(SSignal *)waveformSignal {
    _waveformSignal = waveformSignal;
    [((TGAudioSliderView *)self.boundView) setWaveformSignal:waveformSignal];
}

@end
