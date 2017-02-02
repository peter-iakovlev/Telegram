/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGAudioRecorder.h"
#import "ASQueue.h"
#import "TGTimer.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "TGAppDelegate.h"

#import "TGAccessChecker.h"
#import "TGAlertView.h"

#define TGUseModernAudio true

#import "TGOpusAudioRecorder.h"

#import "TGDataItem.h"

#import "TGMusicPlayer.h"

@interface TGAudioRecorder () <AVAudioRecorderDelegate>
{
    TGTimer *_timer;
    bool _stopped;
    
    TGOpusAudioRecorder *_modernRecorder;
    AVAudioPlayer *_tonePlayer;
    id _activityHolder;
    
    SMetaDisposable *_activityDisposable;
}

@end

@implementation TGAudioRecorder

- (instancetype)initWithFileEncryption:(bool)fileEncryption
{
    self = [super init];
    if (self != nil)
    {
        _modernRecorder = [[TGOpusAudioRecorder alloc] initWithFileEncryption:fileEncryption];
        
        _activityDisposable = [[SMetaDisposable alloc] init];
        
        [[TGAudioRecorder audioRecorderQueue] dispatchOnQueue:^
        {
            __weak TGAudioRecorder *weakSelf = self;
            _modernRecorder.pauseRecording = ^{
                __strong TGAudioRecorder *strongSelf = weakSelf;
                if (strongSelf != nil && strongSelf->_pauseRecording) {
                    strongSelf->_pauseRecording();
                }
            };
        }];
    }
    return self;
}

- (void)dealloc
{
    [self cleanup];
    [_activityDisposable dispose];
}

- (void)setMicLevel:(void (^)(CGFloat))micLevel {
    _micLevel = [micLevel copy];
    _modernRecorder.micLevel = micLevel;
}

+ (ASQueue *)audioRecorderQueue
{
    static ASQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        queue = [[ASQueue alloc] initWithName:"org.telegram.audioRecorderQueue"];
    });
    return queue;
}

static NSMutableDictionary *recordTimers()
{
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        dict = [[NSMutableDictionary alloc] init];
    });
    
    return dict;
}

static int currentTimerId = 0;

static void playSoundCompleted(__unused SystemSoundID ssID, __unused void *clientData)
{
    int timerId = currentTimerId;
    TGTimer *timer = (TGTimer *)recordTimers()[@(timerId)];
    dispatch_block_t block = ^{
        if ([timer isScheduled]) {
            [timer fireAndInvalidate];
            TGLog(@"vibration completed");
        }
    };
    
    if (![TGViewController isWidescreen]) {
        TGDispatchAfter(0.2, [TGAudioRecorder audioRecorderQueue].nativeQueue, block);
    } else {
        block();
    }
}

