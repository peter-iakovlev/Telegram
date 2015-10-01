#import "PGCameraCaptureSession.h"
#import "PGCameraMovieWriter.h"

#import "TGPhotoEditorUtils.h"

#import <Endian.h>

#import <Accelerate/Accelerate.h>

#import <AVFoundation/AVFoundation.h>
#import "ATQueue.h"

const CGSize PGCameraVideoCaptureSize = { 640, 480 };
const NSInteger PGCameraFrameRate = 24;

@interface PGCameraCaptureSession () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>
{
    PGCameraMode _currentMode;
    
    PGCameraPosition _preferredCameraPosition;
    
    PGCameraFlashMode _photoFlashMode;
    PGCameraFlashMode _videoFlashMode;
    
    AVCaptureDeviceInput *_videoInput;
    AVCaptureDeviceInput *_audioInput;
        
    AVCaptureDevice *_audioDevice;
    
    ATQueue *_videoQueue;
    ATQueue *_audioQueue;
    
    bool _captureNextFrame;
    bool _capturingForVideoThumbnail;
    
    NSInteger _frameRate;
    
    bool _initialized;
    
    AVCaptureVideoOrientation _captureVideoOrientation;
    bool _captureMirrored;
}

@property (nonatomic, copy) void(^capturedFrameCompletion)(UIImage *image);

@end

@implementation PGCameraCaptureSession

- (instancetype)initWithPreferredPosition:(PGCameraPosition)position
{
    self = [super init];
    if (self != nil)
    {
        _currentMode = PGCameraModePhoto;
        _photoFlashMode = PGCameraFlashModeOff;
        _videoFlashMode = PGCameraFlashModeOff;
        
        _videoQueue = [[ATQueue alloc] initWithName:@"org.telegram.cameraVideoCaptureQueue"];
        _audioQueue = [[ATQueue alloc] initWithName:@"org.telegram.cameraAudioCaptureQueue"];
        
        _preferredCameraPosition = position;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"Camera session: deaalloc");
    [_videoOutput setSampleBufferDelegate:nil queue:[ATQueue mainQueue].nativeQueue];
    [_audioOutput setSampleBufferDelegate:nil queue:[ATQueue mainQueue].nativeQueue];
}

- (void)performInitialConfigurationWithCompletion:(void (^)(void))completion
{
    NSLog(@"Camera session: initialization");
    _initialized = true;
    
    AVCaptureDevice *targetDevice = [PGCameraCaptureSession _deviceWithCameraPosition:_preferredCameraPosition];
    if (targetDevice == nil)
        targetDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _videoDevice = targetDevice;
        
    NSError *error = nil;
    if (_videoDevice != nil)
    {
        _preferredCameraPosition = [PGCameraCaptureSession _cameraPositionForDevicePosition:_videoDevice.position];
        
        _videoInput = [AVCaptureDeviceInput deviceInputWithDevice:_videoDevice error:&error];
        if (_videoInput != nil)
            [self addInput:_videoInput];
    }
    else
    {
        _videoInput = nil;
        TGLog(@"ERROR: camera can't create video device");
    }
    
    self.sessionPreset = AVCaptureSessionPresetPhoto;
    
    AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];
    if ([self canAddOutput:imageOutput])
    {
        [imageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
        [self addOutput:imageOutput];
        _imageOutput = imageOutput;
    }
    else
    {
        _imageOutput = nil;
        TGLog(@"ERROR: camera can't add still image output");
    }
    
    AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    if ([self canAddOutput:videoOutput])
    {
        videoOutput.alwaysDiscardsLateVideoFrames = true;
        [videoOutput setSampleBufferDelegate:self queue:_videoQueue.nativeQueue];

        //videoOutput.videoSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) };
        videoOutput.videoSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA) };
        [self addOutput:videoOutput];
        _videoOutput = videoOutput;
    }
    else
    {
        _videoOutput = nil;
        TGLog(@"ERROR: camera can't add video output");
    }
    
    [self _reconfigureDevice:self.videoDevice withBlock:^(AVCaptureDevice *device)
    {
        if (device.isLowLightBoostSupported)
            device.automaticallyEnablesLowLightBoostWhenAvailable = true;
    }];
    
    AVCaptureConnection *videoConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
    if (videoConnection.supportsVideoStabilization)
    {
        if ([videoConnection respondsToSelector:@selector(setPreferredVideoStabilizationMode:)])
            videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        else
            videoConnection.enablesVideoStabilizationWhenAvailable = true;
    }
    
    if (completion != nil)
        completion();
}

