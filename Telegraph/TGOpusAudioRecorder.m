/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGOpusAudioRecorder.h"

#import "TGAppDelegate.h"

#import "ASQueue.h"
#import "ActionStage.h"

#import "TGLiveUploadActor.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioUnit/AudioUnit.h>

#import "opus.h"
#import "opusenc.h"

#import "TGDataItem.h"

#import "TGAudioSessionManager.h"

#import "TGAudioWaveform.h"

#import "TGTelegramNetworking.h"

#define kOutputBus 0
#define kInputBus 1
static const int TGOpusAudioPlayerSampleRate = 48000; // libopusfile is bound to use 48 kHz

static const int TGOpusAudioRecorderSampleRate = 16000;

typedef struct
{
    AudioComponentInstance audioUnit;
    bool audioUnitStarted;
    bool audioUnitInitialized;
    
    AudioComponentInstance playbackUnit;
    bool playbackUnitStarted;
    bool playbackUnitInitialized;
    
    int globalAudioRecorderId;
} TGOpusAudioRecorderContext;

static NSData *toneAudioBuffer;
static int64_t toneAudioOffset;

static TGOpusAudioRecorderContext globalRecorderContext = { .audioUnit = NULL, .audioUnitStarted = false, .audioUnitInitialized = false, .playbackUnit = NULL, .playbackUnitStarted = false, .playbackUnitInitialized = false, .globalAudioRecorderId = -1};
static __weak TGOpusAudioRecorder *globalRecorder = nil;

static dispatch_semaphore_t playSoundSemaphore = nil;

@interface TGOpusAudioRecorder () <ASWatcher>
{
    TGDataItem *_tempFileItem;
    
    TGOggOpusWriter *_oggWriter;
    
    NSMutableData *_audioBuffer;
    
    NSString *_liveUploadPath;
    
    SMetaDisposable *_currentAudioSession;
    
    bool _recording;
    bool _waitForTone;
    NSTimeInterval _waitForToneStart;
    bool _stopped;
    
    NSMutableData *_waveformSamples;
    int16_t _waveformPeak;
    int _waveformPeakCount;
    
    int16_t _micLevelPeak;
    int _micLevelPeakCount;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@property (nonatomic) int recorderId;

@end

@implementation TGOpusAudioRecorder

- (instancetype)initWithFileEncryption:(bool)fileEncryption
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        
        _tempFileItem = [[TGDataItem alloc] initWithTempFile];
        
        _currentAudioSession = [[SMetaDisposable alloc] init];
        
        _waveformSamples = [[NSMutableData alloc] init];
        
        [[TGOpusAudioRecorder processingQueue] dispatchOnQueue:^
        {
            static int nextRecorderId = 1;
            _recorderId = nextRecorderId++;
            globalRecorderContext.globalAudioRecorderId = _recorderId;
            
            globalRecorder = self;
            
            static int nextActionId = 0;
            int actionId = nextActionId++;
            _liveUploadPath = [[NSString alloc] initWithFormat:@"/tg/liveUpload/(%d)", actionId];
            
            [ActionStageInstance() requestActor:_liveUploadPath options:@{
                @"fileItem": _tempFileItem,
                @"encryptFile": @(fileEncryption),
                @"mediaTypeTag": @(TGNetworkMediaTypeTagAudio)
            } flags:0 watcher:self];
        }];
    }
    return self;
}

- (void)dealloc
{
    [ActionStageInstance() removeWatcher:self];
    
    [self cleanup];
}

+ (ASQueue *)processingQueue
{
    static ASQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        queue = [[ASQueue alloc] initWithName:"org.telegram.opusAudioRecorderQueue"];
    });
    
    return queue;
}

- (void)cleanup
{
    [self cleanup:true];
}

