#import "TGVideoConverter.h"

#import "ActionStage.h"

#import "ATQueue.h"
#import "TGImageUtils.h"

#import "TGStringUtils.h"

#import <AVFoundation/AVFoundation.h>

#import "MP4Atom.h"

#import <sys/stat.h>

#import "TGLiveUploadActor.h"

@interface TGVideoConverter () <ASWatcher>
{
    ATQueue *_queue;
    ATQueue *_readQueue;
    
    NSURL *_assetUrl;
    NSString *_tempFilePath;
    dispatch_source_t _readerSource;
    
    AVAssetWriter *_assetWriter;
    
    NSString *_liveUploadPath;
    
    bool _highDefinition;
    
    __volatile bool _isCancelled;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGVideoConverter

- (instancetype)initWithAssetUrl:(NSURL *)assetUrl liveUpload:(bool)liveUpload highDefinition:(bool)highDefinition
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
        
        _queue = [[ATQueue alloc] init];
        _readQueue = [[ATQueue alloc] init];
        
        _assetUrl = assetUrl;
        _tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%x.tmp", (int)arc4random()]];
        
        static int nextActionId = 0;
        int actionId = nextActionId++;
        _liveUploadPath = [[NSString alloc] initWithFormat:@"/tg/liveUpload/(%d)", actionId];
        
        _liveUpload = liveUpload;
        _highDefinition = highDefinition;
        
        NSString *tempFilePath = _tempFilePath;
        NSData *(^dataProvider)(NSUInteger offset, NSUInteger length) = ^NSData *(NSUInteger offset, NSUInteger length)
        {
            NSData *result = nil;
            
            NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:tempFilePath];
            struct stat s;
            fstat([file fileDescriptor], &s);
            MP4Atom *fileAtom = [MP4Atom atomAt:0 size:(int)s.st_size type:(OSType)('file') inFile:file];
            MP4Atom *mdatAtom = [TGVideoConverter findMdat:fileAtom];
            if (mdatAtom != nil)
            {
                [file seekToFileOffset:mdatAtom->_offset + offset];
                result = [file readDataOfLength:length];
            }
            [file closeFile];
            
            return result;
        };
        
        if (liveUpload)
        {
            [ActionStageInstance() requestActor:_liveUploadPath options:@{
                @"filePath": _tempFilePath,
                @"unlinkFileAfterCompletion": @true,
                @"encryptFile": @false,
                @"lateHeader": @true,
                @"dataProvider": [dataProvider copy]
            } flags:0 watcher:self];
        }
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    
    dispatch_source_t readerSource = _readerSource;
    
    [_queue dispatch:^
    {
        if (readerSource != nil)
            dispatch_source_cancel(readerSource);
    }];
}

+ (MP4Atom *)findMdat:(MP4Atom *)atom
{
    if (atom == nil)
        return nil;
    
    if (atom.type == (OSType)'mdat')
        return atom;
    
    while (true)
    {
        MP4Atom *child = [atom nextChild];
        if (child == nil)
            break;
        
        MP4Atom *result = [self findMdat:child];
        if (result != nil)
            return result;
    }
    
    return nil;
}

- (dispatch_source_t)resetAndReadFile
{
    int fd = open([_tempFilePath UTF8String], O_NONBLOCK | O_RDONLY);
    
    if (fd > 0)
    {
        dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, fd, 0, _readQueue.nativeQueue);
        
        __block NSUInteger lastFileSize = 0;
        
        __weak TGVideoConverter *weakSelf = self;
        dispatch_source_set_event_handler(source, ^
        {
            struct stat st;
            fstat(fd, &st);
            
            if (st.st_size > lastFileSize + 32 * 1024)
            {
                lastFileSize = (NSUInteger)st.st_size;
                
                __strong TGVideoConverter *strongSelf = weakSelf;
                [strongSelf _fileUpdated];
            }
        });
        
        dispatch_source_set_cancel_handler(source,^
        {
            close(fd);
        });
        
        dispatch_resume(source);
        
        return source;
    }
    
    return nil;
}

