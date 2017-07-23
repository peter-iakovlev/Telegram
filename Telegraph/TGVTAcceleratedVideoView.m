#import "TGVTAcceleratedVideoView.h"

#import <SSignalKit/SSignalKit.h>
#import <AVFoundation/AVFoundation.h>

#import "TGObserverProxy.h"

#import <libkern/OSAtomic.h>
#import <pthread.h>

#import "TGImageUtils.h"

#import "TGImageMessageViewModel.h"

#import "TGWeakReference.h"

#import "TGGLVideoView.h"

static NSMutableDictionary *sessions() {
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = [[NSMutableDictionary alloc] init];
    });
    return dict;
}

static OSSpinLock sessionsLock = 0;
static int32_t nextSessionId = 0;

@interface TGVTAcceleratedVideoFrame : NSObject

@property (nonatomic, readonly) CVImageBufferRef buffer;
@property (nonatomic, readonly) CMTime timestamp;
@property (nonatomic, readonly) CGFloat angle;
@property (nonatomic, strong) __attribute__((NSObject)) CMFormatDescriptionRef formatDescription;

@property (nonatomic, readonly) CMSampleBufferRef sampleBuffer;

- (bool)prepareSampleBuffer;

@end

@implementation TGVTAcceleratedVideoFrame

- (instancetype)initWithBuffer:(CVImageBufferRef)buffer timestamp:(CMTime)timestamp angle:(CGFloat)angle formatDescription:(CMFormatDescriptionRef)formatDescription {
    self = [super init];
    if (self != nil) {
        if (buffer) {
            CFRetain(buffer);
        }
        _timestamp = timestamp;
        _buffer = buffer;
        _angle = angle;
        self.formatDescription = formatDescription;
    }
    return self;
}

- (void)dealloc {
    if (_buffer) {
        CFRelease(_buffer);
    }
    if (_sampleBuffer) {
        CFRelease(_sampleBuffer);
    }
}

- (bool)prepareSampleBuffer
{
    if (_sampleBuffer) {
        return true;
    }
    
    CMSampleTimingInfo timingInfo;
    timingInfo.presentationTimeStamp = self.timestamp;
    timingInfo.duration = kCMTimeInvalid;
    
    OSStatus error = noErr;
    error = CMSampleBufferCreateForImageBuffer(NULL, self.buffer, true, nil, nil, self.formatDescription, &timingInfo, &_sampleBuffer);
    
    return error == noErr;
}

@end

@class TGVTAcceleratedVideoFrameQueue;
@class TGVTAcceleratedVideoFrameQueueGuard;

@interface TGVTAcceleratedVideoFrameQueueItem : NSObject

@property (nonatomic, strong) TGVTAcceleratedVideoFrameQueue *queue;
@property (nonatomic, strong) NSMutableArray *guards;

@end

@implementation TGVTAcceleratedVideoFrameQueueItem

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _guards = [[NSMutableArray alloc] init];
    }
    return self;
}

@end

@interface TGVTAcceleratedVideoFrameQueueGuardItem : NSObject

@property (nonatomic, weak) TGVTAcceleratedVideoFrameQueueGuard *guard;
@property (nonatomic, strong) NSObject *key;

@end

@implementation TGVTAcceleratedVideoFrameQueueGuardItem

- (instancetype)initWithGuard:(TGVTAcceleratedVideoFrameQueueGuard *)guard key:(NSObject *)key {
    self = [super init];
    if (self != nil) {
        self.guard = guard;
        self.key = key;
    }
    return self;
}

@end

@interface TGVTAcceleratedVideoFrameQueueGuard : NSObject {
    void (^_draw)(TGVTAcceleratedVideoFrame *);
    NSString *_path;
}

@property (nonatomic, strong) NSObject *key;

- (void)draw:(TGVTAcceleratedVideoFrame *)frame;

- (instancetype)initWithDraw:(void (^)(TGVTAcceleratedVideoFrame *))draw path:(NSString *)path;

@end

@interface TGVTAcceleratedVideoFrameQueue : NSObject
{
    int32_t _sessionId;
    SQueue *_queue;
    void (^_frameReady)(TGVTAcceleratedVideoFrame *);
    int64_t _epoch;
    
