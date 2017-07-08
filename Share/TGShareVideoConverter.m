#import "TGShareVideoConverter.h"
#import <UIKit/UIKit.h>

#import <LegacyDatabase/LegacyDatabase.h>

#import <sys/stat.h>

typedef enum
{
    TGMediaVideoConversionPresetCompressedDefault,
    TGMediaVideoConversionPresetCompressedVeryLow,
    TGMediaVideoConversionPresetCompressedLow,
    TGMediaVideoConversionPresetCompressedMedium,
    TGMediaVideoConversionPresetCompressedHigh,
    TGMediaVideoConversionPresetCompressedVeryHigh,
    TGMediaVideoConversionPresetAnimation
} TGMediaVideoConversionPreset;

@interface TGShareMediaVideoConversionResult : NSObject

@property (nonatomic, readonly) NSURL *fileURL;
@property (nonatomic, readonly) NSUInteger fileSize;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) CGSize dimensions;
@property (nonatomic, readonly) UIImage *coverImage;
@property (nonatomic, readonly) id liveUploadData;

- (NSDictionary *)dictionary;

@end


@interface TGMediaVideoConversionPresetSettings : NSObject

+ (CGSize)maximumSizeForPreset:(TGMediaVideoConversionPreset)preset;
+ (NSDictionary *)videoSettingsForPreset:(TGMediaVideoConversionPreset)preset dimensions:(CGSize)dimensions;

+ (NSDictionary *)audioSettingsForPreset:(TGMediaVideoConversionPreset)preset;
+ (bool)keepAudioForPreset:(TGMediaVideoConversionPreset)preset;

+ (NSInteger)_videoBitrateKbpsForPreset:(TGMediaVideoConversionPreset)preset;
+ (NSInteger)_audioBitrateKbpsForPreset:(TGMediaVideoConversionPreset)preset;
+ (NSInteger)_audioChannelsCountForPreset:(TGMediaVideoConversionPreset)preset;

@end


@interface TGMediaSampleBufferProcessor : NSObject
{
    AVAssetReaderOutput *_assetReaderOutput;
    AVAssetWriterInput *_assetWriterInput;
    
    SQueue *_queue;
    bool _finished;
    
    void (^_completionBlock)(void);
}

- (instancetype)initWithAssetReaderOutput:(AVAssetReaderOutput *)assetReaderOutput assetWriterInput:(AVAssetWriterInput *)assetWriterInput;

- (void)startWithTimeRange:(CMTimeRange)timeRange progressBlock:(void (^)(CGFloat progress))progressBlock completionBlock:(void (^)(void))completionBlock;
- (void)cancel;

@end


@interface TGMediaVideoConversionContext : NSObject

@property (nonatomic, readonly) bool cancelled;
@property (nonatomic, readonly) bool finished;

@property (nonatomic, readonly) SQueue *queue;
@property (nonatomic, readonly) SSubscriber *subscriber;

@property (nonatomic, readonly) AVAssetReader *assetReader;
@property (nonatomic, readonly) AVAssetWriter *assetWriter;

@property (nonatomic, readonly) AVAssetImageGenerator *imageGenerator;

@property (nonatomic, readonly) TGMediaSampleBufferProcessor *videoProcessor;
@property (nonatomic, readonly) TGMediaSampleBufferProcessor *audioProcessor;

@property (nonatomic, readonly) CMTimeRange timeRange;
@property (nonatomic, readonly) CGSize dimensions;
@property (nonatomic, readonly) UIImage *coverImage;

+ (instancetype)contextWithQueue:(SQueue *)queue subscriber:(SSubscriber *)subscriber;

- (instancetype)cancelledContext;
- (instancetype)finishedContext;

- (instancetype)addImageGenerator:(AVAssetImageGenerator *)imageGenerator;
- (instancetype)addCoverImage:(UIImage *)coverImage;
- (instancetype)contextWithAssetReader:(AVAssetReader *)assetReader assetWriter:(AVAssetWriter *)assetWriter videoProcessor:(TGMediaSampleBufferProcessor *)videoProcessor audioProcessor:(TGMediaSampleBufferProcessor *)audioProcessor timeRange:(CMTimeRange)timeRange dimensions:(CGSize)dimensions;

