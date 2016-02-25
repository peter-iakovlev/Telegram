#import "TGShareVideoConverter.h"
#import <UIKit/UIKit.h>

#import "TGGeometry.h"

#import "MP4Atom.h"

#import <sys/stat.h>

const CGSize TGVideoConverterResultSize = { 640.0f, 640.0f };

@interface TGShareVideoConverter ()
{
    SQueue *_queue;
    SQueue *_readQueue;
    
    AVAsset *_asset;
    NSURL *_itemURL;
    
    NSString *_tempFilePath;
    dispatch_source_t _readerSource;
    
    AVAssetWriter *_assetWriter;
    
    NSString *_liveUploadPath;
    
    bool _passThrough;
    bool _highDefinition;
    
    __volatile bool _isCancelled;
}

@property (nonatomic, assign) bool liveUpload;
@property (nonatomic, assign) CMTimeRange trimRange;
@property (nonatomic, assign) CGRect cropRect;
@property (nonatomic, assign) UIImageOrientation cropOrientation;

//@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGShareVideoConverter

- (instancetype)initWithAVAsset:(AVAsset *)asset
{
    self = [super init];
    if (self != nil)
    {
        _asset = asset;
        
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _trimRange = kCMTimeRangeZero;
    
    //_actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
    
    _queue = [[SQueue alloc] init];
    _readQueue = [[SQueue alloc] init];
    
    _tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%x.tmp", (int)arc4random()]];
    
    static int nextActionId = 0;
    int actionId = nextActionId++;
    _liveUploadPath = [[NSString alloc] initWithFormat:@"/tg/liveUpload/(%d)", actionId];
    
//    NSString *tempFilePath = _tempFilePath;
//    NSData *(^dataProvider)(NSUInteger, NSUInteger) = ^NSData *(NSUInteger offset, NSUInteger length)
//    {
//        NSData *result = nil;
//        
//        NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:tempFilePath];
//        struct stat s;
//        fstat([file fileDescriptor], &s);
//        MP4Atom *fileAtom = [MP4Atom atomAt:0 size:(int)s.st_size type:(OSType)('file') inFile:file];
//        MP4Atom *mdatAtom = [TGShareVideoConverter findMdat:fileAtom];
//        if (mdatAtom != nil)
//        {
//            [file seekToFileOffset:mdatAtom->_offset + offset];
//            result = [file readDataOfLength:length];
//        }
//        [file closeFile];
//        
//        return result;
//    };
    
//    if (_liveUpload)
//    {
//        [ActionStageInstance() requestActor:_liveUploadPath options:
//         @{
//           @"filePath": _tempFilePath,
//           @"unlinkFileAfterCompletion": @true,
//           @"encryptFile": @false,
//           @"lateHeader": @true,
//           @"dataProvider": [dataProvider copy]
//           } flags:0 watcher:self];
//    }
}

- (void)dealloc
{
//    [_actionHandle reset];
//    [ActionStageInstance() removeWatcher:self];
    
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
        dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, fd, 0, _readQueue._dispatch_queue);
        
        __block NSUInteger lastFileSize = 0;
        
        __weak TGShareVideoConverter *weakSelf = self;
        dispatch_source_set_event_handler(source, ^
        {
            struct stat st;
            fstat(fd, &st);
            
            if (st.st_size > (long long)(lastFileSize + 32 * 1024))
            {
                lastFileSize = (NSUInteger)st.st_size;
                
                __strong TGShareVideoConverter *strongSelf = weakSelf;
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
    MP4Atom *mdatAtom = [TGShareVideoConverter findMdat:fileAtom];
    NSUInteger availableSize = 0;
    if (mdatAtom != nil)
    {
        availableSize = MAX(0, ((int)(mdatAtom.length)) - 1024);
    }
    [file closeFile];
    
    if (availableSize != 0)
    {
//        [ActionStageInstance() dispatchOnStageQueue:^
//         {
//             TGLiveUploadActor *actor = (TGLiveUploadActor *)[ActionStageInstance() executingActorWithPath:_liveUploadPath];
//             [actor updateSize:availableSize];
//         }];
    }
}

- (NSData *)_finalHeaderDataAndSize:(NSUInteger *)finalSize
{
    NSData *headerData = nil;
    
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:_tempFilePath];
    struct stat s;
    fstat([file fileDescriptor], &s);
    MP4Atom *fileAtom = [MP4Atom atomAt:0 size:(int)s.st_size type:(OSType)('file') inFile:file];
    MP4Atom *mdatAtom = [TGShareVideoConverter findMdat:fileAtom];
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

- (CGRect)_normalizeCropRect:(CGRect)cropRect
{
    return CGRectIntegral(cropRect);
}

- (CGSize)_renderSizeWithCropSize:(CGSize)cropSize
{
    CGFloat blockSize = 16.0f;
    
    CGFloat renderWidth = floor(cropSize.width / blockSize) * blockSize;
    CGFloat renderHeight = floor(cropSize.height * renderWidth / cropSize.width);
    if (fmodf((float)renderHeight, (float)blockSize) != 0)
        renderHeight = floor(cropSize.height / blockSize) * blockSize;
    return CGSizeMake(renderWidth, renderHeight);
}

UIImageOrientation TGVideoOrientationForAsset(AVAsset *asset, bool *mirrored)
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGAffineTransform t = videoTrack.preferredTransform;
    double videoRotation = atan2((float)t.b, (float)t.a);
    
    if (mirrored != NULL)
    {
        UIView *tempView = [[UIView alloc] init];
        tempView.transform = t;
        CGSize scale = CGSizeMake([[tempView.layer valueForKeyPath: @"transform.scale.x"] floatValue],
                                  [[tempView.layer valueForKeyPath: @"transform.scale.y"] floatValue]);
        
        *mirrored = (scale.width < 0);
    }
    
    if (fabs(videoRotation - M_PI) < FLT_EPSILON)
        return UIImageOrientationLeft;
    else if (fabs(videoRotation - M_PI_2) < FLT_EPSILON)
        return UIImageOrientationUp;
    else if (fabs(videoRotation + M_PI_2) < FLT_EPSILON)
        return UIImageOrientationDown;
    else
        return UIImageOrientationRight;
}

UIImageOrientation TGVideoFinalOrientationForOrientation(UIImageOrientation videoOrientation, UIImageOrientation cropOrientation)
{
    switch (videoOrientation)
    {
        case UIImageOrientationUp:
            return cropOrientation;
            
        case UIImageOrientationDown:
        {
            switch (cropOrientation)
            {
                case UIImageOrientationDown:
                    return UIImageOrientationUp;
                    
                case UIImageOrientationLeft:
                    return UIImageOrientationRight;
                    
                case UIImageOrientationRight:
                    return UIImageOrientationLeft;
                    
                default:
                    return videoOrientation;
            }
        }
            break;
            
        case UIImageOrientationLeft:
        {
            switch (cropOrientation)
            {
                case UIImageOrientationDown:
                    return UIImageOrientationRight;
                    
                case UIImageOrientationLeft:
                    return UIImageOrientationDown;
                    
                case UIImageOrientationRight:
                    return UIImageOrientationUp;
                    
                default:
                    return videoOrientation;
            }
        }
            break;
            
        case UIImageOrientationRight:
        {
            switch (cropOrientation)
            {
                case UIImageOrientationDown:
                    return UIImageOrientationLeft;
                    
                case UIImageOrientationLeft:
                    return UIImageOrientationUp;
                    
                case UIImageOrientationRight:
                    return UIImageOrientationDown;
                    
                default:
                    return videoOrientation;
            }
        }
            break;
            
        default:
            return videoOrientation;
    }
}

CGAffineTransform TGVideoTransformForOrientation(UIImageOrientation orientation, CGSize size, CGRect cropRect, bool mirror)
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    if (mirror)
    {
        if (TGOrientationIsSideward(orientation, NULL))
        {
            cropRect.origin.y *= - 1;
            transform = CGAffineTransformTranslate(transform, 0, size.height);
            transform = CGAffineTransformScale(transform, 1.0f, -1.0f);
        }
        else
        {
            cropRect.origin.x = size.height - cropRect.origin.x;
            transform = CGAffineTransformScale(transform, -1.0f, 1.0f);
        }
    }
    
    switch (orientation)
    {
        case UIImageOrientationUp:
        {
            transform = CGAffineTransformRotate(CGAffineTransformTranslate(transform, size.height - cropRect.origin.x, 0 - cropRect.origin.y), (CGFloat)M_PI_2);
        }
            break;
            
        case UIImageOrientationDown:
        {
            transform = CGAffineTransformRotate(CGAffineTransformTranslate(transform, 0 - cropRect.origin.x, size.width - cropRect.origin.y), (CGFloat)-M_PI_2);
        }
            break;
            
        case UIImageOrientationRight:
        {
            transform = CGAffineTransformRotate(CGAffineTransformTranslate(transform, 0 - cropRect.origin.x, 0 - cropRect.origin.y), 0);
        }
            break;
            
        case UIImageOrientationLeft:
        {
            transform = CGAffineTransformRotate(CGAffineTransformTranslate(transform, size.width - cropRect.origin.x, size.height - cropRect.origin.y), (CGFloat)M_PI);
        }
            break;
            
        default:
            break;
    }
    
    return transform;
}

CGAffineTransform TGVideoCropTransformForOrientation(UIImageOrientation orientation, CGSize size, bool rotateSize)
{
    if (rotateSize && TGOrientationIsSideward(orientation, NULL))
        size = CGSizeMake(size.height, size.width);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (orientation)
    {
        case UIImageOrientationDown:
        {
            transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(size.width, size.height), (CGFloat)M_PI);
        }
            break;
            
        case UIImageOrientationRight:
        {
            transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(size.width, 0), (CGFloat)M_PI_2);
        }
            break;
            
        case UIImageOrientationLeft:
        {
            transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(0, size.height), (CGFloat)-M_PI_2);
        }
            break;
            
        default:
            break;
    }
    
    return transform;
}

