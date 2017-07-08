#import "TGVideoConverter.h"
#import "ActionStage.h"

#import "ATQueue.h"
#import "TGImageUtils.h"
#import "TGStringUtils.h"
#import "TGPhotoEditorUtils.h"

#import "TGVideoEditAdjustments.h"
#import "TGPaintingData.h"

#import <SSignalKit/SSignalKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "MP4Atom.h"

#import <sys/stat.h>

#import "TGLiveUploadActor.h"

#import "TGTelegramNetworking.h"

const CGSize TGVideoConverterResultSize = { 640.0f, 640.0f };
const NSInteger TGVideoConverterVideoBitrate = 800000;

const CGSize TGVideoConverterGifResultSize = { 640.0f, 640.0f };
const NSInteger TGVideoConverterGifVideoBitrate = 500000;

@interface TGVideoConverter () <ASWatcher>
{
    ATQueue *_queue;
    ATQueue *_readQueue;
    
    AVAsset *_asset;
    NSURL *_itemURL;
    
    NSString *_tempFilePath;
    dispatch_source_t _readerSource;
    
    AVAssetWriter *_assetWriter;
    
    NSString *_liveUploadPath;
    
    __volatile bool _isCancelled;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@property (nonatomic, assign) bool liveUpload;
@property (nonatomic, assign) CMTimeRange trimRange;
@property (nonatomic, assign) CGRect cropRect;
@property (nonatomic, assign) UIImageOrientation cropOrientation;
@property (nonatomic, assign) bool cropMirorred;
@property (nonatomic, strong) NSString *overlayImagePath;
@property (nonatomic, assign) bool asGif;

@end

@implementation TGVideoConverter

- (instancetype)initForConvertationWithAVAsset:(AVAsset *)asset liveUpload:(bool)liveUpload
{
    self = [super init];
    if (self != nil)
    {
        _asset = asset;
        _liveUpload = liveUpload;
        
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _trimRange = kCMTimeRangeZero;
    
    _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
    
    _queue = [[ATQueue alloc] init];
    _readQueue = [[ATQueue alloc] init];
    
    _tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%x.tmp", (int)arc4random()]];
    
    static int nextActionId = 0;
    int actionId = nextActionId++;
    _liveUploadPath = [[NSString alloc] initWithFormat:@"/tg/liveUpload/(%d)", actionId];
    
    NSString *tempFilePath = _tempFilePath;
    NSData *(^dataProvider)(NSUInteger, NSUInteger) = ^NSData *(NSUInteger offset, NSUInteger length)
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
    
    if (_liveUpload)
    {
        [ActionStageInstance() requestActor:_liveUploadPath options:
         @{
           @"filePath": _tempFilePath,
           @"unlinkFileAfterCompletion": @true,
           @"encryptFile": @false,
           @"lateHeader": @true,
           @"dataProvider": [dataProvider copy],
           @"mediaTypeTag": @(TGNetworkMediaTypeTagVideo)
           } flags:0 watcher:self];
    }
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
            
            if (st.st_size > (long long)(lastFileSize + 32 * 1024))
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

- (CGRect)_normalizeCropRect:(CGRect)cropRect
{
    return CGRectIntegral(cropRect);
}

- (CGSize)_renderSizeWithCropSize:(CGSize)cropSize
{
    CGFloat blockSize = 16.0f;
    
    CGFloat renderWidth = CGFloor(cropSize.width / blockSize) * blockSize;
    CGFloat renderHeight = CGFloor(cropSize.height * renderWidth / cropSize.width);
    if (fmodf((float)renderHeight, (float)blockSize) != 0)
        renderHeight = CGFloor(cropSize.height / blockSize) * blockSize;
    return CGSizeMake(renderWidth, renderHeight);
}

- (void)processWithCompletion:(void (^)(NSString *tempFilePath, CGSize dimensions, NSTimeInterval duration, UIImage *previewImage, TGLiveUploadActorData *liveUploadData))completion progress:(void (^)(float progress))progress
{
    [_queue dispatch:^
    {
        void (^fail)(void) = ^
        {
            if (completion != nil)
                completion(nil, CGSizeZero, 0.0, nil, nil);
        };
        
        TGLog(@"[VideoConverter] Conversion Started: %@", _tempFilePath);
        
        NSURL *fullPath = [NSURL fileURLWithPath:_tempFilePath];
        NSError *error = nil;
        _assetWriter = [[AVAssetWriter alloc] initWithURL:fullPath fileType:AVFileTypeMPEG4 error:&error];
        if (_assetWriter == nil)
        {
            fail();
            return;
        }
        
        AVAsset *avAsset = nil;
        if (_asset != nil)
            avAsset = _asset;
        else if (_itemURL != nil)
            avAsset = [AVURLAsset assetWithURL:_itemURL];
        
        AVAssetTrack *videoTrack = [[avAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        if (videoTrack == nil)
        {
            TGLog(@"[VideoConverter] ERROR: Video track is nil");
            fail();
            return;
        }
        
        CGSize normalizedVideoSize = CGRectApplyAffineTransform((CGRect){CGPointZero, videoTrack.naturalSize}, videoTrack.preferredTransform).size;
        if (CGSizeEqualToSize(normalizedVideoSize, CGSizeZero))
        {
            if (CGSizeEqualToSize(videoTrack.naturalSize, CGSizeZero))
            {
                TGLog(@"[VideoConverter] ERROR: Video track natural size is zero");
                fail();
                return;
            }
            else
            {
                TGLog(@"[VideoConverter] WARNING: Setting natural size as normalized");
                normalizedVideoSize = videoTrack.naturalSize;
            }
        }
        
        bool hasCropping = !CGRectEqualToRect(_cropRect, CGRectZero);
        CGRect cropRect = hasCropping ? [self _normalizeCropRect:_cropRect] : CGRectMake(0, 0, normalizedVideoSize.width, normalizedVideoSize.height);
        
        CGSize resultSize = _asGif ? TGVideoConverterGifResultSize : TGVideoConverterResultSize;
        CGSize outputVideoDimensions = TGFitSizeF(cropRect.size, resultSize);
        outputVideoDimensions = CGSizeMake(ceil(outputVideoDimensions.width), ceil(outputVideoDimensions.height));
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
          AVVideoAverageBitRateKey: @(_asGif ? TGVideoConverterGifVideoBitrate : TGVideoConverterVideoBitrate),
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
        CGAffineTransform rotationTransform = TGVideoTransformForCrop(_cropOrientation, cropRect.size, _cropMirorred);
        CGAffineTransform finalTransform = CGAffineTransformConcat(transform, rotationTransform);
        [transformer setTransform:finalTransform atTime:kCMTimeZero];
        
        instruction.layerInstructions = [NSArray arrayWithObject:transformer];
        videoComposition.instructions = [NSArray arrayWithObject:instruction];
        
        UIImage *overlayImage = (_overlayImagePath != nil) ? [UIImage imageWithContentsOfFile:_overlayImagePath] : nil;
        if (overlayImage != nil)
        {
            CALayer *parentLayer = [CALayer layer];
            parentLayer.frame = CGRectMake(0, 0, videoComposition.renderSize.width, videoComposition.renderSize.height);
            
            CALayer *videoLayer = [CALayer layer];
            videoLayer.frame = parentLayer.frame;
            [parentLayer addSublayer:videoLayer];
            
            CGSize parentSize = CGSizeMake(TGOrientationIsSideward(_cropOrientation, NULL) ? parentLayer.bounds.size.height : parentLayer.bounds.size.width, TGOrientationIsSideward(_cropOrientation, NULL) ? parentLayer.bounds.size.width : parentLayer.bounds.size.height);
            CGSize size = CGSizeMake(parentSize.width * normalizedVideoSize.width / cropRect.size.width, parentSize.height * normalizedVideoSize.height / cropRect.size.height);
            CGPoint origin = CGPointMake(-parentSize.width / cropRect.size.width * cropRect.origin.x,  -parentSize.height / cropRect.size.height * (normalizedVideoSize.height - cropRect.size.height - cropRect.origin.y));
             
            CALayer *rotationLayer = [CALayer layer];
            rotationLayer.frame = CGRectMake(0, 0, parentSize.width, parentSize.height);
            [parentLayer addSublayer:rotationLayer];
            
            UIImageOrientation orientation = TGMirrorSidewardOrientation(_cropOrientation);
            CATransform3D transform = CATransform3DMakeTranslation(rotationLayer.frame.size.width / 2.0f, rotationLayer.frame.size.height / 2.0f, 0.0f);
            transform = CATransform3DRotate(transform, TGRotationForOrientation(orientation), 0.0f, 0.0f, 1.0f);
            transform = CATransform3DTranslate(transform, -parentLayer.bounds.size.width / 2.0f, -parentLayer.bounds.size.height / 2.0f, 0.0f);
            rotationLayer.transform = transform;
            rotationLayer.frame = parentLayer.frame;
            
            CALayer *overlayLayer = [CALayer layer];
            overlayLayer.contents = (id)overlayImage.CGImage;
            overlayLayer.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
            [rotationLayer addSublayer:overlayLayer];
                        
            videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
        }
        
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:composition];
        imageGenerator.videoComposition = videoComposition;
        imageGenerator.maximumSize = resultSize;
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
        
        if (!_asGif && audioTrack != nil)
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
                    
                    if (completion != nil)
                        completion(_tempFilePath, outputVideoDimensions, videoDuration, previewImage, liveData);
                }];
            }];
        };
        
        [videoWriterInput requestMediaDataWhenReadyOnQueue:_queue.nativeQueue usingBlock:^
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
                             completion(nil, CGSizeZero, 0.0, nil, nil);
                         
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
                                                 [audioWriterInput appendSampleBuffer:nextBuffer];
                                             CFRelease(nextBuffer);
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
                                                         completion(nil, CGSizeZero, 0.0, nil, nil);
                                                     
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
                                 completion(nil, CGSizeZero, 0.0, nil, nil);
                             
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
        [ActionStageInstance() removeWatcher:self];
        
        [_assetWriter cancelWriting];
    }];
}