- (void)cleanup:(bool)endAudioSession
{
    intptr_t objectId = (intptr_t)self;
    int recorderId = _recorderId;
    
    globalRecorder = nil;
    
    _oggWriter = nil;
    
    [[TGOpusAudioRecorder processingQueue] dispatchOnQueue:^
    {
        if (globalRecorderContext.globalAudioRecorderId == recorderId)
        {
            globalRecorderContext.globalAudioRecorderId++;
            
            if (globalRecorderContext.audioUnitStarted && globalRecorderContext.audioUnit != NULL)
            {
                OSStatus status = noErr;
                status = AudioOutputUnitStop(globalRecorderContext.audioUnit);
                if (status != noErr)
                    TGLog(@"[TGOpusAudioRecorder#%x AudioOutputUnitStop failed: %d]", objectId, (int)status);
                
                globalRecorderContext.audioUnitStarted = false;
            }
            
            if (globalRecorderContext.audioUnit != NULL)
            {
                OSStatus status = noErr;
                status = AudioComponentInstanceDispose(globalRecorderContext.audioUnit);
                if (status != noErr)
                    TGLog(@"[TGOpusAudioRecorder#%x AudioComponentInstanceDispose failed: %d]", objectId, (int)status);
                
                globalRecorderContext.audioUnit = NULL;
            }
            
            if (globalRecorderContext.playbackUnitStarted && globalRecorderContext.playbackUnit != NULL)
            {
                OSStatus status = noErr;
                status = AudioOutputUnitStop(globalRecorderContext.playbackUnit);
                if (status != noErr)
                    TGLog(@"[TGOpusAudioRecorder#%x playback AudioOutputUnitStop failed: %d]", objectId, (int)status);
                
                globalRecorderContext.playbackUnitStarted = false;
            }
            
            if (globalRecorderContext.playbackUnit != NULL)
            {
                OSStatus status = noErr;
                status = AudioComponentInstanceDispose(globalRecorderContext.playbackUnit);
                if (status != noErr)
                    TGLog(@"[TGOpusAudioRecorder#%x playback AudioComponentInstanceDispose failed: %d]", objectId, (int)status);
                
                globalRecorderContext.playbackUnit = NULL;
            }
        }
    }];
    
    if (endAudioSession)
        [self _endAudioSession];
}

- (void)_beginAudioSession:(bool)speaker
{
    [[TGOpusAudioRecorder processingQueue] dispatchOnQueue:^
    {
        __weak TGOpusAudioRecorder *weakSelf = self;
        [_currentAudioSession setDisposable:[[TGAudioSessionManager instance] requestSessionWithType:speaker ? TGAudioSessionTypePlayAndRecordHeadphones : TGAudioSessionTypePlayAndRecord interrupted:^
        {
            __strong TGOpusAudioRecorder *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                NSLog(@"_beginAudioSession completed");
                if (strongSelf->_pauseRecording) {
                    strongSelf->_pauseRecording();
                }
            }
        }]];
    } synchronous:true];
}

- (void)_endAudioSession
{
    id<SDisposable> currentAudioSession = _currentAudioSession;
    [[TGOpusAudioRecorder processingQueue] dispatchOnQueue:^
    {
        [currentAudioSession dispose];
    }];
}