@end


@interface TGShareMediaVideoConversionResult ()

+ (instancetype)resultWithFileURL:(NSURL *)fileUrl fileSize:(NSUInteger)fileSize duration:(NSTimeInterval)duration dimensions:(CGSize)dimensions coverImage:(UIImage *)coverImage liveUploadData:(id)livaUploadData;

@end

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

CGAffineTransform TGVideoTransformForCrop(UIImageOrientation orientation, CGSize size, bool mirrored)
{
    if (TGOrientationIsSideward(orientation, NULL))
        size = CGSizeMake(size.height, size.width);
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(size.width / 2.0f, size.height / 2.0f);
    switch (orientation)
    {
        case UIImageOrientationDown:
        {
            transform = CGAffineTransformRotate(transform, M_PI);
        }
            break;
            
        case UIImageOrientationRight:
        {
            transform = CGAffineTransformRotate(transform, M_PI_2);
        }
            break;
            
        case UIImageOrientationLeft:
        {
            transform = CGAffineTransformRotate(transform, -M_PI_2);
        }
            break;
            
        default:
            break;
    }
    
    if (mirrored)
        transform = CGAffineTransformScale(transform, -1.0f, 1.0f);
    
    if (TGOrientationIsSideward(orientation, NULL))
        size = CGSizeMake(size.height, size.width);
    
    transform = CGAffineTransformTranslate(transform, -size.width / 2.0f, -size.height / 2.0f);
    
    return transform;
}

@implementation TGShareVideoConverter

+ (SSignal *)convertAVAsset:(AVAsset *)avAsset
{
    SQueue *queue = [[SQueue alloc] init];
    
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        SAtomic *context = [[SAtomic alloc] initWithValue:[TGMediaVideoConversionContext contextWithQueue:queue subscriber:subscriber]];
        NSURL *outputUrl = [self _randomTemporaryURL];
        
        NSArray *requiredKeys = @[ @"tracks", @"duration" ];
        [avAsset loadValuesAsynchronouslyForKeys:requiredKeys completionHandler:^
        {
            [queue dispatch:^
            {
                if (((TGMediaVideoConversionContext *)context.value).cancelled)
                    return;
                
                CGSize dimensions = [avAsset tracksWithMediaType:AVMediaTypeVideo].firstObject.naturalSize;
                TGMediaVideoConversionPreset preset = TGMediaVideoConversionPresetCompressedMedium;
                if (!CGSizeEqualToSize(dimensions, CGSizeZero))
                {
                    TGMediaVideoConversionPreset bestPreset = [self bestAvailablePresetForDimensions:dimensions];
                    if (preset > bestPreset)
                        preset = bestPreset;
                }
                
                NSError *error = nil;
                for (NSString *key in requiredKeys)
                {
                    if ([avAsset statusOfValueForKey:key error:&error] != AVKeyValueStatusLoaded || error != nil)
                    {
                        [subscriber putError:error];
                        return;
                    }
                }
                
                NSString *outputPath = outputUrl.path;
                NSFileManager *fileManager = [NSFileManager defaultManager];
                if ([fileManager fileExistsAtPath:outputPath])
                {
                    [fileManager removeItemAtPath:outputPath error:&error];
                    if (error != nil)
                    {
                        [subscriber putError:error];
                        return;
                    }
                }
                
                if (![self setupAssetReaderWriterForAVAsset:avAsset outputURL:outputUrl preset:preset inhibitAudio:false conversionContext:context error:&error])
                {
                    [subscriber putError:error];
                    return;
                }
                
                [self processWithConversionContext:context completionBlock:^
                {
                    TGMediaVideoConversionContext *resultContext = context.value;
                    [resultContext.imageGenerator generateCGImagesAsynchronouslyForTimes:@[ [NSValue valueWithCMTime:resultContext.timeRange.start] ] completionHandler:^(__unused CMTime requestedTime, CGImageRef  _Nullable image, __unused CMTime actualTime, AVAssetImageGeneratorResult result, __unused NSError * _Nullable error)
                    {
                        UIImage *coverImage = nil;
                        if (result == AVAssetImageGeneratorSucceeded)
                            coverImage = [UIImage imageWithCGImage:image];
                        
                        [context modify:^id(TGMediaVideoConversionContext *resultContext)
                        {
                            TGShareMediaVideoConversionResult *result = [TGShareMediaVideoConversionResult resultWithFileURL:outputUrl fileSize:0 duration:CMTimeGetSeconds(resultContext.timeRange.duration) dimensions:resultContext.dimensions coverImage:coverImage liveUploadData:nil];
                            [subscriber putNext:result.dictionary];
                            return [resultContext finishedContext];
                        }];
                        
                        [subscriber putCompletion];
                    }];
                }];
            }];
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [context modify:^id(TGMediaVideoConversionContext *currentContext)
            {
                if (currentContext.finishedContext)
                    return currentContext;
                
                [currentContext.videoProcessor cancel];
                [currentContext.audioProcessor cancel];
                
                return [currentContext cancelledContext];
            }];
        }];
    }];
}