+ (void)computeHashForVideoAsset:(id)asset hasTrimming:(bool)hasTrimming isCropped:(bool)isCropped highDefinition:(bool)highDefinition completion:(void (^)(NSString *hash))completion
{
    if (hasTrimming || isCropped)
    {
        if (completion != nil)
            completion(nil);
        return;
    }
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    NSString *(^readAssetWithURL)(NSURL *, NSData *) = ^NSString *(NSURL *url, NSData *timingData)
    {
        if (url == nil)
            return nil;
        
        NSError *error;
        NSData *fileData = [NSData dataWithContentsOfURL:url
                                                 options:NSDataReadingMappedIfSafe
                                                   error:&error];
        if (error != nil)
            return nil;
        
        return [self hashForVideoWithSize:fileData.length highDefinition:highDefinition timingData:timingData dataReadBlock:^(uint8_t *buffer, NSUInteger offset, NSUInteger length)
        {
            [fileData getBytes:buffer range:NSMakeRange(offset, length)];
        }];
    };
    
    NSString *hash = nil;
    if ([asset isKindOfClass:[AVURLAsset class]])
    {
        hash = readAssetWithURL(((AVURLAsset *)asset).URL, nil);
    }
    else if ([asset isKindOfClass:[AVComposition class]])
    {
        AVComposition *composition = (AVComposition *)asset;
        AVCompositionTrack *videoTrack = nil;
        for (AVCompositionTrack *track in composition.tracks)
        {
            if ([track.mediaType isEqualToString:AVMediaTypeVideo])
            {
                videoTrack = track;
                break;
            }
        }
        
        if (videoTrack != nil)
        {
            AVCompositionTrackSegment *firstSegment = videoTrack.segments.firstObject;
            
            NSMutableData *timingData = [[NSMutableData alloc] init];
            for (AVCompositionTrackSegment *segment in videoTrack.segments)
            {
                CMTimeRange targetRange = segment.timeMapping.target;
                CMTimeValue startTime = targetRange.start.value / targetRange.start.timescale;
                CMTimeValue duration = targetRange.duration.value / targetRange.duration.timescale;
                [timingData appendBytes:&startTime length:sizeof(startTime)];
                [timingData appendBytes:&duration length:sizeof(duration)];
            }
            
            hash = readAssetWithURL(firstSegment.sourceURL, timingData);
        }
    }
    else if ([asset isKindOfClass:[ALAsset class]])
    {
        ALAssetRepresentation *representation = ((ALAsset *)asset).defaultRepresentation;
        
        hash = [self hashForVideoWithSize:(NSUInteger)representation.size highDefinition:highDefinition timingData:nil dataReadBlock:^(uint8_t *buffer, NSUInteger offset, NSUInteger length)
        {
            [representation getBytes:buffer fromOffset:offset length:length error:nil];
        }];
    }
    
    if (hash != nil)
    {
        TGLog(@"Computed video hash in %f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0);
        
        if (completion != nil)
            completion(hash);
    }
    else
    {
        if (completion != nil)
            completion(nil);
    }
}

+ (NSString *)hashForVideoWithSize:(NSUInteger)size highDefinition:(BOOL)highDefinition timingData:(NSData *)timingData dataReadBlock:(void (^)(uint8_t *buffer, NSUInteger offset, NSUInteger length))dataReadBlock
{
    const NSUInteger bufSize = 1024;
    const NSUInteger numberOfBuffersToRead = 32;
    uint8_t buf[bufSize];
    
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    
    CC_MD5_Update(&md5, &size, sizeof(size));
    const char *SDString = "SD";
    const char *HDString = "HD";
    if (highDefinition)
        CC_MD5_Update(&md5, HDString, (CC_LONG)strlen(HDString));
    else
        CC_MD5_Update(&md5, SDString, (CC_LONG)strlen(SDString));
    
    if (timingData != nil)
        CC_MD5_Update(&md5, timingData.bytes, (CC_LONG)timingData.length);
    
    for (NSUInteger i = 0; (i < size) && (i < bufSize * numberOfBuffersToRead); i += bufSize)
    {
        dataReadBlock(buf, i, bufSize);
        CC_MD5_Update(&md5, buf, bufSize);
    }
    
    for (NSUInteger i = size - MIN(size, bufSize * numberOfBuffersToRead); i < size; i += bufSize)
    {
        dataReadBlock(buf, i, bufSize);
        CC_MD5_Update(&md5, buf, bufSize);
    }
    
    unsigned char md5Buffer[16];
    CC_MD5_Final(md5Buffer, &md5);
    NSString *hash = [[NSString alloc] initWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", md5Buffer[0], md5Buffer[1], md5Buffer[2], md5Buffer[3], md5Buffer[4], md5Buffer[5], md5Buffer[6], md5Buffer[7], md5Buffer[8], md5Buffer[9], md5Buffer[10], md5Buffer[11], md5Buffer[12], md5Buffer[13], md5Buffer[14], md5Buffer[15]];
    
    return hash;
}

+ (SSignal *)convertSignalForAVAsset:(AVAsset *)asset adjustments:(TGVideoEditAdjustments *)adjustments liveUpload:(bool)liveUpload passthrough:(bool)__unused passthrough
{
    if (asset == nil)
        return [SSignal fail:nil];
    
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGVideoConverter *videoConverter = [[TGVideoConverter alloc] initForConvertationWithAVAsset:asset liveUpload:liveUpload];
        
        if (adjustments != nil)
        {
            videoConverter.cropOrientation = adjustments.cropOrientation;
            videoConverter.cropMirorred = adjustments.cropMirrored;
            if ([adjustments cropAppliedForAvatar:false])
            {
                videoConverter.cropRect = adjustments.cropRect;
            }
            if (adjustments.trimStartValue > DBL_EPSILON || adjustments.trimEndValue > DBL_EPSILON)
            {
                videoConverter.trimRange = CMTimeRangeMake(CMTimeMakeWithSeconds(adjustments.trimStartValue , NSEC_PER_SEC), CMTimeMakeWithSeconds((adjustments.trimEndValue - adjustments.trimStartValue), NSEC_PER_SEC));
            }
            videoConverter.overlayImagePath = adjustments.paintingData.imagePath;
            videoConverter.asGif = adjustments.sendAsGif;
        }
        
        [videoConverter processWithCompletion:^(NSString *filePath, CGSize dimensions, NSTimeInterval duration, UIImage *previewImage, TGLiveUploadActorData *liveUploadData)
        {
            if (filePath != nil)
            {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                dict[@"fileUrl"] = [NSURL fileURLWithPath:filePath];
                dict[@"dimensions"] = [NSValue valueWithCGSize:dimensions];
                dict[@"duration"] = @(duration);
                if (previewImage != nil)
                    dict[@"previewImage"] = previewImage;
                if (liveUploadData != nil)
                    dict[@"liveUploadData"] = liveUploadData;
                
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

+ (SSignal *)hashSignalForAVAsset:(AVAsset *)avAsset
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        [TGVideoConverter computeHashForVideoAsset:avAsset hasTrimming:false isCropped:false highDefinition:false completion:^(NSString *hash)
        {
            [subscriber putNext:hash];
            [subscriber putCompletion];
        }];
        return nil;
    }];
}

@end