- (void)prepareRecord:(bool)playTone completion:(void (^)())completion
{
    [[TGOpusAudioRecorder processingQueue] dispatchOnQueue:^
    {
        if (_stopped) {
            if (completion) {
                completion();
            }
            return;
        }
        //[self _beginAudioSession];
        
        AudioComponentDescription desc;
        desc.componentType = kAudioUnitType_Output;
        desc.componentSubType = kAudioUnitSubType_RemoteIO;
        desc.componentFlags = 0;
        desc.componentFlagsMask = 0;
        desc.componentManufacturer = kAudioUnitManufacturer_Apple;
        AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
        AudioComponentInstanceNew(inputComponent, &globalRecorderContext.audioUnit);
        
        OSStatus status = noErr;
        
        static const UInt32 one = 1;
        status = AudioUnitSetProperty(globalRecorderContext.audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &one, sizeof(one));
        if (status != noErr)
        {
            TGLog(@"[TGOpusAudioRecorder#%x AudioUnitSetProperty kAudioOutputUnitProperty_EnableIO failed: %d]", self, (int)status);
            [self cleanup];
            
            return;
        }
        
        AudioStreamBasicDescription inputAudioFormat;
        inputAudioFormat.mSampleRate = TGOpusAudioRecorderSampleRate;
        inputAudioFormat.mFormatID = kAudioFormatLinearPCM;
        inputAudioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        inputAudioFormat.mFramesPerPacket = 1;
        inputAudioFormat.mChannelsPerFrame = 1;
        inputAudioFormat.mBitsPerChannel = 16;
        inputAudioFormat.mBytesPerPacket = 2;
        inputAudioFormat.mBytesPerFrame = 2;
        status = AudioUnitSetProperty(globalRecorderContext.audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &inputAudioFormat, sizeof(inputAudioFormat));
        if (status != noErr)
        {
            TGLog(@"[TGOpusAudioRecorder#%x AudioUnitSetProperty kAudioUnitProperty_StreamFormat failed: %d]", self, (int)status);
            [self cleanup];
            
            return;
        }
        
        AudioStreamBasicDescription audioFormat;
        audioFormat.mSampleRate = TGOpusAudioRecorderSampleRate;
        audioFormat.mFormatID = kAudioFormatLinearPCM;
        audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        audioFormat.mFramesPerPacket = 1;
        audioFormat.mChannelsPerFrame = 1;
        audioFormat.mBitsPerChannel = 16;
        audioFormat.mBytesPerPacket = 2;
        audioFormat.mBytesPerFrame = 2;
        status = AudioUnitSetProperty(globalRecorderContext.audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &audioFormat, sizeof(audioFormat));
        if (status != noErr)
        {
            TGLog(@"[TGOpusAudioRecorder#%x AudioUnitSetProperty kAudioUnitProperty_StreamFormat failed: %d]", self, (int)status);
            [self cleanup];
            
            return;
        }
        
        AURenderCallbackStruct callbackStruct;
        callbackStruct.inputProc = &TGOpusRecordingCallback;
        callbackStruct.inputProcRefCon = (void *)(intptr_t)_recorderId;
        if (AudioUnitSetProperty(globalRecorderContext.audioUnit, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, 0, &callbackStruct, sizeof(callbackStruct)) != noErr)
        {
            TGLog(@"[TGOpusAudioRecorder#%x AudioUnitSetProperty kAudioOutputUnitProperty_SetInputCallback failed]", self);
            [self cleanup];
            
            return;
        }
        
        static const UInt32 zero = 0;
        if (AudioUnitSetProperty(globalRecorderContext.audioUnit, kAudioUnitProperty_ShouldAllocateBuffer, kAudioUnitScope_Output, 0, &zero, sizeof(zero)) != noErr)
        {
            TGLog(@"[TGOpusAudioRecorder#%x AudioUnitSetProperty kAudioUnitProperty_ShouldAllocateBuffer failed]", self);
            [self cleanup];
            
            return;
        }
        
        _oggWriter = [[TGOggOpusWriter alloc] init];
        if (![_oggWriter beginWithDataItem:_tempFileItem])
        {
            TGLog(@"[TGOpusAudioRecorder#%x error initializing ogg opus writer]", self);
            [self cleanup];
            
            return;
        }
        
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        
        status = AudioUnitInitialize(globalRecorderContext.audioUnit);
        if (status == noErr)
            globalRecorderContext.audioUnitInitialized = true;
        else
        {
            TGLog(@"[TGOpusAudioRecorder#%x AudioUnitInitialize failed: %d]", self, (int)status);
            [self cleanup];
            
            return;
        }
        
        TGLog(@"[TGOpusAudioRecorder#%x setup time: %f ms]", self, (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0);
        
        status = AudioOutputUnitStart(globalRecorderContext.audioUnit);
        if (status == noErr)
        {
            TGLog(@"[TGOpusAudioRecorder#%x initialization time: %f ms]", self, (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0);
            TGLog(@"[TGOpusAudioRecorder#%x started]", self);
            globalRecorderContext.audioUnitStarted = true;
        }
        else
        {
            TGLog(@"[TGOpusAudioRecorder#%x AudioOutputUnitStart failed: %d]", self, (int)status);
            [self cleanup];
            
            return;
        }
        
        if (playTone) {
            [self loadToneBuffer];
            _waitForTone = true;
            toneAudioOffset = 0;
            
            AudioComponentDescription desc;
            desc.componentType = kAudioUnitType_Output;
            desc.componentSubType = kAudioUnitSubType_RemoteIO;
            desc.componentFlags = 0;
            desc.componentFlagsMask = 0;
            desc.componentManufacturer = kAudioUnitManufacturer_Apple;
            AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
            AudioComponentInstanceNew(inputComponent, &globalRecorderContext.playbackUnit);
            
            OSStatus status = noErr;
            
            static const UInt32 one = 1;
            status = AudioUnitSetProperty(globalRecorderContext.playbackUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, kOutputBus, &one, sizeof(one));
            if (status != noErr)
            {
                TGLog(@"[TGOpusAudioPlayer#%x AudioUnitSetProperty kAudioOutputUnitProperty_EnableIO failed: %d]", self, (int)status);
                [self cleanup];
                
                return;
            }
            
            AudioStreamBasicDescription outputAudioFormat;
            outputAudioFormat.mSampleRate = TGOpusAudioPlayerSampleRate;
            outputAudioFormat.mFormatID = kAudioFormatLinearPCM;
            outputAudioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
            outputAudioFormat.mFramesPerPacket = 1;
            outputAudioFormat.mChannelsPerFrame = 1;
            outputAudioFormat.mBitsPerChannel = 16;
            outputAudioFormat.mBytesPerPacket = 2;
            outputAudioFormat.mBytesPerFrame = 2;
            status = AudioUnitSetProperty(globalRecorderContext.playbackUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, kOutputBus, &outputAudioFormat, sizeof(outputAudioFormat));
            if (status != noErr)
            {
                TGLog(@"[TGOpusAudioPlayer#%x playback AudioUnitSetProperty kAudioUnitProperty_StreamFormat failed: %d]", self, (int)status);
                [self cleanup];
                
                return;
            }
            
            AURenderCallbackStruct callbackStruct;
            callbackStruct.inputProc = &TGOpusAudioPlayerCallback;
            callbackStruct.inputProcRefCon = (void *)(intptr_t)_recorderId;
            if (AudioUnitSetProperty(globalRecorderContext.playbackUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Global, kOutputBus, &callbackStruct, sizeof(callbackStruct)) != noErr)
            {
                TGLog(@"[TGOpusAudioPlayer#%x playback AudioUnitSetProperty kAudioUnitProperty_SetRenderCallback failed]", self);
                [self cleanup];
                
                return;
            }
            
            status = AudioUnitInitialize(globalRecorderContext.playbackUnit);
            if (status == noErr)
            {
                status = AudioOutputUnitStart(globalRecorderContext.playbackUnit);
                if (status != noErr)
                {
                    TGLog(@"[TGOpusAudioRecorder#%x playback AudioOutputUnitStart failed: %d]", self, (int)status);
                }
            } else {
                TGLog(@"[TGOpusAudioRecorder#%x playback AudioUnitInitialize failed: %d]", self, (int)status);
                [self cleanup];
            }
            
            _waitForToneStart = CACurrentMediaTime();
        }
        
        if (completion) {
            completion();
        }
    }];
}

- (void)loadToneBuffer {
    if (toneAudioBuffer != nil) {
        return;
    }
    
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                    [NSNumber numberWithFloat:48000.0], AVSampleRateKey,
                                    [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                    nil];
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[[NSBundle mainBundle] URLForResource:@"begin_record" withExtension: @"caf"] options:nil];
    if (asset == nil) {
        NSLog(@"asset is not defined!");
        return;
    }
    
    NSError *assetError = nil;
    AVAssetReader *iPodAssetReader = [AVAssetReader assetReaderWithAsset:asset error:&assetError];
    if (assetError) {
        NSLog (@"error: %@", assetError);
        return;
    }
    
    AVAssetReaderOutput *readerOutput = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:asset.tracks audioSettings:outputSettings];
    
    if (! [iPodAssetReader canAddOutput: readerOutput]) {
        NSLog (@"can't add reader output... die!");
        return;
    }
    
    // add output reader to reader
    [iPodAssetReader addOutput: readerOutput];
    
    if (! [iPodAssetReader startReading]) {
        NSLog(@"Unable to start reading!");
        return;
    }

    NSMutableData *data = [[NSMutableData alloc] init];
    while (iPodAssetReader.status == AVAssetReaderStatusReading) {
        // Check if the available buffer space is enough to hold at least one cycle of the sample data
        CMSampleBufferRef nextBuffer = [readerOutput copyNextSampleBuffer];
        
        if (nextBuffer) {
            AudioBufferList abl;
            CMBlockBufferRef blockBuffer = NULL;
            CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(nextBuffer, NULL, &abl, sizeof(abl), NULL, NULL, kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment, &blockBuffer);
            UInt64 size = CMSampleBufferGetTotalSampleSize(nextBuffer);
            if (size != 0) {
                [data appendBytes:abl.mBuffers[0].mData length:size];
            }
            
            CFRelease(nextBuffer);
            if (blockBuffer) {
                CFRelease(blockBuffer);
            }
        }
        else {
            break;
        }
    }
    
    toneAudioBuffer = data;
}