+ (AVAssetReaderVideoCompositionOutput *)setupVideoCompositionOutputWithAVAsset:(AVAsset *)avAsset composition:(AVMutableComposition *)composition videoTrack:(AVAssetTrack *)videoTrack preset:(TGMediaVideoConversionPreset)preset timeRange:(CMTimeRange)timeRange outputSettings:(NSDictionary **)outputSettings dimensions:(CGSize *)dimensions conversionContext:(SAtomic *)conversionContext
{
    CGSize transformedSize = CGRectApplyAffineTransform((CGRect){CGPointZero, videoTrack.naturalSize}, videoTrack.preferredTransform).size;;
    CGRect transformedRect = CGRectMake(0, 0, transformedSize.width, transformedSize.height);
    if (CGSizeEqualToSize(transformedRect.size, CGSizeZero))
        transformedRect = CGRectMake(0, 0, videoTrack.naturalSize.width, videoTrack.naturalSize.height);
    
    CGRect cropRect = transformedRect;
    
    CGSize maxDimensions = [TGMediaVideoConversionPresetSettings maximumSizeForPreset:preset];
    CGSize outputDimensions = TGFitSize(cropRect.size, maxDimensions);
    outputDimensions = CGSizeMake(ceil(outputDimensions.width), ceil(outputDimensions.height));
    outputDimensions = [self _renderSizeWithCropSize:outputDimensions];
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMake(1, (int32_t)videoTrack.nominalFrameRate);
    
    AVMutableCompositionTrack *trimVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [trimVideoTrack insertTimeRange:timeRange ofTrack:videoTrack atTime:kCMTimeZero error:NULL];
    
    videoComposition.renderSize = [self _renderSizeWithCropSize:cropRect.size];
    
    bool mirrored = false;
    UIImageOrientation videoOrientation = TGVideoOrientationForAsset(avAsset, &mirrored);
    CGAffineTransform transform = TGVideoTransformForOrientation(videoOrientation, videoTrack.naturalSize, cropRect, mirrored);
    //CGAffineTransform rotationTransform = TGVideoTransformForCrop(adjustments.cropOrientation, cropRect.size, adjustments.cropMirrored);
    CGAffineTransform finalTransform = transform; // CGAffineTransformConcat(transform, rotationTransform);
    
    AVMutableVideoCompositionLayerInstruction *transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:trimVideoTrack];
    [transformer setTransform:finalTransform atTime:kCMTimeZero];
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, timeRange.duration);
    instruction.layerInstructions = [NSArray arrayWithObject:transformer];
    videoComposition.instructions = [NSArray arrayWithObject:instruction];
    
    
    AVAssetReaderVideoCompositionOutput *output = [[AVAssetReaderVideoCompositionOutput alloc] initWithVideoTracks:[composition tracksWithMediaType:AVMediaTypeVideo] videoSettings:@{ (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) }];
    output.videoComposition = videoComposition;
    
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:composition];
    imageGenerator.videoComposition = videoComposition;
    imageGenerator.maximumSize = maxDimensions;
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    
    [conversionContext modify:^id(TGMediaVideoConversionContext *context)
    {
        return [context addImageGenerator:imageGenerator];
    }];
    
    *outputSettings = [TGMediaVideoConversionPresetSettings videoSettingsForPreset:preset dimensions:outputDimensions];
    *dimensions = outputDimensions;
    
    return output;
}