- (bool)isResetNeeded
{
    if (self.currentCameraPosition != _preferredCameraPosition)
        return true;
    
    if (self.currentMode == PGCameraModeVideo)
        return true;
    
    if (self.zoomLevel > FLT_EPSILON)
        return true;
    
    return false;
}

- (void)reset
{
    [self beginConfiguration];
    
    if (_audioDevice != nil)
    {
        [self removeInput:_audioInput];
        _audioInput = nil;
        
        [_audioOutput setSampleBufferDelegate:nil queue:[ATQueue mainQueue].nativeQueue];
        [self removeOutput:_audioOutput];
        
        _audioDevice = nil;
    }
    
    if (self.currentCameraPosition != _preferredCameraPosition)
    {
        [self removeInput:_videoInput];

        AVCaptureDevice *targetDevice = [PGCameraCaptureSession _deviceWithCameraPosition:_preferredCameraPosition];
        if (targetDevice == nil)
            targetDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        _videoDevice = targetDevice;
        
        NSError *error = nil;
        if (_videoDevice != nil)
        {
            _videoInput = [AVCaptureDeviceInput deviceInputWithDevice:_videoDevice error:&error];
            if (_videoInput != nil)
                [self addInput:_videoInput];
        }
    }
    
    [self resetFlashMode];
    
    if (self.currentMode != PGCameraModePhoto)
    {
        if (self.currentMode == PGCameraModeVideo)
            self.sessionPreset = AVCaptureSessionPresetPhoto;
        
        _currentMode = PGCameraModePhoto;
    }
    
    [self commitConfiguration];
    
    [self resetFocusPoint];
    
    self.zoomLevel = 0.0f;
}

- (void)resetFlashMode
{
    _photoFlashMode = PGCameraFlashModeOff;
    _videoFlashMode = PGCameraFlashModeOff;
    self.currentFlashMode = PGCameraFlashModeOff;
}

- (PGCameraMode)currentMode
{
    return _currentMode;
}

- (void)setCurrentMode:(PGCameraMode)mode
{
    _currentMode = mode;
    
    [self beginConfiguration];
    
    [self resetFocusPoint];
    
    switch (mode)
    {
        case PGCameraModePhoto:
        case PGCameraModeSquare:
        {
            if (_audioDevice != nil)
            {
                [self removeInput:_audioInput];
                _audioInput = nil;
                
                [_audioOutput setSampleBufferDelegate:nil queue:[ATQueue mainQueue].nativeQueue];
                [self removeOutput:_audioOutput];
                _audioOutput = nil;
                
                _audioDevice = nil;
            }
            
            self.sessionPreset = AVCaptureSessionPresetPhoto;
            
            [self setFrameRate:0];
        }
            break;
            
        case PGCameraModeVideo:
        {
            self.sessionPreset = AVCaptureSessionPreset640x480;
            
            if (_audioDevice == nil)
            {
                AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];

                NSError *error = nil;
                if (audioDevice != nil)
                {
                    _audioDevice = audioDevice;
                    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:_audioDevice error:&error];
                    if ([self canAddInput:audioInput])
                    {
                        [self addInput:audioInput];
                        _audioInput = audioInput;
                    }
                }
             
                AVCaptureAudioDataOutput *audioOutput = [[AVCaptureAudioDataOutput alloc] init];
                if ([self canAddOutput:audioOutput])
                {
                    [audioOutput setSampleBufferDelegate:self queue:_audioQueue.nativeQueue];
                    [self addOutput:audioOutput];
                    _audioOutput = audioOutput;
                }
            }
            
            [self setFrameRate:PGCameraFrameRate];
        }
            break;
            
        default:
            break;
    }
    
    AVCaptureConnection *videoConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
    if (videoConnection.supportsVideoStabilization)
    {
        if ([videoConnection respondsToSelector:@selector(setPreferredVideoStabilizationMode:)])
            videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        else
            videoConnection.enablesVideoStabilizationWhenAvailable = true;
    }
    
    [self commitConfiguration];
}