- (void)_fileUpdated
{
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:_tempFilePath];
    struct stat s;
    fstat([file fileDescriptor], &s);
    MP4Atom *fileAtom = [MP4Atom atomAt:0 size:(int)s.st_size type:(OSType)('file') inFile:file];
    MP4Atom *mdatAtom = [TGVideoConverter findMdat:fileAtom];
    NSUInteger availableSize = 0;
    if (mdatAtom != nil)
    {
        availableSize = MAX(0, ((int)(mdatAtom.length)) - 1024);
    }
    [file closeFile];
    
    if (availableSize != 0)
    {
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            TGLiveUploadActor *actor = (TGLiveUploadActor *)[ActionStageInstance() executingActorWithPath:_liveUploadPath];
            [actor updateSize:availableSize];
        }];
    }
}

- (NSData *)_finalHeaderDataAndSize:(NSUInteger *)finalSize
{
    NSData *headerData = nil;
    
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:_tempFilePath];
    struct stat s;
    fstat([file fileDescriptor], &s);
    MP4Atom *fileAtom = [MP4Atom atomAt:0 size:(int)s.st_size type:(OSType)('file') inFile:file];
    MP4Atom *mdatAtom = [TGVideoConverter findMdat:fileAtom];
    if (mdatAtom != nil)
    {
        [file seekToFileOffset:0];
        headerData = [file readDataOfLength:(NSUInteger)mdatAtom->_offset];
        if (finalSize != NULL)
            *finalSize = (NSUInteger)s.st_size;
    }
    [file closeFile];
    
    return headerData;
}