    NSUInteger _maxFrames;
    NSUInteger _fillFrames;
    CMTime _previousFrameTimestamp;
    
    NSMutableArray *_frames;
    
    STimer *_timer;
    
    NSString *_path;
    AVAssetReader *_reader;
    AVAssetReaderTrackOutput *_output;
    CMTimeRange _timeRange;
    bool _failed;
}

@property (nonatomic, strong) NSMutableArray *pendingFrames;
@property (nonatomic) CGFloat angle;
@property (nonatomic, strong) __attribute__((NSObject)) CMFormatDescriptionRef formatDescription;

@end

@implementation TGVTAcceleratedVideoFrameQueue

- (instancetype)initWithPath:(NSString *)path frameReady:(void (^)(TGVTAcceleratedVideoFrame *))frameReady {
    self = [super init];
    if (self != nil) {
        _sessionId = nextSessionId++;
        OSSpinLockLock(&sessionsLock);
        sessions()[@(_sessionId)] = [[TGWeakReference alloc] initWithObject:self];
        OSSpinLockUnlock(&sessionsLock);
        
        static SQueue *queue = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            queue = [[SQueue alloc] init];
        });
        
        _queue = queue;
        
        if ([path hasSuffix:@".gif"])
        {
            NSString *movPath = [path stringByReplacingCharactersInRange:NSMakeRange(path.length - 4, 4) withString:@".mp4"];
            [[NSFileManager defaultManager] removeItemAtPath:movPath error:nil];
            [[NSFileManager defaultManager] createSymbolicLinkAtPath:movPath withDestinationPath:path error:nil];
            path = movPath;
        }
        
        _path = path;
        _frameReady = [frameReady copy];
        
        _maxFrames = 2;
        _fillFrames = 1;
        
        _frames = [[NSMutableArray alloc] init];
        _pendingFrames = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    OSSpinLockLock(&sessionsLock);
    [sessions() removeObjectForKey:@(_sessionId)];
    OSSpinLockUnlock(&sessionsLock);
    
    NSAssert([_queue isCurrentQueue], @"[_queue isCurrentQueue]");
}

- (void)dispatch:(void (^)())block {
    [_queue dispatch:block];
}

- (void)beginRequests {
    [_queue dispatch:^{
        [_timer invalidate];
        _timer = nil;
        
        [self checkQueue];
    }];
}

- (void)pauseRequests {
    [_queue dispatch:^{
        [_timer invalidate];
        _timer = nil;
        _previousFrameTimestamp = kCMTimeZero;
        [_frames removeAllObjects];
        [_reader cancelReading];
        _output = nil;
        _reader = nil;
    }];
}

- (void)checkQueue {
    [_timer invalidate];
    _timer = nil;
    
    NSTimeInterval nextDelay = 0.0;
    bool initializedNextDelay = false;
    
    if (_frames.count != 0) {
        nextDelay = 1.0;
        initializedNextDelay = true;
        
        TGVTAcceleratedVideoFrame *firstFrame = _frames[0];
        [_frames removeObjectAtIndex:0];
        
        int32_t comparison = CMTimeCompare(firstFrame.timestamp, _previousFrameTimestamp);
        
        if (comparison <= 0) {
            nextDelay = 0.05;
        } else {
            nextDelay = MIN(5.0, CMTimeGetSeconds(firstFrame.timestamp) - CMTimeGetSeconds(_previousFrameTimestamp));
        }
        
        _previousFrameTimestamp = firstFrame.timestamp;
        
        comparison = CMTimeCompare(firstFrame.timestamp, CMTimeMakeWithSeconds(DBL_EPSILON, 1000));
        if (comparison <= 0) {
            nextDelay = 0.0;
        }
        
        if (_frameReady) {
            _frameReady(firstFrame);
        }
    }
    
    if (_frames.count <= _fillFrames) {
        while (_frames.count < _maxFrames) {
            TGVTAcceleratedVideoFrame *frame = [self requestFrame];
            
            if (frame == nil) {
                if (_failed) {
                    nextDelay = 1.0;
                } else {
                    nextDelay = 0.0;
                }
                break;
            } else {
                [_frames addObject:frame];
            }
        }
    }
    
    __weak TGVTAcceleratedVideoFrameQueue *weakSelf = self;
    _timer = [[STimer alloc] initWithTimeout:nextDelay repeat:false completion:^{
        __strong TGVTAcceleratedVideoFrameQueue *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf checkQueue];
        }
    } queue:_queue];
    [_timer start];
}