#pragma mark - Zoom

- (CGFloat)_maximumZoomFactor
{
    return MIN(5.0f, self.videoDevice.activeFormat.videoMaxZoomFactor);
}

- (CGFloat)zoomLevel
{
    if (![self.videoDevice respondsToSelector:@selector(videoZoomFactor)])
        return 1.0f;
    
    return (self.videoDevice.videoZoomFactor - 1.0f) / ([self _maximumZoomFactor] - 1.0f);
}

- (void)setZoomLevel:(CGFloat)zoomLevel
{
    if (![self.videoDevice respondsToSelector:@selector(setVideoZoomFactor:)])
        return;
    
    __weak PGCameraCaptureSession *weakSelf = self;
    
    [self _reconfigureDevice:self.videoDevice withBlock:^(AVCaptureDevice *device)
    {
        __strong PGCameraCaptureSession *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        device.videoZoomFactor = MAX(1.0f, MIN([strongSelf _maximumZoomFactor], 1.0f + ([strongSelf _maximumZoomFactor] - 1.0f) * zoomLevel));
    }];
}

- (bool)isZoomAvailable
{
    return [PGCameraCaptureSession _isZoomAvailableForDevice:self.videoDevice];
}

+ (bool)_isZoomAvailableForDevice:(AVCaptureDevice *)device
{
    if (![device respondsToSelector:@selector(setVideoZoomFactor:)])
        return false;
    
    if (device.position == AVCaptureDevicePositionFront)
        return false;
    
    return true;
}

#pragma mark - Focus and Exposure

- (void)resetFocusPoint
{
    const CGPoint centerPoint = CGPointMake(0.5f, 0.5f);
    [self setFocusPoint:centerPoint focusMode:AVCaptureFocusModeContinuousAutoFocus exposureMode:AVCaptureExposureModeContinuousAutoExposure monitorSubjectAreaChange:false];
}

