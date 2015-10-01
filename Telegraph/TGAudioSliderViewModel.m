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
    bool _isPlaying;
    float _audioPosition;
    NSTimeInterval _audioPositionTimestamp;
}

@end

@implementation TGAudioSliderViewModel

- (Class)viewClass
{
    return [TGAudioSliderView class];
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    ((TGAudioSliderView *)self.boundView).incoming = _incoming;
    ((TGAudioSliderView *)self.boundView).duration = _duration;
    ((TGAudioSliderView *)self.boundView).audioDurationText = _audioDurationText;
    [((TGAudioSliderView *)self.boundView) setPreciseDuration:_preciseDuration];
    [((TGAudioSliderView *)self.boundView) setAudioPosition:_audioPosition animated:false timestamp:_audioPositionTimestamp isPlaying:_isPlaying immediate:true];
    ((TGAudioSliderView *)self.boundView).manualPositionAdjustmentEnabled = _manualPositionAdjustmentEnabled;
    ((TGAudioSliderView *)self.boundView).progressMode = _progressMode;
    ((TGAudioSliderView *)self.boundView).listenedStatus = _listenedStatus;
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    [((TGAudioSliderView *)self.boundView) stopAnimations];
    
    [super unbindView:viewStorage];
}

- (void)setIncoming:(bool)incoming
{
    _incoming = incoming;
    
    ((TGAudioSliderView *)self.boundView).incoming = _incoming;
}

- (void)setDuration:(NSTimeInterval)duration
{
    _duration = duration;
    
    ((TGAudioSliderView *)self.boundView).duration = _duration;
}

- (void)setListenedStatus:(bool)listenedStatus
{
    _listenedStatus = listenedStatus;
    
    ((TGAudioSliderView *)self.boundView).listenedStatus = _listenedStatus;
}

- (void)setAudioDurationText:(NSString *)audioDurationText
{
    _audioDurationText = audioDurationText;
    
    ((TGAudioSliderView *)self.boundView).audioDurationText = _audioDurationText;
}

- (void)setAudioPosition:(float)audioPosition animated:(bool)animated timestamp:(NSTimeInterval)timestamp isPlaying:(bool)isPlaying
{
    _audioPosition = audioPosition;
    _audioPositionTimestamp = timestamp;
    _isPlaying = isPlaying;
    
    [((TGAudioSliderView *)self.boundView) setAudioPosition:_audioPosition animated:animated timestamp:_audioPositionTimestamp isPlaying:_isPlaying immediate:false];
}

- (void)setPreciseDuration:(NSTimeInterval)preciseDuration
{
    _preciseDuration = preciseDuration;
    
    [((TGAudioSliderView *)self.boundView) setPreciseDuration:_preciseDuration];
}

- (void)setManualPositionAdjustmentEnabled:(bool)manualPositionAdjustmentEnabled
{
    _manualPositionAdjustmentEnabled = manualPositionAdjustmentEnabled;
    
    ((TGAudioSliderView *)self.boundView).manualPositionAdjustmentEnabled = _manualPositionAdjustmentEnabled;
}

- (void)setProgressMode:(bool)progressMode
{
    _progressMode = progressMode;
    
    ((TGAudioSliderView *)self.boundView).progressMode = _progressMode;
}

@end