+ (bool)setupAssetReaderWriterForAVAsset:(AVAsset *)avAsset outputURL:(NSURL *)outputURL preset:(TGMediaVideoConversionPreset)preset inhibitAudio:(bool)inhibitAudio conversionContext:(SAtomic *)outConversionContext error:(NSError **)error
{
    TGMediaSampleBufferProcessor *videoProcessor = nil;
    TGMediaSampleBufferProcessor *audioProcessor = nil;
    
    AVAssetTrack *audioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    AVAssetTrack *videoTrack = [[avAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    if (videoTrack == nil)
        return false;
    
    CGSize dimensions = CGSizeZero;
    CMTimeRange timeRange = videoTrack.timeRange;
    timeRange = CMTimeRangeMake(CMTimeAdd(timeRange.start, CMTimeMake(10, 100)), CMTimeSubtract(timeRange.duration, CMTimeMake(10, 100)));
    
    NSDictionary *outputSettings = nil;
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVAssetReaderVideoCompositionOutput *output = [self setupVideoCompositionOutputWithAVAsset:avAsset composition:composition videoTrack:videoTrack preset:preset timeRange:timeRange outputSettings:&outputSettings dimensions:&dimensions conversionContext:outConversionContext];
    
    AVAssetReader *assetReader = [[AVAssetReader alloc] initWithAsset:composition error:error];
    if (assetReader == nil)
        return false;
    
    AVAssetWriter *assetWriter = [[AVAssetWriter alloc] initWithURL:outputURL fileType:AVFileTypeMPEG4 error:error];
    if (assetWriter == nil)
        return false;
    
    [assetReader addOutput:output];
    
    AVAssetWriterInput *input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
    [assetWriter addInput:input];
    
    videoProcessor = [[TGMediaSampleBufferProcessor alloc] initWithAssetReaderOutput:output assetWriterInput:input];
    
    if (!inhibitAudio && [TGMediaVideoConversionPresetSettings keepAudioForPreset:preset] && audioTrack != nil)
    {
        AVMutableCompositionTrack *trimAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [trimAudioTrack insertTimeRange:timeRange ofTrack:audioTrack atTime:kCMTimeZero error:NULL];
        
        AVAssetReaderOutput *output = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:trimAudioTrack outputSettings:@{ AVFormatIDKey: @(kAudioFormatLinearPCM) }];
        [assetReader addOutput:output];
        
        AVAssetWriterInput *input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:[TGMediaVideoConversionPresetSettings audioSettingsForPreset:preset]];
        [assetWriter addInput:input];
        
        audioProcessor = [[TGMediaSampleBufferProcessor alloc] initWithAssetReaderOutput:output assetWriterInput:input];
    }
    
    [outConversionContext modify:^id(TGMediaVideoConversionContext *currentContext)
    {
        return [currentContext contextWithAssetReader:assetReader assetWriter:assetWriter videoProcessor:videoProcessor audioProcessor:audioProcessor timeRange:timeRange dimensions:dimensions];
    }];
    
    return true;
}