- (void)setFocusPoint:(CGPoint)point focusMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode monitorSubjectAreaChange:(bool)monitorSubjectAreaChange
{
    [self _reconfigureDevice:self.videoDevice withBlock:^(AVCaptureDevice *device)
    {
        _focusPoint = point;
        
        if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
        {
            [device setExposurePointOfInterest:point];
            [device setExposureMode:exposureMode];
        }
        if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
        {
            [device setFocusPointOfInterest:point];
            [device setFocusMode:focusMode];
        }

        [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
        
        if ([device respondsToSelector:@selector(exposureTargetBias)])
        {
            if (fabsf(device.exposureTargetBias) > FLT_EPSILON)
                [device setExposureTargetBias:0.0f completionHandler:nil];
        }
    }];
}

- (void)setExposureTargetBias:(CGFloat)bias
{
    [self _reconfigureDevice:self.videoDevice withBlock:^(AVCaptureDevice *device)
    {
        CGFloat value = 0.0f;
        if (bias >= 0)
            value = ABS(bias) * device.maxExposureTargetBias * 0.85f;
        else if (bias < 0)
            value = ABS(bias) * device.minExposureTargetBias * 0.85f;
        
        [device setExposureTargetBias:(float)value completionHandler:nil];
    }];
}

#pragma mark - Flash

- (PGCameraFlashMode)currentFlashMode
{
    switch (self.currentMode)
    {
        case PGCameraModeVideo:
            return _videoFlashMode;
            
        default:
            return _photoFlashMode;
    }
}

- (void)setCurrentFlashMode:(PGCameraFlashMode)mode
{
    [self _reconfigureDevice:self.videoDevice withBlock:^(AVCaptureDevice *device)
    {
        switch (self.currentMode)
        {
            case PGCameraModeVideo:
            {
                AVCaptureTorchMode torchMode = [PGCameraCaptureSession _deviceTorchModeForCameraFlashMode:mode];
                if (device.hasTorch && [device isTorchModeSupported:torchMode])
                {
                    _videoFlashMode = mode;
                    if (mode != PGCameraFlashModeAuto)
                    {
                        device.torchMode = torchMode;
                    }
                    else
                    {
                        device.torchMode = AVCaptureTorchModeOff;
                        
                        AVCaptureFlashMode flashMode = [PGCameraCaptureSession _deviceFlashModeForCameraFlashMode:mode];
                        if (device.hasFlash && [device isFlashModeSupported:flashMode])
                            device.flashMode = flashMode;
                    }
                }
            }
                break;
                
            default:
            {
                AVCaptureFlashMode flashMode = [PGCameraCaptureSession _deviceFlashModeForCameraFlashMode:mode];
                if (device.hasFlash && [device isFlashModeSupported:flashMode])
                {
                    _photoFlashMode = mode;
                    device.flashMode = flashMode;
                }
            }
                break;
        }
    }];
}

+ (AVCaptureFlashMode)_deviceFlashModeForCameraFlashMode:(PGCameraFlashMode)mode
{
    switch (mode)
    {
        case PGCameraFlashModeAuto:
            return AVCaptureFlashModeAuto;
            
        case PGCameraFlashModeOn:
            return AVCaptureFlashModeOn;
            
        default:
            return AVCaptureFlashModeOff;
    }
}

+ (AVCaptureTorchMode)_deviceTorchModeForCameraFlashMode:(PGCameraFlashMode)mode
{
    switch (mode)
    {
        case PGCameraFlashModeAuto:
            return AVCaptureTorchModeAuto;
            
        case PGCameraFlashModeOn:
            return AVCaptureTorchModeOn;
            
        default:
            return AVCaptureTorchModeOff;
    }
}

#pragma mark - Position

- (PGCameraPosition)currentCameraPosition
{
    if (_videoDevice != nil)
        return [PGCameraCaptureSession _cameraPositionForDevicePosition:_videoDevice.position];
    
    return PGCameraPositionUndefined;
}

- (void)setCurrentCameraPosition:(PGCameraPosition)position
{
    NSError *error;
    
    AVCaptureDevice *deviceForTargetPosition = [PGCameraCaptureSession _deviceWithCameraPosition:position];
    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:deviceForTargetPosition error:&error];
    
    if (newVideoInput != nil)
    {
        [self resetFocusPoint];
        
        [self beginConfiguration];
        
        [self removeInput:_videoInput];
        if ([self canAddInput:newVideoInput])
        {
            [self addInput:newVideoInput];
            _videoInput = newVideoInput;
        }
        else
        {
            [self addInput:_videoInput];
        }
        
        if (self.changingPosition != nil)
            self.changingPosition();
        
        if (self.currentMode == PGCameraModeVideo)
            [self setFrameRate:PGCameraFrameRate];
        else
            [self setFrameRate:0];
        
        [self commitConfiguration];
    }
    
    _videoDevice = deviceForTargetPosition;
    
    [self _reconfigureDevice:_videoDevice withBlock:^(AVCaptureDevice *device)
    {
        if (device.isLowLightBoostSupported)
            device.automaticallyEnablesLowLightBoostWhenAvailable = true;
    }];
    
    AVCaptureConnection *videoConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
    if (videoConnection.supportsVideoStabilization)
    {
        if ([videoConnection respondsToSelector:@selector(setPreferredVideoStabilizationMode:)])
            videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        else
            videoConnection.enablesVideoStabilizationWhenAvailable = true;
    }
}

