#import "PGCameraMovieWriter.h"

#import "TGImageUtils.h"
#import "TGPhotoEditorUtils.h"

#import <AVFoundation/AVFoundation.h>

NSString *const PGCameraReadyForMoreMediaData = @"readyForMoreMediaData";

@interface PGCameraMovieWriter ()
{
    AVAssetWriter *_assetWriter;
    AVAssetWriterInput *_videoInput;
    AVAssetWriterInput *_audioInput;

    bool _startedWriting;
    bool _finishedWriting;
    
    CGAffineTransform _videoTransform;
    NSDictionary *_videoOutputSettings;
    NSDictionary *_audioOutputSettings;
    
    CMTime _startTimeStamp;
    CMTime _lastVideoTimeStamp;
    CMTime _lastAudioTimeStamp;
}
@end

@implementation PGCameraMovieWriter

- (instancetype)initWithVideoTransform:(CGAffineTransform)videoTransform videoOutputSettings:(NSDictionary *)videoSettings audioOutputSettings:(NSDictionary *)audioSettings
{
    self = [super init];
    if (self != nil)
    {
        _videoTransform = videoTransform;
        _videoOutputSettings = videoSettings;
        _audioOutputSettings = audioSettings;
    }
    return self;
}

- (void)startRecording
{
    if (_isRecording || _finishedWriting)
        return;
    
    NSError *error = nil;
    
    NSString *path = [PGCameraMovieWriter tempOutputPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    
    _assetWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:path]
                                             fileType:[PGCameraMovieWriter outputFileType]
                                                error:&error];

    if (_assetWriter == nil && error != nil)
    {
        TGLog(@"ERROR: camera movie writer failed to initialize: %@", error);
        return;
    }
    
    _videoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:_videoOutputSettings];
    _videoInput.expectsMediaDataInRealTime = true;
    _videoInput.transform = _videoTransform;
    
    if ([_assetWriter canAddInput:_videoInput])
    {
        [_assetWriter addInput:_videoInput];
    }
    else
    {
        TGLog(@"ERROR: camera movie writer failed to add video input");
        return;
    }
    
    _audioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:_audioOutputSettings];
    _audioInput.expectsMediaDataInRealTime = true;
    
    if ([_assetWriter canAddInput:_audioInput])
    {
        [_assetWriter addInput:_audioInput];
    }
    else
    {
        TGLog(@"ERROR: camera movie writer failed to add audio input");
        return;
    }
    
    _isRecording = true;
}

- (void)stopRecordingWithCompletion:(void (^)(void))completion
{
    _isRecording = false;
    
    if (_assetWriter.status > AVAssetWriterStatusCompleted)
    {
        if (self.finishedWithMovieAtURL != nil)
            self.finishedWithMovieAtURL(_assetWriter.outputURL, CGAffineTransformIdentity, CGSizeZero, 0.0, false);
        TGLog(@"ERROR: camera movie writer failed to write movie: %@", _assetWriter.error);
        
        return;
    }
    
    __weak PGCameraMovieWriter *weakSelf = self;
    [_assetWriter finishWritingWithCompletionHandler:^
    {
        __strong PGCameraMovieWriter *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_finishedWriting = true;
        
        TGDispatchOnMainThread(^
        {
            if (strongSelf->_assetWriter.status == AVAssetWriterStatusCompleted)
            {
                if (strongSelf.finishedWithMovieAtURL != nil)
                {
                    CGSize dimensions = CGSizeMake([strongSelf->_videoOutputSettings[AVVideoWidthKey] floatValue], [strongSelf->_videoOutputSettings[AVVideoHeightKey] floatValue]);
                    dimensions = TGTransformDimensionsWithTransform(dimensions, strongSelf->_videoTransform);
                    strongSelf.finishedWithMovieAtURL(strongSelf->_assetWriter.outputURL, strongSelf->_videoTransform, dimensions, strongSelf.currentDuration, true);
                }
            }
            else
            {
                if (strongSelf.finishedWithMovieAtURL != nil)
                    strongSelf.finishedWithMovieAtURL(strongSelf->_assetWriter.outputURL, CGAffineTransformIdentity, CGSizeZero, 0.0, false);
                TGLog(@"ERROR: camera movie writer failed to write movie: %@", strongSelf->_assetWriter.error);
            }
            
            strongSelf->_assetWriter = nil;
            
            if (completion != nil)
                completion();
        });
    }];
}

- (void)_processSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    if (!_isRecording)
        return;
    
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    CMMediaType mediaType = CMFormatDescriptionGetMediaType(formatDescription);
    CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    
    if (_assetWriter.status > AVAssetWriterStatusCompleted)
    {
        TGLog(@"WARNING: camera movie writer status is %d", _assetWriter.status);
        if (_assetWriter.status == AVAssetWriterStatusFailed)
        {
            TGLog(@"ERROR: camera movie writer error: %@", _assetWriter.error);
            _isRecording = false;
            
            if (self.finishedWithMovieAtURL != nil)
                self.finishedWithMovieAtURL(_assetWriter.outputURL, CGAffineTransformIdentity, CGSizeZero, 0.0, false);
        }
        return;
    }
    
    if (mediaType == kCMMediaType_Video)
    {
        if (!_startedWriting)
        {
            if ([_assetWriter startWriting])
            {
                [_assetWriter startSessionAtSourceTime:timestamp];
                _startTimeStamp = timestamp;
            }
            else
            {
                TGLog(@"ERROR: camera movie writer failed to start writing: %@", _assetWriter.error);
            }
            _startedWriting = true;
        }
        
        while (!_videoInput.readyForMoreMediaData)
        {
            TGLog(@"WARNING: camera movie writer had to wait for video frame: %@", CFBridgingRelease(CMTimeCopyDescription(kCFAllocatorDefault, timestamp)));
            
            NSDate *maxDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
            [[NSRunLoop currentRunLoop] runUntilDate:maxDate];
        }

        bool success = [_videoInput appendSampleBuffer:sampleBuffer];
        if (success)
            _lastVideoTimeStamp = timestamp;
        else
            TGLog(@"ERROR: camera movie writer failed to append pixel buffer");
    }
    else if (_startedWriting && mediaType == kCMMediaType_Audio)
    {
        while (!_audioInput.isReadyForMoreMediaData)
        {
            TGLog(@"WARNING: camera movie writer had to wait for audio frame: %@", CFBridgingRelease(CMTimeCopyDescription(kCFAllocatorDefault, timestamp)));

            NSDate *maxDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
            [[NSRunLoop currentRunLoop] runUntilDate:maxDate];
        }
    
        bool success = [_audioInput appendSampleBuffer:sampleBuffer];
        if (success)
            _lastAudioTimeStamp = timestamp;
        else
            TGLog(@"ERROR: camera movie writer failed to append audio buffer");
    }
}

- (NSTimeInterval)currentDuration
{
    return CMTimeGetSeconds(CMTimeSubtract(_lastVideoTimeStamp, _startTimeStamp));
}

+ (NSString *)outputFileType
{
    return AVFileTypeMPEG4;
}

+ (NSString *)tempOutputPath
{
    return [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"cam_%x.mp4", (int)arc4random()]];
}

@end