- (void)record {
    _recording = true;
}

static OSStatus TGOpusRecordingCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, __unused AudioBufferList *ioData)
{
    @autoreleasepool
    {
        if (globalRecorderContext.globalAudioRecorderId != (int)inRefCon)
            return noErr;
        
        AudioBuffer buffer;
        buffer.mNumberChannels = 1;
        buffer.mDataByteSize = inNumberFrames * 2;
        buffer.mData = malloc(inNumberFrames * 2);
        
        AudioBufferList bufferList;
        bufferList.mNumberBuffers = 1;
        bufferList.mBuffers[0] = buffer;
        OSStatus status = AudioUnitRender(globalRecorderContext.audioUnit, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, &bufferList);
        if (status == noErr)
        {
            [[TGOpusAudioRecorder processingQueue] dispatchOnQueue:^
            {
                TGOpusAudioRecorder *recorder = globalRecorder;
                if (recorder != nil && recorder.recorderId == (int)(intptr_t)inRefCon && recorder->_recording) {
                    
                    if (recorder->_waitForTone) {
                        if (CACurrentMediaTime() - recorder->_waitForToneStart > 0.44) {
                            [recorder _processBuffer:&buffer];
                        }
                    } else {
                        [recorder _processBuffer:&buffer];
                    }
                }
                
                free(buffer.mData);
            }];
        }
    }
    
    return noErr;
}