- (void)processWithCompletion:(void (^)(NSString *tempFilePath, CGSize dimensions, NSTimeInterval duration, UIImage *previewImage))completion progress:(void (^)(float progress))progress
{
    [_queue dispatch:^
     {
         NSURL *fullPath = [NSURL fileURLWithPath:_tempFilePath];
         
         NSLog(@"Write Started");
         
         NSError *error = nil;
         
         _assetWriter = [[AVAssetWriter alloc] initWithURL:fullPath fileType:AVFileTypeMPEG4 error:&error];
         
         if (_assetWriter == nil)
         {
             if (completion != nil)
                 completion(nil, CGSizeZero, 0.0, nil);
             return;
         }
         
         AVAsset *avAsset = nil;
         if (_asset != nil)
             avAsset = _asset;
         else if (_itemURL != nil)
             avAsset = [AVURLAsset assetWithURL:_itemURL];
         
         if (avAsset == nil)
         {
             if (completion)
                 completion(nil, CGSizeZero, 0.0, nil);
             return;
         }
         
         AVAssetTrack *videoTrack = [[avAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
         CGSize normalizedVideoSize = CGRectApplyAffineTransform((CGRect){CGPointZero, videoTrack.naturalSize}, videoTrack.preferredTransform).size;
         
         bool hasCropping = !CGRectEqualToRect(_cropRect, CGRectZero);
         CGRect cropRect = hasCropping ? [self _normalizeCropRect:_cropRect] : CGRectMake(0, 0, normalizedVideoSize.width, normalizedVideoSize.height);
         
         CGSize outputVideoDimensions = TGFitSize(cropRect.size, TGVideoConverterResultSize);
         if (hasCropping)
             outputVideoDimensions = [self _renderSizeWithCropSize:outputVideoDimensions];
         
         if (TGOrientationIsSideward(_cropOrientation, NULL))
             outputVideoDimensions = CGSizeMake(outputVideoDimensions.height, outputVideoDimensions.width);
         
         NSDictionary *videoCleanApertureSettings =
         @{
           AVVideoCleanApertureWidthKey: @((NSInteger)outputVideoDimensions.width),
           AVVideoCleanApertureHeightKey: @((NSInteger)outputVideoDimensions.height),
           AVVideoCleanApertureHorizontalOffsetKey: @10,
           AVVideoCleanApertureVerticalOffsetKey: @10
           };
         
         NSDictionary *videoAspectRatioSettings =
         @{
           AVVideoPixelAspectRatioHorizontalSpacingKey: @3,
           AVVideoPixelAspectRatioVerticalSpacingKey: @3
           };
         
         NSDictionary *codecSettings =
         @{
           AVVideoAverageBitRateKey: @(_highDefinition ? ((NSInteger)(750000 * 2.0)) : 750000),
           AVVideoCleanApertureKey: videoCleanApertureSettings,
           AVVideoPixelAspectRatioKey: videoAspectRatioSettings
           };
         
         NSDictionary *videoInputSettings =
         @{
           AVVideoCodecKey: AVVideoCodecH264,
           AVVideoCompressionPropertiesKey: codecSettings,
           AVVideoWidthKey: @((NSInteger)outputVideoDimensions.width),
           AVVideoHeightKey: @((NSInteger)outputVideoDimensions.height)
           };
         
         AVAssetWriterInput *videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoInputSettings];
         NSParameterAssert([_assetWriter canAddInput:videoWriterInput]);
         
         videoWriterInput.expectsMediaDataInRealTime = true;
         [_assetWriter addInput:videoWriterInput];
         
         AVMutableComposition *composition = nil;
         AVMutableVideoComposition *videoComposition = nil;
         AVAsset *readedAsset = avAsset;
         AVAssetTrack *readedVideoTrack = videoTrack;
         UIImage *previewImage = nil;
         
         NSTimeInterval videoDuration = 0.0;
         CMTimeRange range = videoTrack.timeRange;
         if (!CMTIMERANGE_IS_EMPTY(_trimRange))
         {
             range = _trimRange;
             videoDuration = CMTimeGetSeconds(_trimRange.duration);
         }
         else
         {
             videoDuration = CMTimeGetSeconds(avAsset.duration);
         }
         
         composition = [AVMutableComposition composition];
         readedAsset = composition;
         
         AVMutableCompositionTrack *trimCompositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                         preferredTrackID:kCMPersistentTrackID_Invalid];
         [trimCompositionVideoTrack insertTimeRange:range ofTrack:videoTrack atTime:kCMTimeZero error:NULL];
         readedVideoTrack = trimCompositionVideoTrack;
         
         videoComposition = [AVMutableVideoComposition videoComposition];
         videoComposition.frameDuration = CMTimeMake(1, (int32_t)videoTrack.nominalFrameRate);
         
         
         if (TGOrientationIsSideward(_cropOrientation, NULL))
             videoComposition.renderSize = [self _renderSizeWithCropSize:CGSizeMake(cropRect.size.height, cropRect.size.width)];
         else
             videoComposition.renderSize = [self _renderSizeWithCropSize:cropRect.size];
         
         AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
         instruction.timeRange = CMTimeRangeMake(kCMTimeZero, range.duration);
         
         AVMutableVideoCompositionLayerInstruction *transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:trimCompositionVideoTrack];
         
         bool mirrored = false;
         UIImageOrientation videoOrientation = TGVideoOrientationForAsset(avAsset, &mirrored);
         CGAffineTransform transform = TGVideoTransformForOrientation(videoOrientation, videoTrack.naturalSize, cropRect, mirrored);
         CGAffineTransform rotationTransform = TGVideoCropTransformForOrientation(_cropOrientation, cropRect.size, true);
         CGAffineTransform finalTransform = CGAffineTransformConcat(transform, rotationTransform);
         [transformer setTransform:finalTransform atTime:kCMTimeZero];
         
         instruction.layerInstructions = [NSArray arrayWithObject:transformer];
         videoComposition.instructions = [NSArray arrayWithObject:instruction];
         
         AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:composition];
         imageGenerator.videoComposition = videoComposition;
         imageGenerator.maximumSize = TGVideoConverterResultSize;
         CGImageRef imageRef = [imageGenerator copyCGImageAtTime:range.start actualTime:NULL error:NULL];
         previewImage = [UIImage imageWithCGImage:imageRef];
         CGImageRelease(imageRef);
         
         AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:readedAsset error:&error];
         
         NSDictionary *videoOutputSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
         
         AVAssetReaderVideoCompositionOutput *compositionOutput = [[AVAssetReaderVideoCompositionOutput alloc] initWithVideoTracks:[composition tracksWithMediaType:AVMediaTypeVideo] videoSettings:videoOutputSettings];
         compositionOutput.videoComposition = videoComposition;
         [reader addOutput:compositionOutput];
         
         AudioChannelLayout acl;
         bzero( &acl, sizeof(acl));
         acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
         
         NSDictionary *audioInputSettings =
         @{
           AVFormatIDKey: @(kAudioFormatMPEG4AAC),
           AVSampleRateKey: @44100.0f,
           AVEncoderBitRateKey: @64000,
           AVNumberOfChannelsKey: @1,
           AVChannelLayoutKey: [NSData dataWithBytes:&acl length: sizeof(acl)]
           };
         
         AVAssetTrack *audioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
         
         AVAssetWriterInput *audioWriterInput = nil;
         AVAssetReaderTrackOutput *readerOutput = nil;
         AVAssetReader *audioReader = nil;
         
         if (audioTrack != nil)
         {
             AVAssetTrack *readedAudioTrack = audioTrack;
             if (composition != nil)
             {
                 AVMutableCompositionTrack *trimCompositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                                 preferredTrackID:kCMPersistentTrackID_Invalid];
                 [trimCompositionAudioTrack insertTimeRange:range ofTrack:audioTrack atTime:kCMTimeZero error:NULL];
                 readedAudioTrack = trimCompositionAudioTrack;
             }
             
             audioReader = [AVAssetReader assetReaderWithAsset:readedAsset error:&error];
             
             NSDictionary *audioOutputSettings =
             @{
               AVFormatIDKey: @(kAudioFormatLinearPCM),
               AVSampleRateKey: @44100.0f,
               AVNumberOfChannelsKey: @1,
               AVChannelLayoutKey: [NSData dataWithBytes:&acl length: sizeof(acl)],
               AVLinearPCMBitDepthKey: @16,
               AVLinearPCMIsNonInterleaved: @false,
               AVLinearPCMIsFloatKey: @false,
               AVLinearPCMIsBigEndianKey: @false
               };
             
             readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:readedAudioTrack outputSettings:audioOutputSettings];
             [audioReader addOutput:readerOutput];
             
             audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioInputSettings];
             audioWriterInput.expectsMediaDataInRealTime = false;
             NSParameterAssert([_assetWriter canAddInput:audioWriterInput]);
             [_assetWriter addInput:audioWriterInput];
         }
         
         [_assetWriter startWriting];
         [_assetWriter startSessionAtSourceTime:kCMTimeZero];
         [reader startReading];
         
         if (_liveUpload)
             _readerSource = [self resetAndReadFile];
         
         __block int lastProgressReported = 0;
         
         void(^writeCompletion)(void) = ^
         {
             [_assetWriter finishWritingWithCompletionHandler:^
             {
                 [_readQueue dispatch:^
                 {
                     //NSUInteger finalSize = 0;
                     //NSData *headerData = nil;
                     //                       __block TGLiveUploadActorData *liveData = nil;
                     //
                     //                       if (_liveUpload)
                     //                       {
                     //                           headerData = [self _finalHeaderDataAndSize:&finalSize];
                     //
                     //                           if (headerData != nil && finalSize != 0)
                     //                           {
                     //                               dispatch_sync([ActionStageInstance() globalStageDispatchQueue], ^
                     //                                             {
                     //                                                 TGLiveUploadActor *actor = (TGLiveUploadActor *)[ActionStageInstance() executingActorWithPath:_liveUploadPath];
                     //
                     //                                                 liveData = [actor finishRestOfFileWithHeader:headerData finalSize:finalSize];
                     //                                             });
                     //                           }
                     //                       }
                     
                     if (completion != nil)
                         completion(_tempFilePath, outputVideoDimensions, videoDuration, previewImage);
                 }];
             }];
         };
         
         [videoWriterInput requestMediaDataWhenReadyOnQueue:_queue._dispatch_queue usingBlock:^
         {
             while ([videoWriterInput isReadyForMoreMediaData] && !_isCancelled)
             {
                 CMSampleBufferRef sampleBuffer = NULL;
                 if ([reader status] == AVAssetReaderStatusReading && (sampleBuffer = [compositionOutput copyNextSampleBuffer]))
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
                                 
                                 [audioWriterInput requestMediaDataWhenReadyOnQueue:_queue._dispatch_queue usingBlock:^
                                 {
                                     while ([audioWriterInput isReadyForMoreMediaData] && !_isCancelled)
                                     {
                                         CMSampleBufferRef nextBuffer = NULL;
                                         if ([audioReader status] == AVAssetReaderStatusReading &&
                                             (nextBuffer = [readerOutput copyNextSampleBuffer]))
                                         {
                                             if (nextBuffer)
                                                 [audioWriterInput appendSampleBuffer:nextBuffer];
                                         }
                                         else
                                         {
                                             [audioWriterInput markAsFinished];
                                             switch ([audioReader status])
                                             {
                                                 case AVAssetReaderStatusCompleted:
                                                 {
                                                     writeCompletion();
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
                                 writeCompletion();
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
         }];
     }];
}

- (void)cancel
{
    _isCancelled = true;
    
    [_queue dispatch:^
     {
         if (_readerSource != nil)
             dispatch_source_cancel(_readerSource);
         //[ActionStageInstance() removeWatcher:self];
         
         [_assetWriter cancelWriting];
     }];
}

+ (SSignal *)convertSignalForAVAsset:(AVAsset *)avAsset
{
    TGShareVideoConverter *videoConverter = [[TGShareVideoConverter alloc] initWithAVAsset:avAsset];
    
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        [videoConverter processWithCompletion:^(NSString *filePath, CGSize dimensions, NSTimeInterval duration, UIImage *previewImage)
        {
            if (filePath != nil)
            {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                dict[@"fileUrl"] = [NSURL fileURLWithPath:filePath];
                dict[@"dimensions"] = [NSValue valueWithCGSize:dimensions];
                dict[@"duration"] = @(duration);
                if (previewImage != nil)
                    dict[@"previewImage"] = previewImage;
//                if (liveUploadData != nil)
//                    dict[@"liveUploadData"] = liveUploadData;
                
                [subscriber putNext:dict];
                [subscriber putCompletion];
            }
            else
            {
                [subscriber putError:nil];
            }
        } progress:^(float progress)
        {
            [subscriber putNext:@(progress)];
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [videoConverter cancel];
        }];
    }];
}

@end