- (TGVTAcceleratedVideoFrame *)requestFrame {
    _failed = false;
    for (int i = 0; i < 3; i++) {
        if (_reader == nil) {
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:_path] options:nil];
            AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
            if (track != nil) {
                _timeRange = track.timeRange;
                CGAffineTransform transform = [track preferredTransform];
                _angle = atan2(transform.b, transform.a);
                
                _output = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:track outputSettings:@{(NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)}];
                
                if (_output != nil) {
                    _output.alwaysCopiesSampleData = false;
                    if (false && iosMajorVersion() >= 8) {
                        _output.supportsRandomAccess = true;
                    }
                    
                    _reader = [[AVAssetReader alloc] initWithAsset:asset error:nil];
                    if ([_reader canAddOutput:_output]) {
                        [_reader addOutput:_output];
                        
                        if (![_reader startReading]) {
                            TGLog(@"Failed to begin reading video frames");
                            _reader = nil;
                            _output = nil;
                            _failed = true;
                            return nil;
                        }
                    } else {
                        TGLog(@"Failed to add output");
                        _reader = nil;
                        _output = nil;
                        _failed = true;
                        return nil;
                    }
                }
            }
        }
        
        if (_reader != nil) {
            CMSampleBufferRef sampleVideo = NULL;
            if (([_reader status] == AVAssetReaderStatusReading) && (sampleVideo = [_output copyNextSampleBuffer])) {
                TGVTAcceleratedVideoFrame *videoFrame = nil;

                CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleVideo);
                presentationTime.epoch = _epoch;
                
                CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleVideo);
                
                if (self.formatDescription == NULL || !CMVideoFormatDescriptionMatchesImageBuffer(self.formatDescription, imageBuffer)) {
                    OSStatus error = noErr;
                    
                    CMVideoFormatDescriptionRef formatDescription;
                    error = CMVideoFormatDescriptionCreateForImageBuffer(NULL, imageBuffer, &formatDescription);
                    if (error == noErr)
                        self.formatDescription = formatDescription;
                    else
                        TGLog(@"CMVideoFormatDescriptionCreateForImageBuffer error");
                }
                
                videoFrame = [[TGVTAcceleratedVideoFrame alloc] initWithBuffer:imageBuffer timestamp:presentationTime angle:_angle formatDescription:self.formatDescription];
                
                CFRelease(sampleVideo);
                
                return videoFrame;
            } else {
                TGVTAcceleratedVideoFrame *earliestFrame = nil;
                for (TGVTAcceleratedVideoFrame *frame in _pendingFrames) {
                    if (earliestFrame == nil || CMTimeCompare(earliestFrame.timestamp, frame.timestamp) == 1) {
                        earliestFrame = frame;
                    }
                }
                if (earliestFrame != nil) {
                    [_pendingFrames removeObject:earliestFrame];
                }
                
                if (earliestFrame != nil){
                    return earliestFrame;
                } else {
                    if (false && iosMajorVersion() >= 8) {
                        [_output resetForReadingTimeRanges:@[[NSValue valueWithCMTimeRange:_timeRange]]];
                    } else {
                        _epoch++;
                        [_reader cancelReading];
                        _reader = nil;
                        _output = nil;
                    }
                }
            }
        }
    }
    
    return nil;
}

@end

@implementation TGVTAcceleratedVideoFrameQueueGuard

+ (SQueue *)controlQueue {
    static SQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[SQueue alloc] init];
    });
    return queue;
}

static NSMutableDictionary *queueItemsByPath() {
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = [[NSMutableDictionary alloc] init];
    });
    return dict;
}

