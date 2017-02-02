/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

@class TGAudioRecorder;
@class TGLiveUploadActorData;
@class TGDataItem;
@class TGAudioWaveform;

@protocol TGAudioRecorderDelegate <NSObject>

@optional

- (void)audioRecorderDidStartRecording:(TGAudioRecorder *)audioRecorder;

@end

@interface TGAudioRecorder : NSObject

@property (nonatomic, weak) id<TGAudioRecorderDelegate> delegate;
@property (nonatomic, copy) id (^requestActivityHolder)();
@property (nonatomic, copy) void (^pauseRecording)();
@property (nonatomic, copy) void (^micLevel)(CGFloat);

- (instancetype)initWithFileEncryption:(bool)fileEncryption;

- (void)startWithSpeaker:(bool)speaker completion:(void (^)())completion;
- (NSTimeInterval)currentDuration;
- (void)cancel;
- (void)finish:(void (^)(TGDataItem *, NSTimeInterval, TGLiveUploadActorData *, TGAudioWaveform *))completion;

@end