static OSStatus TGOpusAudioPlayerCallback(void *inRefCon, __unused AudioUnitRenderActionFlags *ioActionFlags, __unused const AudioTimeStamp *inTimeStamp, __unused UInt32 inBusNumber, __unused UInt32 inNumberFrames, AudioBufferList *ioData)
{
    if (globalRecorderContext.globalAudioRecorderId != (int)inRefCon)
        return noErr;
    
    for (int i = 0; i < (int)ioData->mNumberBuffers; i++)
    {
        AudioBuffer *buffer = &ioData->mBuffers[i];
        buffer->mNumberChannels = 1;
        
        int audioBytesToCopy = MAX(0, MIN((int)buffer->mDataByteSize, ((int)toneAudioBuffer.length) - (int)toneAudioOffset));
        if (audioBytesToCopy != 0) {
            memcpy(buffer->mData, toneAudioBuffer.bytes + (int)toneAudioOffset, audioBytesToCopy);
            toneAudioOffset += audioBytesToCopy;
        }
        
        int remainingBytes = ((int)buffer->mDataByteSize) - audioBytesToCopy;
        if (remainingBytes > 0) {
            memset(buffer->mData + buffer->mDataByteSize - remainingBytes, 0, remainingBytes);
        }
    }
    
    return noErr;
}