+ (void)processWithConversionContext:(SAtomic *)context_ completionBlock:(void (^)(void))completionBlock
{
    TGMediaVideoConversionContext *context = [context_ value];
    
    if (![context.assetReader startReading])
    {
        [context.subscriber putError:context.assetReader.error];
        return;
    }
    
    if (![context.assetWriter startWriting])
    {
        [context.subscriber putError:context.assetWriter.error];
        return;
    }
    
    dispatch_group_t dispatchGroup = dispatch_group_create();
    
    [context.assetWriter startSessionAtSourceTime:kCMTimeZero];
    
    if (context.audioProcessor != nil)
    {
        dispatch_group_enter(dispatchGroup);
        [context.audioProcessor startWithTimeRange:context.timeRange progressBlock:nil completionBlock:^
        {
            dispatch_group_leave(dispatchGroup);
        }];
    }
    
    if (context.videoProcessor != nil)
    {
        dispatch_group_enter(dispatchGroup);
        
        SSubscriber *subscriber = context.subscriber;
        [context.videoProcessor startWithTimeRange:context.timeRange progressBlock:^(CGFloat progress)
        {
            [subscriber putNext:@(progress)];
        } completionBlock:^
        {
            dispatch_group_leave(dispatchGroup);
        }];
    }
    
    dispatch_group_notify(dispatchGroup, context.queue._dispatch_queue, ^
    {
        TGMediaVideoConversionContext *context = [context_ value];
        if (context.cancelled)
        {
            [context.assetReader cancelReading];
            [context.assetWriter cancelWriting];
        }
        else
        {
            if (context.assetReader.status != AVAssetReaderStatusFailed)
            {
                [context.assetWriter finishWritingWithCompletionHandler:^
                {
                    if (context.assetWriter.status != AVAssetWriterStatusFailed)
                        completionBlock();
                    else
                        [context.subscriber putError:context.assetWriter.error];
                }];
            }
            else
            {
                [context.subscriber putError:context.assetReader.error];
            }
        }
        
    });
}

#pragma mark - Miscellaneous

+ (CGSize)_renderSizeWithCropSize:(CGSize)cropSize
{
    const CGFloat blockSize = 16.0f;
    
    CGFloat renderWidth = floor(cropSize.width / blockSize) * blockSize;
    CGFloat renderHeight = floor(cropSize.height * renderWidth / cropSize.width);
    if (fmod(renderHeight, blockSize) != 0)
        renderHeight = floor(cropSize.height / blockSize) * blockSize;
    return CGSizeMake(renderWidth, renderHeight);
}

+ (NSURL *)_randomTemporaryURL
{
    return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%x.tmp", (int)arc4random()]]];
}

+ (NSUInteger)estimatedSizeForPreset:(TGMediaVideoConversionPreset)preset duration:(NSTimeInterval)duration hasAudio:(bool)hasAudio
{
    NSInteger bitrate = [TGMediaVideoConversionPresetSettings _videoBitrateKbpsForPreset:preset];
    if (hasAudio)
        bitrate += [TGMediaVideoConversionPresetSettings _audioBitrateKbpsForPreset:preset] * [TGMediaVideoConversionPresetSettings _audioChannelsCountForPreset:preset];
    
    NSInteger dataRate = bitrate * 1000 / 8;
    return (NSInteger)(dataRate * duration);
}

+ (TGMediaVideoConversionPreset)bestAvailablePresetForDimensions:(CGSize)dimensions
{
    TGMediaVideoConversionPreset preset = TGMediaVideoConversionPresetCompressedVeryHigh;
    CGFloat maxSide = MAX(dimensions.width, dimensions.height);
    for (NSInteger i = TGMediaVideoConversionPresetCompressedVeryHigh; i >= TGMediaVideoConversionPresetCompressedMedium; i--)
    {
        CGFloat presetMaxSide = [TGMediaVideoConversionPresetSettings maximumSizeForPreset:(TGMediaVideoConversionPreset)i].width;
        if (maxSide >= presetMaxSide)
            break;
        
        preset = (TGMediaVideoConversionPreset)i;
    }
    return preset;
}

@end


static CGFloat progressOfSampleBufferInTimeRange(CMSampleBufferRef sampleBuffer, CMTimeRange timeRange)
{
    CMTime progressTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    CMTime sampleDuration = CMSampleBufferGetDuration(sampleBuffer);
    if (CMTIME_IS_NUMERIC(sampleDuration))
        progressTime = CMTimeAdd(progressTime, sampleDuration);
    return MAX(0.0f, MIN(1.0f, CMTimeGetSeconds(progressTime) / CMTimeGetSeconds(timeRange.duration)));
}