- (void)startWithSpeaker:(bool)speaker1 completion:(void (^)())completion
{
    __weak TGAudioRecorder *weakSelf = self;
    [_activityDisposable setDisposable:[[[SSignal complete] delay:0.3 onQueue:[SQueue mainQueue]] startWithNext:nil error:nil completed:^{
        __strong TGAudioRecorder *strongSelf = weakSelf;
        if (strongSelf != nil && strongSelf->_requestActivityHolder) {
            strongSelf->_activityHolder = strongSelf->_requestActivityHolder();
        }
    }]];
    
    __unused static SystemSoundID soundId;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        /*NSString *path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"begin_record.caf"];
        NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:false];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundId);
        if (soundId != 0) {
            //AudioServicesAddSystemSoundCompletion(soundId, NULL, kCFRunLoopCommonModes, &playSoundCompleted, NULL);
        }*/
        AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, kCFRunLoopCommonModes, &playSoundCompleted, NULL);
    });
    
    TGLog(@"[TGAudioRecorder start]");
    
    [[TGAudioRecorder audioRecorderQueue] dispatchOnQueue:^
    {
        void (^recordBlock)(bool) = ^(bool granted)
        {
            if (granted)
            {
                [_timer invalidate];
                
                TGLog(@"[TGAudioRecorder initialized session]");
                
                if (!_stopped && completion) {
                    completion();
                }
                
                bool headphones = [TGMusicPlayer isHeadsetPluggedIn];
                bool speaker = headphones || speaker1;
                NSTimeInterval startTime = CACurrentMediaTime();
                [_modernRecorder _beginAudioSession:speaker];
                TGLog(@"AudioSession time: %f s", CACurrentMediaTime() - startTime);
                
                /*static int nextTimerId = 0;
                int timerId = nextTimerId++;
                NSTimeInterval timeout = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 0.5 : 1.0;
                __weak TGAudioRecorder *weakSelf = self;
                _timer = [[TGTimer alloc] initWithTimeout:timeout repeat:false completion:^
                {
                    TGLog(@"[TGAudioRecorder record]");
                    __strong TGAudioRecorder *strongSelf = weakSelf;

                    [strongSelf _commitRecord];
                } queue:[TGAudioRecorder audioRecorderQueue].nativeQueue];
                recordTimers()[@(timerId)] = strongSelf->_timer;
                [strongSelf->_timer start];
                
                [strongSelf->_modernRecorder _beginAudioSession:speaker];
                currentTimerId = timerId;
                if (!speaker) {
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                        [strongSelf->_timer fireAndInvalidate];
                    } else {
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    }
                } else {
                }
                
                [strongSelf->_timer fireAndInvalidate];*/
                
                [self _prepareRecord:speaker completion:nil];
                [self _commitRecord];
            }
            else
            {
                [TGAccessChecker checkMicrophoneAuthorizationStatusForIntent:TGMicrophoneAccessIntentVoice alertDismissCompletion:nil];
            }
        };
        
        if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)])
        {
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted)
            {
                TGDispatchOnMainThread(^
                {
                    recordBlock(granted);
                });
            }];
        }
        else
            recordBlock(true);
    }];
}

- (NSTimeInterval)currentDuration
{
    return [_modernRecorder currentDuration];
}

- (void)_prepareRecord:(bool)playTone completion:(void (^)())completion {
    [_modernRecorder prepareRecord:playTone completion:^{
        [[TGAudioRecorder audioRecorderQueue] dispatchOnQueue:^{
            if (completion) {
                completion();
            }
        }];
    }];
}

- (void)_commitRecord
{
    [_modernRecorder record];
    
    TGDispatchOnMainThread(^
    {
        id<TGAudioRecorderDelegate> delegate = _delegate;
        if ([delegate respondsToSelector:@selector(audioRecorderDidStartRecording:)])
            [delegate audioRecorderDidStartRecording:self];
    });
}

- (void)cleanup
{
    TGOpusAudioRecorder *modernRecorder = _modernRecorder;
    _modernRecorder = nil;
    
    TGTimer *timer = _timer;
    _timer = nil;
    
    [[TGAudioRecorder audioRecorderQueue] dispatchOnQueue:^
    {
        [timer invalidate];
        
        if (modernRecorder != nil)
            [modernRecorder stopRecording:NULL liveData:NULL waveform:NULL];
    }];
}

- (void)cancel
{
    [_activityDisposable dispose];
    _stopped = true;
    [[TGAudioRecorder audioRecorderQueue] dispatchOnQueue:^
    {
        [self cleanup];
    }];
}

- (void)finish:(void (^)(TGDataItem *, NSTimeInterval, TGLiveUploadActorData *, TGAudioWaveform *))completion
{
    [_activityDisposable dispose];
    _stopped = true;
    [[TGAudioRecorder audioRecorderQueue] dispatchOnQueue:^
    {
        TGDataItem *resultDataItem = nil;
        NSTimeInterval resultDuration = 0.0;
        TGAudioWaveform *resultWaveform = nil;
        __autoreleasing TGLiveUploadActorData *liveData = nil;
        
        if (_modernRecorder != nil)
        {
            NSTimeInterval recordedDuration = 0.0;
            TGAudioWaveform *waveform = nil;
            TGDataItem *dataItem = [_modernRecorder stopRecording:&recordedDuration liveData:&liveData waveform:&waveform];
            if (dataItem != nil && recordedDuration > 0.5)
            {
                resultDataItem = dataItem;
                resultDuration = recordedDuration;
                resultWaveform = waveform;
            }
        }
        
        if (completion != nil)
            completion(resultDataItem, resultDuration, liveData, resultWaveform);
    }];
}


@end