- (void)processWaveformPreview:(int16_t const *)samples count:(int)count {
    for (int i = 0; i < count; i++) {
        int16_t sample = samples[i];
        if (sample < 0) {
            sample = -sample;
        }
        
        if (_waveformPeak < sample) {
            _waveformPeak = sample;
        }
        _waveformPeakCount++;
        
        if (_waveformPeakCount >= 100) {
            [_waveformSamples appendBytes:&_waveformPeak length:2];
            _waveformPeak = 0;
            _waveformPeakCount = 0;
        }
        
        if (_micLevelPeak < sample) {
            _micLevelPeak = sample;
        }
        _micLevelPeakCount++;
        
        if (_micLevelPeakCount >= 1200) {
            if (_micLevel) {
                CGFloat level = (CGFloat)_micLevelPeak / 4000.0;
                _micLevel(level);
            }
            _micLevelPeak = 0;
            _micLevelPeakCount = 0;
        }
    }
}

- (void)_processBuffer:(AudioBuffer const *)buffer
{
    @autoreleasepool
    {
        if (_oggWriter == nil)
            return;
        
        static const int millisecondsPerPacket = 60;
        static const int encoderPacketSizeInBytes = TGOpusAudioRecorderSampleRate / 1000 * millisecondsPerPacket * 2;
        
        unsigned char currentEncoderPacket[encoderPacketSizeInBytes];
        
        int bufferOffset = 0;
        
        while (true)
        {
            int currentEncoderPacketSize = 0;
            
            while (currentEncoderPacketSize < encoderPacketSizeInBytes)
            {
                if (_audioBuffer.length != 0)
                {
                    int takenBytes = MIN((int)_audioBuffer.length, encoderPacketSizeInBytes - currentEncoderPacketSize);
                    if (takenBytes != 0)
                    {
                        memcpy(currentEncoderPacket + currentEncoderPacketSize, _audioBuffer.bytes, takenBytes);
                        [_audioBuffer replaceBytesInRange:NSMakeRange(0, takenBytes) withBytes:NULL length:0];
                        currentEncoderPacketSize += takenBytes;
                    }
                }
                else if (bufferOffset < (int)buffer->mDataByteSize)
                {
                    int takenBytes = MIN((int)buffer->mDataByteSize - bufferOffset, encoderPacketSizeInBytes - currentEncoderPacketSize);
                    if (takenBytes != 0)
                    {
                        memcpy(currentEncoderPacket + currentEncoderPacketSize, ((const char *)buffer->mData) + bufferOffset, takenBytes);
                        bufferOffset += takenBytes;
                        currentEncoderPacketSize += takenBytes;
                    }
                }
                else
                    break;
            }
            
            if (currentEncoderPacketSize < encoderPacketSizeInBytes)
            {
                if (_audioBuffer == nil)
                    _audioBuffer = [[NSMutableData alloc] initWithCapacity:encoderPacketSizeInBytes];
                [_audioBuffer appendBytes:currentEncoderPacket length:currentEncoderPacketSize];
                
                break;
            }
            else
            {
                NSUInteger previousBytesWritten = [_oggWriter encodedBytes];
                [self processWaveformPreview:(int16_t const *)currentEncoderPacket count:currentEncoderPacketSize / 2];
                [_oggWriter writeFrame:currentEncoderPacket frameByteCount:(NSUInteger)currentEncoderPacketSize];
                NSUInteger currentBytesWritten = [_oggWriter encodedBytes];
                if (currentBytesWritten != previousBytesWritten)
                {
                    [ActionStageInstance() dispatchOnStageQueue:^
                    {
                        TGLiveUploadActor *actor = (TGLiveUploadActor *)[ActionStageInstance() executingActorWithPath:_liveUploadPath];
                        [actor updateSize:currentBytesWritten];
                    }];
                }
            }
        }
    }
}