@implementation TGMediaSampleBufferProcessor

- (instancetype)initWithAssetReaderOutput:(AVAssetReaderOutput *)assetReaderOutput assetWriterInput:(AVAssetWriterInput *)assetWriterInput
{
    self = [super init];
    if (self != nil)
    {
        _assetReaderOutput = assetReaderOutput;
        _assetWriterInput = assetWriterInput;
        
        _queue = [[SQueue alloc] init];
        _finished = false;
    }
    return self;
}

- (void)startWithTimeRange:(CMTimeRange)timeRange progressBlock:(void (^)(CGFloat progress))progressBlock completionBlock:(void (^)(void))completionBlock
{
    _completionBlock = [completionBlock copy];
    
    [_assetWriterInput requestMediaDataWhenReadyOnQueue:_queue._dispatch_queue usingBlock:^
     {
         if (_finished)
             return;
         
         bool ended = false;
         while ([_assetWriterInput isReadyForMoreMediaData] && !ended)
         {
             CMSampleBufferRef sampleBuffer = [_assetReaderOutput copyNextSampleBuffer];
             if (sampleBuffer != NULL)
             {
                 if (progressBlock != nil)
                     progressBlock(progressOfSampleBufferInTimeRange(sampleBuffer, timeRange));
                 
                 bool success = [_assetWriterInput appendSampleBuffer:sampleBuffer];
                 CFRelease(sampleBuffer);
                 
                 ended = !success;
             }
             else
             {
                 ended = true;
             }
         }
         
         if (ended)
             [self _finish];
     }];
}

- (void)cancel
{
    [_queue dispatch:^
     {
         [self _finish];
     }];
}

- (void)_finish
{
    bool didFinish = _finished;
    _finished = true;
    
    if (!didFinish)
    {
        [_assetWriterInput markAsFinished];
        
        if (_completionBlock != nil)
        {
            void (^completionBlock)(void) = [_completionBlock copy];
            _completionBlock = nil;
            completionBlock();
        }
    }
}

@end


@implementation TGMediaVideoConversionContext

+ (instancetype)contextWithQueue:(SQueue *)queue subscriber:(SSubscriber *)subscriber
{
    TGMediaVideoConversionContext *context = [[TGMediaVideoConversionContext alloc] init];
    context->_queue = queue;
    context->_subscriber = subscriber;
    return context;
}

- (instancetype)cancelledContext
{
    TGMediaVideoConversionContext *context = [[TGMediaVideoConversionContext alloc] init];
    context->_queue = _queue;
    context->_subscriber = _subscriber;
    context->_cancelled = true;
    context->_assetReader = _assetReader;
    context->_assetWriter = _assetWriter;
    context->_videoProcessor = _videoProcessor;
    context->_audioProcessor = _audioProcessor;
    context->_timeRange = _timeRange;
    context->_dimensions = _dimensions;
    context->_coverImage = _coverImage;
    context->_imageGenerator = _imageGenerator;
    return context;
}

- (instancetype)finishedContext
{
    TGMediaVideoConversionContext *context = [[TGMediaVideoConversionContext alloc] init];
    context->_queue = _queue;
    context->_subscriber = _subscriber;
    context->_cancelled = false;
    context->_finished = true;
    context->_assetReader = _assetReader;
    context->_assetWriter = _assetWriter;
    context->_videoProcessor = _videoProcessor;
    context->_audioProcessor = _audioProcessor;
    context->_timeRange = _timeRange;
    context->_dimensions = _dimensions;
    context->_coverImage = _coverImage;
    context->_imageGenerator = _imageGenerator;
    return context;
}

- (instancetype)addImageGenerator:(AVAssetImageGenerator *)imageGenerator
{
    TGMediaVideoConversionContext *context = [[TGMediaVideoConversionContext alloc] init];
    context->_queue = _queue;
    context->_subscriber = _subscriber;
    context->_cancelled = _cancelled;
    context->_assetReader = _assetReader;
    context->_assetWriter = _assetWriter;
    context->_videoProcessor = _videoProcessor;
    context->_audioProcessor = _audioProcessor;
    context->_timeRange = _timeRange;
    context->_dimensions = _dimensions;
    context->_coverImage = _coverImage;
    context->_imageGenerator = imageGenerator;
    return context;
}