+ (void)addGuardForPath:(NSString *)path guard:(TGVTAcceleratedVideoFrameQueueGuard *)guard {
    NSAssert([[self controlQueue] isCurrentQueue], @"calling addGuardForPath from the wrong queue");
    
    if (path.length == 0) {
        return;
    }
    
    TGVTAcceleratedVideoFrameQueueItem *item = queueItemsByPath()[path];
    if (item == nil) {
        item = [[TGVTAcceleratedVideoFrameQueueItem alloc] init];
        __weak TGVTAcceleratedVideoFrameQueueItem *weakItem = item;
        item.queue = [[TGVTAcceleratedVideoFrameQueue alloc] initWithPath:path frameReady:^(TGVTAcceleratedVideoFrame *frame) {
            [[self controlQueue] dispatch:^{
                __strong TGVTAcceleratedVideoFrameQueueItem *strongItem = weakItem;
                if (strongItem != nil) {
                    for (TGVTAcceleratedVideoFrameQueueGuardItem *guardItem in strongItem.guards) {
                        [guardItem.guard draw:frame];
                    }
                }
            }];
        }];
        queueItemsByPath()[path] = item;
        [item.queue beginRequests];
    }
    [item.guards addObject:[[TGVTAcceleratedVideoFrameQueueGuardItem alloc] initWithGuard:guard key:guard.key]];
}

+ (void)removeGuardFromPath:(NSString *)path key:(NSObject *)key {
    [[self controlQueue] dispatch:^{
        TGVTAcceleratedVideoFrameQueueItem *item = queueItemsByPath()[path];
        if (item != nil) {
            for (NSInteger i = 0; i < (NSInteger)item.guards.count; i++) {
                TGVTAcceleratedVideoFrameQueueGuardItem *guardItem = item.guards[i];
                if ([guardItem.key isEqual:key] || guardItem.guard == nil) {
                    [item.guards removeObjectAtIndex:i];
                    i--;
                }
            }
            
            if (item.guards.count == 0) {
                [queueItemsByPath() removeObjectForKey:path];
                [item.queue pauseRequests];
            }
        }
    }];
}

- (instancetype)initWithDraw:(void (^)(TGVTAcceleratedVideoFrame *))draw path:(NSString *)path {
    self = [super init];
    if (self != nil) {
        _draw = [draw copy];
        _key = [[NSObject alloc] init];
        _path = path;
    }
    return self;
}

- (void)dealloc {
    [TGVTAcceleratedVideoFrameQueueGuard removeGuardFromPath:_path key:_key];
}

- (void)draw:(TGVTAcceleratedVideoFrame *)frame {
    if (_draw) {
        _draw(frame);
    }
}

@end

@interface TGVTAcceleratedVideoView () {
    NSString *_path;
    
    TGVTAcceleratedVideoFrameQueueGuard *_frameQueueGuard;
    
    id _applicationDidEnterBackground;
    id _applicationDidEnterBackground2;
    id _applicationWillEnterForeground;
    bool _inBackground;
    pthread_mutex_t _inBackgroundMutex;
    
    OSSpinLock _pendingFramesLock;
    NSMutableArray *_pendingFrames;
    
    int64_t _previousEpoch;
    CGFloat _angle;
    
    AVSampleBufferDisplayLayer *_displayLayer;
}

@end

@implementation TGVTAcceleratedVideoView

@synthesize videoSize = _videoSize;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        //TGLog(@"TGVTAcceleratedVideoView count %d", OSAtomicIncrement32(&TGVTAcceleratedVideoViewCount));
        
        _applicationWillEnterForeground = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(applicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification];
        _applicationDidEnterBackground = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(applicationWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification];
        _applicationDidEnterBackground2 = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(applicationWillResignActiveNotification:) name:UIApplicationDidEnterBackgroundNotification];
        _inBackground = [UIApplication sharedApplication].applicationState != UIApplicationStateActive;
        pthread_mutex_init(&_inBackgroundMutex, NULL);
        
        self.opaque = true;
        
        _displayLayer = [[AVSampleBufferDisplayLayer alloc] init];
        _displayLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.layer addSublayer:_displayLayer];
        
        _pendingFrames = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    //TGLog(@"TGVTAcceleratedVideoView count %d", OSAtomicDecrement32(&TGVTAcceleratedVideoViewCount));
    
    NSAssert([NSThread isMainThread], @"dealloc from background thread");
    
    pthread_mutex_destroy(&_inBackgroundMutex);
}