- (void)convertWithCompletion:(void (^)(NSString *tempFilePath, CGSize dimensions, NSTimeInterval duration, TGLiveUploadActorData *liveUploadData))completion progress:(void (^)(float progress))__unused progress
{
    [_queue dispatch:^
    {
        NSURL *fullPath = [NSURL fileURLWithPath:_tempFilePath];
        
        NSLog(@"Write Started");
        
        NSError *error = nil;
        
        _assetWriter = [[AVAssetWriter alloc] initWithURL:fullPath fileType:AVFileTypeMPEG4 error:&error];
        
        if (_assetWriter == nil)
        {
            if (completion)
                completion(nil, CGSizeZero, 0.0, nil);
            
            return;
        }
        
        AVAsset *avAsset = [[AVURLAsset alloc] initWithURL:_assetUrl options:nil];
        
        AVAssetTrack *videoTrack = [[avAsset tracksWithMediaType:AVMediaTypeVideo]objectAtIndex:0];
        
        CGSize fitSize = CGSizeMake(640.0f, 640.0f);
        CGSize internalVideoDimensions = TGFitSize(videoTrack.naturalSize, fitSize);
        CGSize videoDimensions = CGRectApplyAffineTransform((CGRect){CGPointZero, internalVideoDimensions}, videoTrack.preferredTransform).size;
        NSTimeInterval videoDuration = CMTimeGetSeconds(avAsset.duration);
        
        NSDictionary *videoCleanApertureSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    @((int)internalVideoDimensions.width), AVVideoCleanApertureWidthKey,
                                                    @((int)internalVideoDimensions.height), AVVideoCleanApertureHeightKey,
                                                    [NSNumber numberWithInt:10], AVVideoCleanApertureHorizontalOffsetKey,
                                                    [NSNumber numberWithInt:10], AVVideoCleanApertureVerticalOffsetKey,
                                                    nil];
        
        
        NSDictionary *videoAspectRatioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:3], AVVideoPixelAspectRatioHorizontalSpacingKey,
                                                  [NSNumber numberWithInt:3],AVVideoPixelAspectRatioVerticalSpacingKey,
                                                  nil];
        
        
        
        NSDictionary *codecSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInt:_highDefinition ? ((int)(750000 * 2.0)) : 750000], AVVideoAverageBitRateKey,
                                       //[NSNumber numberWithInt:1],AVVideoMaxKeyFrameIntervalKey,
                                       videoCleanApertureSettings, AVVideoCleanApertureKey,
                                       videoAspectRatioSettings, AVVideoPixelAspectRatioKey,
                                       //AVVideoProfileLevelH264Main30, AVVideoProfileLevelKey,
                                       nil];
        
        
        NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                       AVVideoCodecH264, AVVideoCodecKey,
                                       codecSettings,AVVideoCompressionPropertiesKey,
                                       @((int)internalVideoDimensions.width), AVVideoWidthKey,
                                       @((int)internalVideoDimensions.height), AVVideoHeightKey,
                                       nil];
        
        AVAssetWriterInput *videoWriterInput = [AVAssetWriterInput
                                                 assetWriterInputWithMediaType:AVMediaTypeVideo
                                                 outputSettings:videoSettings];
        NSParameterAssert(videoWriterInput);
        NSParameterAssert([_assetWriter canAddInput:videoWriterInput]);
        
        videoWriterInput.expectsMediaDataInRealTime = YES;
        [_assetWriter addInput:videoWriterInput];
        NSError *aerror = nil;
        AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:avAsset error:&aerror];
        
        videoWriterInput.transform = videoTrack.preferredTransform;
        NSDictionary *videoOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        AVAssetReaderTrackOutput *asset_reader_output = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:videoOptions];
        [reader addOutput:asset_reader_output];
        
        AudioChannelLayout acl;
        bzero( &acl, sizeof(acl));
        acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
        
        __unused NSDictionary *audioSettings = @{
            AVFormatIDKey: @(kAudioFormatMPEG4AAC),
            AVSampleRateKey: @(44100.0f),
            AVEncoderBitRateKey: @(64000),
            AVNumberOfChannelsKey: @(1),
            AVChannelLayoutKey: [NSData dataWithBytes:&acl length: sizeof(acl)]
        };
        
        AVAssetTrack *audioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        
        AVAssetWriterInput *audioWriterInput = nil;
        AVAssetReaderTrackOutput *readerOutput = nil;
        AVAssetReader *audioReader = nil;
        if (audioTrack != nil)
        {
            audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioSettings];
            audioReader = [AVAssetReader assetReaderWithAsset:avAsset error:&error];
            
            readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:@{
                    AVFormatIDKey: @(kAudioFormatLinearPCM),
                    AVSampleRateKey: @(44100.0f),
                    AVNumberOfChannelsKey: @(1),
                    AVChannelLayoutKey: [NSData dataWithBytes:&acl length: sizeof(acl)],
                    AVLinearPCMBitDepthKey: @(16),
                    AVLinearPCMIsNonInterleaved: @false,
                    AVLinearPCMIsFloatKey: @false,
                    AVLinearPCMIsBigEndianKey: @false
            }];
            
            [audioReader addOutput:readerOutput];
            NSParameterAssert(audioWriterInput);
            
            audioWriterInput.expectsMediaDataInRealTime = NO;
            [_assetWriter addInput:audioWriterInput];
        }
        
        [_assetWriter startWriting];
        [_assetWriter startSessionAtSourceTime:kCMTimeZero];
        [reader startReading];
        
        if (_liveUpload)
            _readerSource = [self resetAndReadFile];
        
        __block int lastProgressReported = 0;
        
        [videoWriterInput requestMediaDataWhenReadyOnQueue:_queue.nativeQueue usingBlock:^
        {
             while ([videoWriterInput isReadyForMoreMediaData] && !_isCancelled)
             {
                 CMSampleBufferRef sampleBuffer = NULL;
                 if ([reader status] == AVAssetReaderStatusReading && (sampleBuffer = [asset_reader_output copyNextSampleBuffer]))
                 {
                     int currentProgress = (int)(CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer)) * 100.0 / videoDuration);
                     if (lastProgressReported != currentProgress)
                     {
                         lastProgressReported = currentProgress;
                         if (progress != nil)
                             progress(currentProgress / 100.0f);
                     }
                     
                     BOOL result = [videoWriterInput appendSampleBuffer:sampleBuffer];
                     CFRelease(sampleBuffer);
                     
                     if (!result)
                     {
                         [reader cancelReading];
                         
                         if (completion)
                             completion(nil, CGSizeZero, 0.0, nil);
                         
                         break;
                     }
                 }
                 else
                 {
                     [videoWriterInput markAsFinished];
                     
                     switch ([reader status])
                     {
                         case AVAssetReaderStatusReading:
                         {
                             break;
                         }
                         case AVAssetReaderStatusCompleted:
                         {
                             if (audioReader != nil)
                             {
                             [audioReader startReading];
                             [_assetWriter startSessionAtSourceTime:kCMTimeZero];

                             [audioWriterInput requestMediaDataWhenReadyOnQueue:_queue.nativeQueue usingBlock:^
                             {
                                  while ([audioWriterInput isReadyForMoreMediaData] && !_isCancelled)
                                  {
                                      CMSampleBufferRef nextBuffer = NULL;
                                      if ([audioReader status] == AVAssetReaderStatusReading &&
                                          (nextBuffer = [readerOutput copyNextSampleBuffer]))
                                      {
                                          if (nextBuffer)
                                          {
                                              [audioWriterInput appendSampleBuffer:nextBuffer];
                                          }
                                      }
                                      else
                                      {
                                          [audioWriterInput markAsFinished];
                                          switch ([audioReader status])
                                          {
                                              case AVAssetReaderStatusCompleted:
                                              {
                                                  [_assetWriter finishWritingWithCompletionHandler:^
                                                  {
                                                      [_readQueue dispatch:^
                                                      {
                                                          NSUInteger finalSize = 0;
                                                          NSData *headerData = nil;
                                                          __block TGLiveUploadActorData *liveData = nil;
                                                          
                                                          if (_liveUpload)
                                                          {
                                                              headerData = [self _finalHeaderDataAndSize:&finalSize];
                                                              
                                                              if (headerData != nil && finalSize != 0)
                                                              {
                                                                  dispatch_sync([ActionStageInstance() globalStageDispatchQueue], ^
                                                                  {
                                                                      TGLiveUploadActor *actor = (TGLiveUploadActor *)[ActionStageInstance() executingActorWithPath:_liveUploadPath];
                                                                      
                                                                      liveData = [actor finishRestOfFileWithHeader:headerData finalSize:finalSize];
                                                                  });
                                                              }
                                                          }
                                                          
                                                          if (completion)
                                                              completion(_tempFilePath, videoDimensions, videoDuration, liveData);
                                                      }];
                                                  }];
                                                  break;
                                              }
                                              default:
                                              {
                                                  if (completion)
                                                      completion(nil, CGSizeZero, 0.0, nil);
                                                  
                                                  break;
                                              }
                                          }
                                      }
                                  }
                                  
                              }];
                             }
                             else
                             {
                                 [_assetWriter finishWritingWithCompletionHandler:^
                                  {
                                      [_readQueue dispatch:^
                                       {
                                           NSUInteger finalSize = 0;
                                           NSData *headerData = nil;
                                           __block TGLiveUploadActorData *liveData = nil;
                                           
                                           if (_liveUpload)
                                           {
                                               headerData = [self _finalHeaderDataAndSize:&finalSize];
                                               
                                               if (headerData != nil && finalSize != 0)
                                               {
                                                   dispatch_sync([ActionStageInstance() globalStageDispatchQueue], ^
                                                                 {
                                                                     TGLiveUploadActor *actor = (TGLiveUploadActor *)[ActionStageInstance() executingActorWithPath:_liveUploadPath];
                                                                     
                                                                     liveData = [actor finishRestOfFileWithHeader:headerData finalSize:finalSize];
                                                                 });
                                               }
                                           }
                                           
                                           if (completion)
                                               completion(_tempFilePath, videoDimensions, videoDuration, liveData);
                                       }];
                                  }];
                             }
                             
                             break;
                         }
                         case AVAssetReaderStatusFailed:
                         {
                             [_assetWriter cancelWriting];
                             
                             if (completion)
                                 completion(nil, CGSizeZero, 0.0, nil);
                             
                             break;
                         }
                        default:
                             break;
                     }
                     
                     break;
                 }
             }
         }
         ];
    }];
}

- (void)cancel
{
    _isCancelled = true;
    
    [_queue dispatch:^
    {
        if (_readerSource != nil)
            dispatch_source_cancel(_readerSource);
        [ActionStageInstance() removeWatcher:self];
        
        [_assetWriter cancelWriting];
    }];
}

@end