- (instancetype)addCoverImage:(UIImage *)coverImage
{
    TGMediaVideoConversionContext *context = [[TGMediaVideoConversionContext alloc] init];
    context->_queue = _queue;
    context->_subscriber = _subscriber;
    context->_cancelled = _cancelled;
    context->_assetReader = _assetReader;
    context->_assetWriter = _assetWriter;
    context->_videoProcessor = _videoProcessor;
    context->_audioProcessor = _audioProcessor;
    context->_timeRange = _timeRange;
    context->_dimensions = _dimensions;
    context->_coverImage = coverImage;
    context->_imageGenerator = _imageGenerator;
    return context;
}

- (instancetype)contextWithAssetReader:(AVAssetReader *)assetReader assetWriter:(AVAssetWriter *)assetWriter videoProcessor:(TGMediaSampleBufferProcessor *)videoProcessor audioProcessor:(TGMediaSampleBufferProcessor *)audioProcessor timeRange:(CMTimeRange)timeRange dimensions:(CGSize)dimensions
{
    TGMediaVideoConversionContext *context = [[TGMediaVideoConversionContext alloc] init];
    context->_queue = _queue;
    context->_subscriber = _subscriber;
    context->_cancelled = _cancelled;
    context->_assetReader = assetReader;
    context->_assetWriter = assetWriter;
    context->_videoProcessor = videoProcessor;
    context->_audioProcessor = audioProcessor;
    context->_timeRange = timeRange;
    context->_dimensions = dimensions;
    context->_coverImage = _coverImage;
    context->_imageGenerator = _imageGenerator;
    return context;
}

@end


@implementation TGShareMediaVideoConversionResult

+ (instancetype)resultWithFileURL:(NSURL *)fileUrl fileSize:(NSUInteger)fileSize duration:(NSTimeInterval)duration dimensions:(CGSize)dimensions coverImage:(UIImage *)coverImage liveUploadData:(id)livaUploadData
{
    TGShareMediaVideoConversionResult *result = [[TGShareMediaVideoConversionResult alloc] init];
    result->_fileURL = fileUrl;
    result->_fileSize = fileSize;
    result->_duration = duration;
    result->_dimensions = dimensions;
    result->_coverImage = coverImage;
    result->_liveUploadData = livaUploadData;
    return result;
}

- (NSDictionary *)dictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"fileUrl"] = self.fileURL;
    dict[@"dimensions"] = [NSValue valueWithCGSize:self.dimensions];
    dict[@"duration"] = @(self.duration);
    if (self.coverImage != nil)
        dict[@"previewImage"] = self.coverImage;
    if (self.liveUploadData != nil)
        dict[@"liveUploadData"] = self.liveUploadData;
    return dict;
}

@end


@implementation TGMediaVideoConversionPresetSettings

+ (CGSize)maximumSizeForPreset:(TGMediaVideoConversionPreset)preset
{
    switch (preset)
    {
        case TGMediaVideoConversionPresetCompressedVeryLow:
            return (CGSize){ 480.0f, 480.0f };
            
        case TGMediaVideoConversionPresetCompressedLow:
            return (CGSize){ 640.0f, 640.0f };
            
        case TGMediaVideoConversionPresetCompressedMedium:
            return (CGSize){ 848.0f, 848.0f };
            
        case TGMediaVideoConversionPresetCompressedHigh:
            return (CGSize){ 1280.0f, 1280.0f };
            
        case TGMediaVideoConversionPresetCompressedVeryHigh:
            return (CGSize){ 1920.0f, 1920.0f };
            
        default:
            return (CGSize){ 640.0f, 640.0f };
    }
}

+ (bool)keepAudioForPreset:(TGMediaVideoConversionPreset)preset
{
    return preset != TGMediaVideoConversionPresetAnimation;
}