+ (AVCaptureDevice *)_deviceWithCameraPosition:(PGCameraPosition)position
{
    return [self _deviceWithPosition:[self _devicePositionForCameraPosition:position]];
}

+ (AVCaptureDevice *)_deviceWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in devices)
    {
        if (device.position == position)
            return device;
    }
    
    return nil;
}

+ (PGCameraPosition)_cameraPositionForDevicePosition:(AVCaptureDevicePosition)position
{
    switch (position)
    {
        case AVCaptureDevicePositionBack:
            return PGCameraPositionRear;
            
        case AVCaptureDevicePositionFront:
            return PGCameraPositionFront;
            
        default:
            return PGCameraPositionUndefined;
    }
}

+ (AVCaptureDevicePosition)_devicePositionForCameraPosition:(PGCameraPosition)position
{
    switch (position)
    {
        case PGCameraPositionRear:
            return AVCaptureDevicePositionBack;
            
        case PGCameraPositionFront:
            return AVCaptureDevicePositionFront;
            
        default:
            return AVCaptureDevicePositionUnspecified;
    }
}

#pragma mark - Configuration

- (void)_reconfigureDevice:(AVCaptureDevice *)device withBlock:(void (^)(AVCaptureDevice *device))block
{    
    if (block == nil)
        return;
    
    NSError *error = nil;
    [device lockForConfiguration:&error];
    block(device);
    [device unlockForConfiguration];
    
    if (error != nil)
        TGLog(@"ERROR: failed to reconfigure camera: %@", error);
}

- (void)setFrameRate:(NSInteger)frameRate
{
    _frameRate = frameRate;
    
    if (_frameRate > 0)
    {
        if ([self.videoDevice respondsToSelector:@selector(setActiveVideoMinFrameDuration:)] &&
            [self.videoDevice respondsToSelector:@selector(setActiveVideoMaxFrameDuration:)])
        {
            NSInteger maxFrameRate = PGCameraFrameRate;
            if (self.videoDevice.activeFormat.videoSupportedFrameRateRanges.count > 0)
            {
                AVFrameRateRange *range = self.videoDevice.activeFormat.videoSupportedFrameRateRanges.firstObject;
                if (range.maxFrameRate < maxFrameRate)
                    maxFrameRate = (NSInteger)range.maxFrameRate;
            }
            
            [self _reconfigureDevice:self.videoDevice withBlock:^(AVCaptureDevice *device)
            {
                [device setActiveVideoMinFrameDuration:CMTimeMake(1, (int32_t)maxFrameRate)];
                [device setActiveVideoMaxFrameDuration:CMTimeMake(1, (int32_t)maxFrameRate)];
            }];
        }
    }
    else
    {
        if ([self.videoDevice respondsToSelector:@selector(setActiveVideoMinFrameDuration:)] &&
            [self.videoDevice respondsToSelector:@selector(setActiveVideoMaxFrameDuration:)])
        {
            [self _reconfigureDevice:self.videoDevice withBlock:^(AVCaptureDevice *device)
            {
                [device setActiveVideoMinFrameDuration:kCMTimeInvalid];
                [device setActiveVideoMaxFrameDuration:kCMTimeInvalid];
            }];
        }
    }
}

- (NSInteger)frameRate
{
    return _frameRate;
}

#pragma mark - 