- (TGDataItem *)stopRecording:(NSTimeInterval *)recordedDuration liveData:(__autoreleasing TGLiveUploadActorData **)liveData waveform:(__autoreleasing TGAudioWaveform **)waveform
{
    _stopped = true;
    __block TGDataItem *dataItemResult = nil;
    __block NSTimeInterval durationResult = 0.0;
    
    __block NSUInteger totalBytes = 0;
    
    [[TGOpusAudioRecorder processingQueue] dispatchOnQueue:^
    {
        if (_oggWriter != nil && [_oggWriter writeFrame:NULL frameByteCount:0])
        {
            dataItemResult = _tempFileItem;
            durationResult = [_oggWriter encodedDuration];
            totalBytes = [_oggWriter encodedBytes];
        }
        
        [self cleanup:false];
    } synchronous:true];
    
    int16_t scaledSamples[100];
    memset(scaledSamples, 0, 100 * 2);
    int16_t *samples = _waveformSamples.mutableBytes;
    int count = (int)_waveformSamples.length / 2;
    for (int i = 0; i < count; i++) {
        int16_t sample = samples[i];
        int index = i * 100 / count;
        if (scaledSamples[index] < sample) {
            scaledSamples[index] = sample;
        }
    }
    
    int16_t peak = 0;
    int64_t sumSamples = 0;
    for (int i = 0; i < 100; i++) {
        int16_t sample = scaledSamples[i];
        if (peak < sample) {
            peak = sample;
        }
        sumSamples += peak;
    }
    uint16_t calculatedPeak = 0;
    calculatedPeak = (uint16_t)(sumSamples * 1.8f / 100);
    
    if (calculatedPeak < 2500) {
        calculatedPeak = 2500;
    }
    
    for (int i = 0; i < 100; i++) {
        uint16_t sample = (uint16_t)((int64_t)samples[i]);
        if (sample > calculatedPeak) {
            scaledSamples[i] = calculatedPeak;
        }
    }
    
    TGAudioWaveform *resultWaveform = [[TGAudioWaveform alloc] initWithSamples:[NSData dataWithBytes:scaledSamples length:100 * 2] peak:calculatedPeak];
    NSData *bitstream = [resultWaveform bitstream];
    resultWaveform = [[TGAudioWaveform alloc] initWithBitstream:bitstream bitsPerSample:5];
    
    if (recordedDuration != NULL)
        *recordedDuration = durationResult;
    
    if (waveform != NULL) {
        *waveform = resultWaveform;
    }
    
    if (liveData != NULL)
    {
        dispatch_sync([ActionStageInstance() globalStageDispatchQueue], ^
        {
            TGLiveUploadActor *actor = (TGLiveUploadActor *)[ActionStageInstance() executingActorWithPath:_liveUploadPath];
            *liveData = [actor finishRestOfFile:totalBytes];
        });
    }
    
    [[TGOpusAudioRecorder processingQueue] dispatchOnQueue:^
    {
        [self _endAudioSession];
    }];
    
    return dataItemResult;
}

- (NSTimeInterval)currentDuration
{
    return [_oggWriter encodedDuration];
}

@end