- (void)layoutSubviews {
    _displayLayer.frame = self.bounds;
}

- (void)applicationWillResignActiveNotification:(id)__unused notification {
    pthread_mutex_lock(&_inBackgroundMutex);
    _inBackground = true;
    pthread_mutex_unlock(&_inBackgroundMutex);
}

- (void)applicationDidBecomeActiveNotification:(id)__unused notification {
    pthread_mutex_lock(&_inBackgroundMutex);
    _inBackground = false;
    pthread_mutex_unlock(&_inBackgroundMutex);
}

- (void)prepareForRecycle {
    TGDispatchOnMainThread(^
    {
        [_displayLayer flushAndRemoveImage];
        _previousEpoch = 0;
    });
}

- (void)displayFrame:(TGVTAcceleratedVideoFrame *)frame {
    //TGLog(@"draw frame at %f", frame.timestamp);
    
    pthread_mutex_lock(&_inBackgroundMutex);
    if (!_inBackground) {
        
        if (_displayLayer.status == AVQueuedSampleBufferRenderingStatusFailed)
            [_displayLayer flushAndRemoveImage];
        
        if (_previousEpoch != frame.timestamp.epoch) {
            _previousEpoch = frame.timestamp.epoch;
            [_displayLayer flush];
        }
        
        if ([_displayLayer isReadyForMoreMediaData])
            [_displayLayer enqueueSampleBuffer:frame.sampleBuffer];
        
        if (_angle != frame.angle) {
            _angle = frame.angle;
            self.transform = CGAffineTransformMakeRotation(frame.angle);
        }
    }
    
    pthread_mutex_unlock(&_inBackgroundMutex);
}

- (void)setPath:(NSString *)path {
    [[TGVTAcceleratedVideoFrameQueueGuard controlQueue] dispatch:^{
        NSString *realPath = path;
        if (path != nil && [path pathExtension].length == 0 && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
            realPath = [path stringByAppendingPathExtension:@"mov"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:realPath]) {
                [[NSFileManager defaultManager] removeItemAtPath:realPath error:nil];
                [[NSFileManager defaultManager] createSymbolicLinkAtPath:realPath withDestinationPath:[path pathComponents].lastObject error:nil];
            }
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:realPath]) {
            realPath = nil;
        }
        
        TGDispatchOnMainThread(^{
            if (!TGStringCompare(realPath, _path)) {
                _path = realPath;
                _frameQueueGuard = nil;
                
                if (_path.length != 0) {
                    __weak TGVTAcceleratedVideoView *weakSelf = self;
                    TGVTAcceleratedVideoFrameQueueGuard *frameQueueGuard = [[TGVTAcceleratedVideoFrameQueueGuard alloc] initWithDraw:^(TGVTAcceleratedVideoFrame *frame) {
                        __strong TGVTAcceleratedVideoView *strongSelf = weakSelf;
                        if (strongSelf != nil && frame != nil) {
                            [frame prepareSampleBuffer];
                            TGDispatchOnMainThread(^{
                                [strongSelf displayFrame:frame];
                            });
                        }
                    } path:realPath];
                    
                    _frameQueueGuard = frameQueueGuard;
                    
                    [[TGVTAcceleratedVideoFrameQueueGuard controlQueue] dispatch:^{
                        [TGVTAcceleratedVideoFrameQueueGuard addGuardForPath:realPath guard:frameQueueGuard];
                    }];
                }
            }
        });
    }];
}

+ (Class)videoViewClass
{
    static dispatch_once_t onceToken;
    static Class class;
    dispatch_once(&onceToken, ^{
        if (iosMajorVersion() >= 8)
            class = [TGVTAcceleratedVideoView class];
        else
            class = [TGGLVideoView class];
    });
    return class;
}

@end