+ (NSDictionary *)audioSettingsForPreset:(TGMediaVideoConversionPreset)preset
{
    NSInteger bitrate = [self _audioBitrateKbpsForPreset:preset];
    NSInteger channels = [self _audioChannelsCountForPreset:preset];
    
    NSInteger sampleRate = bitrate >= 32 ? 44100 : 16000;
    
    AudioChannelLayout acl;
    bzero( &acl, sizeof(acl));
    acl.mChannelLayoutTag = channels > 1 ? kAudioChannelLayoutTag_Stereo : kAudioChannelLayoutTag_Mono;
    
    return @
    {
        AVFormatIDKey: @(kAudioFormatMPEG4AAC),
        AVSampleRateKey: @(sampleRate),
        AVEncoderBitRateKey: @(bitrate * 1000),
        AVNumberOfChannelsKey: @(channels),
        AVChannelLayoutKey: [NSData dataWithBytes:&acl length:sizeof(acl)]
    };
}

+ (NSDictionary *)videoSettingsForPreset:(TGMediaVideoConversionPreset)preset dimensions:(CGSize)dimensions
{
    NSDictionary *videoCleanApertureSettings = @
    {
        AVVideoCleanApertureWidthKey: @((NSInteger)dimensions.width),
        AVVideoCleanApertureHeightKey: @((NSInteger)dimensions.height),
        AVVideoCleanApertureHorizontalOffsetKey: @10,
        AVVideoCleanApertureVerticalOffsetKey: @10
    };
    
    NSDictionary *videoAspectRatioSettings = @
    {
        AVVideoPixelAspectRatioHorizontalSpacingKey: @3,
        AVVideoPixelAspectRatioVerticalSpacingKey: @3
    };
    
    NSDictionary *codecSettings = @
    {
        AVVideoAverageBitRateKey: @([self _videoBitrateKbpsForPreset:preset] * 1000),
        AVVideoCleanApertureKey: videoCleanApertureSettings,
        AVVideoPixelAspectRatioKey: videoAspectRatioSettings
    };
    
    return @
    {
        AVVideoCodecKey: AVVideoCodecH264,
        AVVideoCompressionPropertiesKey: codecSettings,
        AVVideoWidthKey: @((NSInteger)dimensions.width),
        AVVideoHeightKey: @((NSInteger)dimensions.height)
    };
}

+ (NSInteger)_videoBitrateKbpsForPreset:(TGMediaVideoConversionPreset)preset
{
    switch (preset)
    {
        case TGMediaVideoConversionPresetCompressedVeryLow:
            return 400;
            
        case TGMediaVideoConversionPresetCompressedLow:
            return 700;
            
        case TGMediaVideoConversionPresetCompressedMedium:
            return 1100;
            
        case TGMediaVideoConversionPresetCompressedHigh:
            return 2500;
            
        case TGMediaVideoConversionPresetCompressedVeryHigh:
            return 4000;
            
        default:
            return 700;
    }
}

+ (NSInteger)_audioBitrateKbpsForPreset:(TGMediaVideoConversionPreset)preset
{
    switch (preset)
    {
        case TGMediaVideoConversionPresetCompressedVeryLow:
            return 32;
            
        case TGMediaVideoConversionPresetCompressedLow:
            return 32;
            
        case TGMediaVideoConversionPresetCompressedMedium:
            return 64;
            
        case TGMediaVideoConversionPresetCompressedHigh:
            return 64;
            
        case TGMediaVideoConversionPresetCompressedVeryHigh:
            return 64;
            
        default:
            return 24;
    }
}

+ (NSInteger)_audioChannelsCountForPreset:(TGMediaVideoConversionPreset)preset
{
    switch (preset)
    {
        case TGMediaVideoConversionPresetCompressedVeryLow:
            return 1;
            
        case TGMediaVideoConversionPresetCompressedLow:
            return 1;
            
        case TGMediaVideoConversionPresetCompressedMedium:
            return 2;
            
        case TGMediaVideoConversionPresetCompressedHigh:
            return 2;
            
        case TGMediaVideoConversionPresetCompressedVeryHigh:
            return 2;
            
        default:
            return 1;
    }
}

@end