- (void)startVideoRecordingWithOrientation:(AVCaptureVideoOrientation)orientation mirrored:(bool)mirrored completion:(void (^)(NSURL *outputURL, CGAffineTransform transform, CGSize dimensions, NSTimeInterval duration, bool success))completion
{
    if (_movieWriter.isRecording)
        return;
    
    if (_videoFlashMode == PGCameraFlashModeAuto)
    {
        [self _reconfigureDevice:self.videoDevice withBlock:^(AVCaptureDevice *device)
        {
            AVCaptureTorchMode torchMode = [PGCameraCaptureSession _deviceTorchModeForCameraFlashMode:PGCameraFlashModeAuto];
            if (device.hasTorch && [device isTorchModeSupported:torchMode])
                device.torchMode = torchMode;
        }];
    }
    
    CGSize targetVideoDimensions = CGSizeMake(640, 480);
    
    NSDictionary *videoCleanApertureSettings = @{
                                                 AVVideoCleanApertureWidthKey: @((NSInteger)targetVideoDimensions.width),
                                                 AVVideoCleanApertureHeightKey: @((NSInteger)targetVideoDimensions.height),
                                                 AVVideoCleanApertureHorizontalOffsetKey: @10,
                                                 AVVideoCleanApertureVerticalOffsetKey: @10
                                                 };
    
    NSDictionary *videoAspectRatioSettings = @{
                                               AVVideoPixelAspectRatioHorizontalSpacingKey: @3,
                                               AVVideoPixelAspectRatioVerticalSpacingKey: @3
                                               };

    bool highDefinition = false;
    NSDictionary *codecSettings = @{
                                    AVVideoAverageBitRateKey: @(highDefinition ? ((NSInteger)(750000 * 2.0)) : 750000),
                                    AVVideoCleanApertureKey: videoCleanApertureSettings,
                                    AVVideoPixelAspectRatioKey: videoAspectRatioSettings
                                    };
    
    NSDictionary *videoSettings = @{
                                    AVVideoCodecKey: AVVideoCodecH264,
                                    AVVideoCompressionPropertiesKey: codecSettings,
                                    AVVideoWidthKey: @((NSInteger)targetVideoDimensions.width),
                                    AVVideoHeightKey: @((NSInteger)targetVideoDimensions.height)
                                    };
    
    AudioChannelLayout acl;
    bzero( &acl, sizeof(acl));
    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    
    NSDictionary *audioSettings = @{
                                    AVFormatIDKey: @(kAudioFormatMPEG4AAC),
                                    AVSampleRateKey: @(44100.0f),
                                    AVEncoderBitRateKey: @(64000),
                                    AVNumberOfChannelsKey: @(1),
                                    AVChannelLayoutKey: [NSData dataWithBytes:&acl length:sizeof(acl)]
                                    };
    
    _captureVideoOrientation = orientation;
    _captureMirrored = mirrored;
    
    _movieWriter = [[PGCameraMovieWriter alloc] initWithVideoTransform:TGTransformForVideoOrientation(orientation, mirrored) videoOutputSettings:videoSettings audioOutputSettings:audioSettings];
    _movieWriter.finishedWithMovieAtURL = completion;
    [_movieWriter startRecording];
}

- (void)stopVideoRecording
{
    if (!_movieWriter.isRecording)
        return;
    
    __weak PGCameraCaptureSession *weakSelf = self;
    [_movieWriter stopRecordingWithCompletion:^
    {
        __strong PGCameraCaptureSession *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_movieWriter = nil;
        
        strongSelf->_videoFlashMode = PGCameraFlashModeOff;
    }];
}

- (void)captureNextFrameForVideoThumbnail:(bool)forVideoThumbnail completion:(void (^)(UIImage * image))completion
{
    _captureNextFrame = true;
    _capturingForVideoThumbnail = forVideoThumbnail;
    self.capturedFrameCompletion = completion;
}

static u_int8_t *TGCopyDataFromImageBuffer(CVImageBufferRef imageBuffer, size_t *outWidth, size_t *outHeight, size_t *outBytesPerRow)
{
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    size_t currSize = bytesPerRow * height * sizeof(uint8_t);
    
    if (outWidth != NULL)
        *outWidth = width;
    
    if (outHeight != NULL)
        *outHeight = height;
    
    if (outBytesPerRow != NULL)
        *outBytesPerRow = bytesPerRow;
    
    void *srcBuff = CVPixelBufferGetBaseAddress(imageBuffer);
    u_int8_t *outBuff = (u_int8_t *)malloc(currSize);
    
    memcpy(outBuff, srcBuff, currSize);
    
    return outBuff;
}

