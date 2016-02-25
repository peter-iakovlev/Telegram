/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

@class TGLiveUploadActorData;
@class TGDataItem;
@class TGAudioWaveform;

@interface TGOpusAudioRecorder : NSObject

@property (nonatomic, copy) void (^pauseRecording)();
@property (nonatomic, copy) void (^micLevel)(CGFloat);

- (instancetype)initWithFileEncryption:(bool)fileEncryption;

- (void)_beginAudioSession:(bool)speaker;
- (void)prepareRecord:(bool)playTone completion:(void (^)())completion;
- (void)record;
- (TGDataItem *)stopRecording:(NSTimeInterval *)recordedDuration liveData:(__autoreleasing TGLiveUploadActorData **)liveData waveform:(__autoreleasing TGAudioWaveform **)waveform;
- (NSTimeInterval)currentDuration;

@end