static UIImage *TGCapturedImage(u_int8_t *srcBuff, size_t width, size_t height, size_t bytesPerRow, UIImageOrientation orientation)
{
    size_t bytesPerRowOut = 4 * height * sizeof(uint8_t);
    size_t currSize = width * 4 * height * sizeof(uint8_t);
    
    u_int8_t *outBuff = (u_int8_t *)malloc(currSize);
    
    vImage_Buffer ibuff = { srcBuff, height, width, bytesPerRow };
    vImage_Buffer ubuff = { outBuff, width, height, bytesPerRowOut };
    
    uint8_t backColor[4] = { 0, 0, 0, 0 };
    vImage_Error err = vImageRotate90_ARGB8888(&ibuff, &ubuff, 3, backColor, 0);
    if (err != kvImageNoError)
        TGLog(@"ERROR: camera failed to rotate captured buffer errno: %ld", err);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(outBuff, height, width, 8, bytesPerRowOut, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst);
    
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:orientation];
    
    free(outBuff);
    CGImageRelease(quartzImage);
    
    return image;
}

static UIImageOrientation TGCapturedImageOrientationForVideoOrientation(AVCaptureVideoOrientation orientation, bool mirrored)
{
    switch (orientation)
    {
        case AVCaptureVideoOrientationPortraitUpsideDown:
            return mirrored ? UIImageOrientationDown : UIImageOrientationDown;
            
        case AVCaptureVideoOrientationLandscapeRight:
            return mirrored ? UIImageOrientationLeftMirrored : UIImageOrientationLeft;
            
        case AVCaptureVideoOrientationLandscapeLeft:
            return mirrored ? UIImageOrientationRightMirrored : UIImageOrientationRight;
            
        default:
            return mirrored ? UIImageOrientationUpMirrored : UIImageOrientationUp;
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)__unused connection
{
    if (!self.isRunning)
        return;
    
    if (!CMSampleBufferDataIsReady(sampleBuffer))
    {
        TGLog(@"WARNING: camera sample buffer data is not ready, skipping");
        return;
    }
    
    if (_movieWriter.isRecording)
        [_movieWriter _processSampleBuffer:sampleBuffer];
    
    if (!_captureNextFrame || captureOutput != _videoOutput)
        return;

    _captureNextFrame = false;
    
    if (self.capturedFrameCompletion != nil)
    {
        CFRetain(sampleBuffer);
        void(^capturedFrameCompletion)(UIImage *image) = self.capturedFrameCompletion;
        self.capturedFrameCompletion = nil;
     
        [[ATQueue concurrentDefaultQueue] dispatch:^
        {
            CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            CVPixelBufferLockBaseAddress(imageBuffer, 0);
            
            size_t width;
            size_t height;
            size_t bytesPerRow;
            
            uint8_t *srcBufferData = TGCopyDataFromImageBuffer(imageBuffer, &width, &height, &bytesPerRow);
             
            CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
             
            CFRelease(sampleBuffer);
             
            UIImageOrientation orientation = UIImageOrientationUp;
            if (_capturingForVideoThumbnail)
            {
                orientation = TGCapturedImageOrientationForVideoOrientation(_captureVideoOrientation, _captureMirrored);
            }
            else
            {
                if (self.requestPreviewIsMirrored != nil)
                    orientation = self.requestPreviewIsMirrored() ? UIImageOrientationUpMirrored : UIImageOrientationUp;
            }
            
            UIImage *image = TGCapturedImage(srcBufferData, width, height, bytesPerRow, orientation);
            free(srcBufferData);
             
            capturedFrameCompletion(image);
        }];
    }
}

@end
