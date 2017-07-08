#import "TGGLVideoView.h"

#import <SSignalKit/SSignalKit.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <AVFoundation/AVFoundation.h>

#import "TGObserverProxy.h"

#import <libkern/OSAtomic.h>
#import <pthread.h>

#import "TGImageUtils.h"

#import "TGImageMessageViewModel.h"

#import <VideoToolbox/VideoToolbox.h>

#import "TGWeakReference.h"

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

typedef enum {
    UniformIndex_Y = 0,
    UniformIndex_UV,
    UniformIndex_RotationAngle,
    UniformIndex_ColorConversionMatrix,
    UniformIndex_NumUniforms
} UniformIndex;

typedef enum {
    AttributeIndex_Vertex = 0,
    AttributeIndex_TextureCoordinates,
    AttributeIndex_NumAttributes
} AttributeIndex;

// BT.601, which is the standard for SDTV.
static GLfloat colorConversion601[] = {
    1.164f, 1.164f, 1.164f,
    0.0f, -0.392f, 2.017f,
    1.596f, -0.813f, 0.0f
};

// BT.709, which is the standard for HDTV.
static GLfloat colorConversion709[] = {
    1.164f, 1.164f, 1.164f,
    0.0f, -0.213f, 2.112f,
    1.793f, -0.533f, 0.0f
};

static NSData *fragmentShaderSource() {
    static NSData *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        value = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"VTPlayer/VTPlayer_Shader" ofType:@"fsh"]];
    });
    return value;
}

static NSData *vertexShaderSource() {
    static NSData *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        value = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"VTPlayer/VTPlayer_Shader" ofType:@"vsh"]];
    });
    return value;
}

@interface TGGLVideoFrame : NSObject

@property (nonatomic, readonly) CVImageBufferRef buffer;
@property (nonatomic, readonly) NSTimeInterval timestamp;
@property (nonatomic, readonly) CGFloat angle;

@end

@implementation TGGLVideoFrame

- (instancetype)initWithBuffer:(CVImageBufferRef)buffer timestamp:(NSTimeInterval)timestamp angle:(CGFloat)angle {
    self = [super init];
    if (self != nil) {
        if (buffer) {
            CFRetain(buffer);
        }
        _timestamp = timestamp;
        _buffer = buffer;
        _angle = angle;
    }
    return self;
}

- (void)dealloc {
    if (_buffer) {
        CFRelease(_buffer);
    }
}

@end

@class TGGLVideoFrameQueue;
@class TGGLVideoFrameQueueGuard;

@interface TGGLVideoFrameQueueItem : NSObject

@property (nonatomic, strong) TGGLVideoFrameQueue *queue;
@property (nonatomic, strong) NSMutableArray *guards;

@end

@implementation TGGLVideoFrameQueueItem

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _guards = [[NSMutableArray alloc] init];
    }
    return self;
}

@end

@interface TGGLVideoFrameQueueGuardItem : NSObject

@property (nonatomic, weak) TGGLVideoFrameQueueGuard *guard;
@property (nonatomic, strong) NSObject *key;

@end

@implementation TGGLVideoFrameQueueGuardItem

- (instancetype)initWithGuard:(TGGLVideoFrameQueueGuard *)guard key:(NSObject *)key {
    self = [super init];
    if (self != nil) {
        self.guard = guard;
        self.key = key;
    }
    return self;
}

@end

@interface TGGLVideoFrameQueueGuard : NSObject {
    void (^_draw)(TGGLVideoFrame *);
    NSString *_path;
}

@property (nonatomic, strong) NSObject *key;

- (void)draw:(TGGLVideoFrame *)frame;

- (instancetype)initWithDraw:(void (^)(TGGLVideoFrame *))draw path:(NSString *)path;

@end

@interface TGGLVideoFrameQueue : NSObject
{
    int32_t _sessionId;
    SQueue *_queue;
    void (^_frameReady)(TGGLVideoFrame *);
    
    NSUInteger _maxFrames;
    NSUInteger _fillFrames;
    NSTimeInterval _previousFrameTimestamp;
    
    NSMutableArray *_frames;
    
    STimer *_timer;
    
    NSString *_path;
    AVAssetReader *_reader;
    AVAssetReaderTrackOutput *_output;
    CMTimeRange _timeRange;
    bool _failed;
    
    VTDecompressionSessionRef _decompressionSession;
    
    bool _useVT;
}

@property (nonatomic, strong) NSMutableArray *pendingFrames;
@property (nonatomic) CGFloat angle;

@end

@implementation TGGLVideoFrameQueue

- (instancetype)initWithPath:(NSString *)path frameReady:(void (^)(TGGLVideoFrame *))frameReady {
    self = [super init];
    if (self != nil) {
        _useVT = iosMajorVersion() >= 8;
#if TARGET_IPHONE_SIMULATOR
        _useVT = false;
#endif
        
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
    
    if (_decompressionSession) {
        VTDecompressionSessionInvalidate(_decompressionSession);
        CFRelease(_decompressionSession);
        _decompressionSession = nil;
    }
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
        _previousFrameTimestamp = 0.0;
        [_frames removeAllObjects];
        [_reader cancelReading];
        _output = nil;
        _reader = nil;
        
        if (_decompressionSession) {
            VTDecompressionSessionInvalidate(_decompressionSession);
            CFRelease(_decompressionSession);
            _decompressionSession = nil;
        }
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
        
        TGGLVideoFrame *firstFrame = _frames[0];
        [_frames removeObjectAtIndex:0];
        
        if (firstFrame.timestamp <= _previousFrameTimestamp) {
            nextDelay = 0.05;
        } else {
            nextDelay = MIN(5.0, firstFrame.timestamp - _previousFrameTimestamp);
        }
        
        _previousFrameTimestamp = firstFrame.timestamp;
        
        if (firstFrame.timestamp <= DBL_EPSILON) {
            nextDelay = 0.0;
        }
        
        if (_frameReady) {
            _frameReady(firstFrame);
        }
    }
    
    if (_frames.count <= _fillFrames) {
        while (_frames.count < _maxFrames) {
            TGGLVideoFrame *frame = [self requestFrame];
            
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
    
    __weak TGGLVideoFrameQueue *weakSelf = self;
    _timer = [[STimer alloc] initWithTimeout:nextDelay repeat:false completion:^{
        __strong TGGLVideoFrameQueue *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf checkQueue];
        }
    } queue:_queue];
    [_timer start];
}

static void TGVTPlayerDecompressionOutputCallback(void *decompressionOutputRefCon, __unused void *sourceFrameRefCon, OSStatus status, __unused VTDecodeInfoFlags infoFlags, CVImageBufferRef imageBuffer, CMTime presentationTimestamp, __unused CMTime presentationDuration) {
    @autoreleasepool {
        if (status != noErr) {
            //Console.WriteLine ("Error decompresssing frame at time: {0:#.###} error: {1} infoFlags: {2}", (float)presentationTimeStamp.Value / presentationTimeStamp.TimeScale, (int)status, flags);
            TGLog(@"TGVTPlayerDecompressionOutputCallback error %d", (int)status);
            return;
        }
        
        if (imageBuffer == nil) {
            return;
        }
        
        if (CMTIME_IS_INVALID(presentationTimestamp)) {
            TGLog(@"TGVTPlayerDecompressionOutputCallback invalid timestamp");
            return;
        }
        
        CFAbsoluteTime presentationSeconds = CMTimeGetSeconds(presentationTimestamp);
        
        //TGLog(@"out %f (%d)", presentationSeconds, (int)sourceFrameRefCon);
        
        OSSpinLockLock(&sessionsLock);
        TGWeakReference *sessionReference = sessions()[@((int32_t)((intptr_t)decompressionOutputRefCon))];
        OSSpinLockUnlock(&sessionsLock);
        
        TGGLVideoFrameQueue *queue = sessionReference.object;
        TGGLVideoFrame *frame = [[TGGLVideoFrame alloc] initWithBuffer:imageBuffer timestamp:presentationSeconds angle:queue.angle];
        
        //[queue dispatch:^{
        [queue.pendingFrames addObject:frame];
        //}];
    }
}

- (TGGLVideoFrame *)requestFrame {
    _failed = false;
    for (int i = 0; i < 3; i++) {
        if (_reader == nil) {
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:_path] options:nil];
            AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
            if (track != nil) {
                _timeRange = track.timeRange;
                CGAffineTransform transform = [track preferredTransform];
                _angle = atan2(transform.b, transform.a);
                
                if (_useVT) {
                    NSArray *formatDescriptions = track.formatDescriptions;
                    CMVideoFormatDescriptionRef formatDescription = (__bridge CMVideoFormatDescriptionRef)formatDescriptions.firstObject;
                    VTDecompressionOutputCallbackRecord callbackRecord = {&TGVTPlayerDecompressionOutputCallback, (void *)(intptr_t)_sessionId};
                    
                    NSDictionary *imageOutputDescription = nil;
                    OSStatus status = VTDecompressionSessionCreate(kCFAllocatorDefault, formatDescription, NULL, (__bridge CFDictionaryRef)imageOutputDescription, &callbackRecord, &_decompressionSession);
                    if (_decompressionSession == NULL) {
                        if (status != -12983) {
                            TGLog(@"VTDecompressionSessionCreate failed with %d", (int)status);
                        }
                        _failed = true;
                        
                        _reader = nil;
                        _output = nil;
                        _failed = true;
                        return nil;
                    }
                    
                    _output = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:track outputSettings:nil];
                } else {
                    _output = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:track outputSettings:@{(NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)}];
                }
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
                            if (_decompressionSession) {
                                VTDecompressionSessionInvalidate(_decompressionSession);
                                CFRelease(_decompressionSession);
                                _decompressionSession = nil;
                            }
                            return nil;
                        }
                    } else {
                        TGLog(@"Failed to add output");
                        _reader = nil;
                        _output = nil;
                        _failed = true;
                        if (_decompressionSession) {
                            VTDecompressionSessionInvalidate(_decompressionSession);
                            CFRelease(_decompressionSession);
                            _decompressionSession = nil;
                        }
                        return nil;
                    }
                }
            }
        }
        
        if (_reader != nil) {
            CMSampleBufferRef sampleVideo = NULL;
            if (([_reader status] == AVAssetReaderStatusReading) && (sampleVideo = [_output copyNextSampleBuffer])) {
                TGGLVideoFrame *videoFrame = nil;
                if (_useVT) {
                    if (_decompressionSession != NULL) {
                        VTDecodeFrameFlags decodeFlags = kVTDecodeFrame_EnableTemporalProcessing;
                        VTDecodeInfoFlags outFlags = 0;
                        VTDecompressionSessionDecodeFrame(_decompressionSession, sampleVideo, decodeFlags, NULL, &outFlags);
                        if (outFlags & kVTDecodeInfo_Asynchronous) {
                            VTDecompressionSessionFinishDelayedFrames(_decompressionSession);
                            VTDecompressionSessionWaitForAsynchronousFrames(_decompressionSession);
                        }
                    }
                    
                    if (_pendingFrames.count >= 3) {
                        TGGLVideoFrame *earliestFrame = nil;
                        for (TGGLVideoFrame *frame in _pendingFrames) {
                            if (earliestFrame == nil || earliestFrame.timestamp > frame.timestamp) {
                                earliestFrame = frame;
                            }
                        }
                        if (earliestFrame != nil) {
                            [_pendingFrames removeObject:earliestFrame];
                        }
                        
                        videoFrame = earliestFrame;
                    } else {
                        if (sampleVideo != NULL) {
                            CFRelease(sampleVideo);
                        }
                        continue;
                    }
                } else {
                    CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleVideo);
                    NSTimeInterval presentationSeconds = CMTimeGetSeconds(presentationTime);
                    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleVideo);
                    videoFrame = [[TGGLVideoFrame alloc] initWithBuffer:imageBuffer timestamp:presentationSeconds angle:_angle];
                }
                
                CFRelease(sampleVideo);
                
                return videoFrame;
            } else {
                TGGLVideoFrame *earliestFrame = nil;
                for (TGGLVideoFrame *frame in _pendingFrames) {
                    if (earliestFrame == nil || earliestFrame.timestamp > frame.timestamp) {
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
                        [_reader cancelReading];
                        _reader = nil;
                        _output = nil;
                        if (_decompressionSession) {
                            VTDecompressionSessionInvalidate(_decompressionSession);
                            CFRelease(_decompressionSession);
                            _decompressionSession = nil;
                        }
                    }
                }
            }
        }
    }
    
    return nil;
}

@end

@implementation TGGLVideoFrameQueueGuard

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

+ (void)addGuardForPath:(NSString *)path guard:(TGGLVideoFrameQueueGuard *)guard {
    NSAssert([[self controlQueue] isCurrentQueue], @"calling addGuardForPath from the wrong queue");
    
    if (path.length == 0) {
        return;
    }
    
    TGGLVideoFrameQueueItem *item = queueItemsByPath()[path];
    if (item == nil) {
        item = [[TGGLVideoFrameQueueItem alloc] init];
        __weak TGGLVideoFrameQueueItem *weakItem = item;
        item.queue = [[TGGLVideoFrameQueue alloc] initWithPath:path frameReady:^(TGGLVideoFrame *frame) {
            [[self controlQueue] dispatch:^{
                __strong TGGLVideoFrameQueueItem *strongItem = weakItem;
                if (strongItem != nil) {
                    for (TGGLVideoFrameQueueGuardItem *guardItem in strongItem.guards) {
                        [guardItem.guard draw:frame];
                    }
                }
            }];
        }];
        queueItemsByPath()[path] = item;
        [item.queue beginRequests];
    }
    [item.guards addObject:[[TGGLVideoFrameQueueGuardItem alloc] initWithGuard:guard key:guard.key]];
}

+ (void)removeGuardFromPath:(NSString *)path key:(NSObject *)key {
    [[self controlQueue] dispatch:^{
        TGGLVideoFrameQueueItem *item = queueItemsByPath()[path];
        if (item != nil) {
            for (NSInteger i = 0; i < (NSInteger)item.guards.count; i++) {
                TGGLVideoFrameQueueGuardItem *guardItem = item.guards[i];
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

- (instancetype)initWithDraw:(void (^)(TGGLVideoFrame *))draw path:(NSString *)path {
    self = [super init];
    if (self != nil) {
        _draw = [draw copy];
        _key = [[NSObject alloc] init];
        _path = path;
    }
    return self;
}

- (void)dealloc {
    [TGGLVideoFrameQueueGuard removeGuardFromPath:_path key:_key];
}

- (void)draw:(TGGLVideoFrame *)frame {
    if (_draw) {
        _draw(frame);
    }
}

@end

@interface TGGLVideoContext : NSObject {
    SQueue *_queue;
    EAGLContext *_context;
}

@property (nonatomic, readonly) CVOpenGLESTextureCacheRef videoTextureCache;
@property (nonatomic, readonly) GLint *uniforms;
@property (nonatomic, readonly) GLint program;


@end

@implementation TGGLVideoContext

+ (TGGLVideoContext *)instance {
    static TGGLVideoContext *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[TGGLVideoContext alloc] init];
    });
    return singleton;
}

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _queue = [[SQueue alloc] init];
        [_queue dispatch:^{
            _uniforms = malloc(sizeof(GLint) * UniformIndex_NumUniforms);
            
            _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
            
            [EAGLContext setCurrentContext:_context];
            
            glDisable(GL_DEPTH_TEST);
            
            glEnableVertexAttribArray(AttributeIndex_Vertex);
            glVertexAttribPointer(AttributeIndex_Vertex, 2, GL_FLOAT, false, 2 * sizeof(GLfloat), NULL);
            
            glEnableVertexAttribArray(AttributeIndex_TextureCoordinates);
            
            glVertexAttribPointer(AttributeIndex_TextureCoordinates, 2, GL_FLOAT, false, 2 * sizeof(GLfloat), NULL);
            
            [self _loadShaders];
            
            glUseProgram(_program);
            
            // 0 and 1 are the texture IDs of lumaTexture and chromaTexture respectively.
            glUniform1i(_uniforms[UniformIndex_Y], 0);
            glUniform1i(_uniforms[UniformIndex_UV], 1);
            
            glUniform1f(_uniforms[UniformIndex_RotationAngle], 0.0f);
            
            glUniformMatrix3fv(_uniforms[UniformIndex_ColorConversionMatrix], 1, false, colorConversion709);
            
            CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _context, NULL, &_videoTextureCache);
        }];
    }
    return self;
}

- (void)dealloc {
}

- (bool)_loadShaders {
    int vertShader;
    int fragShader;
    
    _program = glCreateProgram();
    
    // Create and compile the vertex shader.
    if (![self _compileShaderWithType:GL_VERTEX_SHADER outShader:&vertShader]) {
        TGLog(@"Failed to compile vertex shader");
        return false;
    }
    
    // Create and compile fragment shader.
    if (![self _compileShaderWithType:GL_FRAGMENT_SHADER outShader:&fragShader]) {
        TGLog(@"Failed to compile fragment shader");
        return false;
    }
    
    glAttachShader(_program, vertShader);
    glAttachShader(_program, fragShader);
    
    glBindAttribLocation(_program, AttributeIndex_Vertex, "position");
    glBindAttribLocation(_program, AttributeIndex_TextureCoordinates, "texCoord");
    
    glLinkProgram(_program);
    
    
    int status;
    glGetProgramiv(_program, GL_LINK_STATUS, &status);
    bool ok = (status != 0);
    if (ok) {
        _uniforms[UniformIndex_Y] = glGetUniformLocation(_program, "SamplerY");
        _uniforms[UniformIndex_UV] = glGetUniformLocation(_program, "SamplerUV");
        _uniforms[UniformIndex_RotationAngle] = glGetUniformLocation(_program, "preferredRotation");
        _uniforms[UniformIndex_ColorConversionMatrix] = glGetUniformLocation(_program, "colorConversionMatrix");
    }
    if (vertShader != 0) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader != 0) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    if (!ok) {
        glDeleteProgram(_program);
        _program = 0;
    }
    
    return ok;
}

- (bool)_compileShaderWithType:(int)shaderType outShader:(int *)outShader {
    int shader = 0;
    
    NSData *source = (shaderType == GL_FRAGMENT_SHADER) ? fragmentShaderSource() : vertexShaderSource();
    if (source == nil) {
        return false;
    }
    
    shader = glCreateShader(shaderType);
    GLchar const *bytes = (GLchar const *)source.bytes;
    GLint length = (GLint)source.length;
    glShaderSource(shader, 1, &bytes, &length);
    glCompileShader(shader);
    
    if (iosMajorVersion() >= 7) {
        GLsizei logLength = 0;
        glGetShaderInfoLog(shader, 0, &logLength, NULL);
        if (logLength != 0) {
            GLchar *log = malloc(logLength);
            glGetShaderInfoLog(shader, logLength, &logLength, log);
            NSString *logString = [[NSString alloc] initWithBytes:log length:logLength encoding:NSUTF8StringEncoding];
            TGLog(@"Shader compile log: %@", logString);
            free(log);
        }
    }
    
    if (outShader != NULL) {
        *outShader = shader;
    }
    
    return true;
}

- (void)performAsynchronouslyWithContext:(dispatch_block_t)block {
    [_queue dispatch:^{
        [EAGLContext setCurrentContext:_context];
        block();
    }];
}

- (void)performSynchronouslyWithContext:(dispatch_block_t)block {
    [_queue dispatchSync:^{
        [EAGLContext setCurrentContext:_context];
        block();
    }];
}

- (void)presentRenderbuffer:(NSUInteger)target {
    [_context presentRenderbuffer:target];
}

- (void)renderbufferStorage:(NSUInteger)target fromDrawable:(id<EAGLDrawable>)drawable {
    [_context renderbufferStorage:target fromDrawable:drawable];
}

@end

@interface TGGLVideoView () {
    CAEAGLLayer *_layer;
    
    bool _buffersInitialized;
    int _backingWidth;
    int _backingHeight;
    uint _frameBufferHandle;
    uint _colorBufferHandle;
    
    GLfloat *_preferredConversion;
    
    int _program;
    
    NSString *_path;
    
    TGGLVideoFrameQueueGuard *_frameQueueGuard;
    
    id _applicationDidEnterBackground;
    id _applicationDidEnterBackground2;
    id _applicationWillEnterForeground;
    bool _inBackground;
    pthread_mutex_t _inBackgroundMutex;
    
    OSSpinLock _pendingFramesLock;
    NSMutableArray *_pendingFrames;
}

@end

@implementation TGGLVideoView

@synthesize videoSize = _videoSize;

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        //TGLog(@"TGGLVideoView count %d", OSAtomicIncrement32(&TGGLVideoViewCount));
        
        _applicationWillEnterForeground = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(applicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification];
        _applicationDidEnterBackground = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(applicationWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification];
        _applicationDidEnterBackground2 = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(applicationWillResignActiveNotification:) name:UIApplicationDidEnterBackgroundNotification];
        _inBackground = [UIApplication sharedApplication].applicationState != UIApplicationStateActive;
        pthread_mutex_init(&_inBackgroundMutex, NULL);
        
        _layer = (CAEAGLLayer *)self.layer;
        _layer.contentsScale = [UIScreen mainScreen].scale;
        self.opaque = true;
        _layer.drawableProperties = @{(NSString *)kEAGLDrawablePropertyRetainedBacking: @false, (NSString *)kEAGLDrawablePropertyColorFormat: (NSString *)kEAGLColorFormatRGBA8};
        
        _pendingFrames = [[NSMutableArray alloc] init];
        
        [[TGGLVideoContext instance] performAsynchronouslyWithContext:^{
            _preferredConversion = colorConversion709;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.layer position];
            });
        }];
    }
    return self;
}

- (void)dealloc {
    //TGLog(@"TGGLVideoView count %d", OSAtomicDecrement32(&TGGLVideoViewCount));
    
    NSAssert([NSThread isMainThread], @"dealloc from background thread");
    
    GLuint frameBufferHandle = _frameBufferHandle;
    GLuint colorBufferHandle = _colorBufferHandle;
    
    [[TGGLVideoContext instance] performAsynchronouslyWithContext:^{
        if (frameBufferHandle) {
            glDeleteFramebuffers(1, &frameBufferHandle);
        }
        
        if (colorBufferHandle) {
            glDeleteRenderbuffers(1, &colorBufferHandle);
        }
    }];
    
    pthread_mutex_destroy(&_inBackgroundMutex);
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
    [[TGGLVideoContext instance] performAsynchronouslyWithContext:^{
        if (_buffersInitialized) {
            if (_frameBufferHandle) {
                glDeleteFramebuffers(1, &_frameBufferHandle);
                _frameBufferHandle = 0;
            }
            
            if (_colorBufferHandle) {
                glDeleteRenderbuffers(1, &_colorBufferHandle);
                _colorBufferHandle = 0;
            }
            
            _buffersInitialized = false;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.layer position];
        });
    }];
}

- (void)setupBuffers {
    glGenFramebuffers(1, &_frameBufferHandle);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandle);
    
    glGenRenderbuffers(1, &_colorBufferHandle);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferHandle);
    
    
    [[TGGLVideoContext instance] renderbufferStorage:GL_RENDERBUFFER fromDrawable:_layer];
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorBufferHandle);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        TGLog(@"Failed to make complete framebuffer object");
    }
    
    _buffersInitialized = true;
}

- (void)displayFrame:(TGGLVideoFrame *)frame
{
    //TGLog(@"draw frame at %f", frame.timestamp);
    
    pthread_mutex_lock(&_inBackgroundMutex);
    if (!_inBackground && _buffersInitialized) {
        glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandle);
        glViewport(0, 0, _backingWidth, _backingHeight);
        
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        
        CVOpenGLESTextureRef lumaTexture = NULL;
        CVOpenGLESTextureRef chromaTexture = NULL;
        
        if (frame.buffer != NULL) {
            int frameWidth = (int)CVPixelBufferGetWidth(frame.buffer);
            int frameHeight = (int)CVPixelBufferGetHeight(frame.buffer);
            
            if ([TGGLVideoContext instance].videoTextureCache == NULL) {
                TGLog(@"No video texture cache");
            } else {
                CFTypeRef colorAttachments = CVBufferGetAttachment(frame.buffer, kCVImageBufferYCbCrMatrixKey, NULL);
                if (colorAttachments == kCVImageBufferYCbCrMatrix_ITU_R_601_4) {
                    _preferredConversion = colorConversion601;
                } else {
                    _preferredConversion = colorConversion709;
                }
                
                glActiveTexture(GL_TEXTURE0);
                CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [TGGLVideoContext instance].videoTextureCache, frame.buffer, NULL, GL_TEXTURE_2D, GL_RED_EXT, frameWidth, frameHeight, GL_RED_EXT, GL_UNSIGNED_BYTE, 0, &lumaTexture);
                if (lumaTexture == NULL) {
                    TGLog(@"Error at CVOpenGLESTextureCache.TextureFromImage");
                }
                
                glBindTexture(CVOpenGLESTextureGetTarget(lumaTexture), CVOpenGLESTextureGetName(lumaTexture));
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
                
                glActiveTexture(GL_TEXTURE1);
                
                CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [TGGLVideoContext instance].videoTextureCache, frame.buffer, NULL, GL_TEXTURE_2D, GL_RG_EXT, frameWidth / 2, frameHeight / 2, GL_RG_EXT, GL_UNSIGNED_BYTE, 1, &chromaTexture);
                
                if (chromaTexture == NULL) {
                    TGLog(@"Error at CVOpenGLESTextureCache.TextureFromImage");
                }
                
                glBindTexture(CVOpenGLESTextureGetTarget(chromaTexture), CVOpenGLESTextureGetName(chromaTexture));
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
                
                glUseProgram([TGGLVideoContext instance].program);
                glUniform1f([TGGLVideoContext instance].uniforms[UniformIndex_RotationAngle], 0.0f);
                glUniformMatrix3fv([TGGLVideoContext instance].uniforms[UniformIndex_ColorConversionMatrix], 1, false, _preferredConversion);
                
                // Set up the quad vertices with respect to the orientation and aspect ratio of the video.
                
                CGSize boundsSize = CGSizeMake(_backingWidth, _backingHeight);
                CGSize imageSize = CGSizeMake(frameWidth, frameHeight);
                if (ABS(frame.angle - ((CGFloat)M_PI / 2.0f)) < FLT_EPSILON) {
                    CGFloat tmp = imageSize.width;
                    imageSize.width = imageSize.height;
                    imageSize.height = tmp;
                } else if (ABS(frame.angle - ((CGFloat)-M_PI / 2.0f)) < FLT_EPSILON) {
                    CGFloat tmp = imageSize.width;
                    imageSize.width = imageSize.height;
                    imageSize.height = tmp;
                }
                CGSize renderSize = TGScaleToFill(imageSize, boundsSize);
                
                if (_videoSize.width > FLT_EPSILON && _videoSize.height > FLT_EPSILON) {
                    renderSize = _videoSize;
                }
                
                CGSize normalizedSamplingSize = CGSizeMake(0.0, 0.0);
                
                normalizedSamplingSize.width = renderSize.width / boundsSize.width;
                normalizedSamplingSize.height = renderSize.height / boundsSize.height;
                
                /*
                 The quad vertex data defines the region of 2D plane onto which we draw our pixel buffers.
                 Vertex data formed using (-1,-1) and (1,1) as the bottom left and top right coordinates respectively, covers the entire screen.
                 */
                GLfloat quadVertexData [] = {
                    (GLfloat)(-1 * normalizedSamplingSize.width), (GLfloat)(-1 * normalizedSamplingSize.height),
                    (GLfloat)normalizedSamplingSize.width, (GLfloat)(-1 * normalizedSamplingSize.height),
                    (GLfloat)(-1 * normalizedSamplingSize.width), (GLfloat)(normalizedSamplingSize.height),
                    (GLfloat)(normalizedSamplingSize.width), (GLfloat)(normalizedSamplingSize.height),
                };
                
                // Update attribute values.
                glVertexAttribPointer(AttributeIndex_Vertex, 2, GL_FLOAT, 0, 0, quadVertexData);
                glEnableVertexAttribArray(AttributeIndex_Vertex);
                
                /*
                 The texture vertices are set up such that we flip the texture vertically. This is so that our top left origin buffers match OpenGL's bottom left texture coordinate system.
                 */
                
                /*
                 
                 0,0---1,0
                 |      |
                 0,1---1,1
                 
                 */
                
                CGRect textureSamplingRect = CGRectMake(0, 0, 1, 1);
                if (ABS(frame.angle - ((CGFloat)M_PI / 2.0f)) < FLT_EPSILON) {
                    GLfloat quadTextureData[] = {
                        1.0f, 1.0f,
                        1.0f, 0.0f,
                        0.0f, 1.0f,
                        0.0f, 0.0f
                    };
                    glVertexAttribPointer(AttributeIndex_TextureCoordinates, 2, GL_FLOAT, 0, 0, quadTextureData);
                } else if (ABS(frame.angle - ((CGFloat)-M_PI / 2.0f)) < FLT_EPSILON) {
                    GLfloat quadTextureData[] = {
                        0.0f, 0.0f,
                        0.0f, 1.0f,
                        1.0f, 0.0f,
                        1.0f, 1.0f
                    };
                    glVertexAttribPointer(AttributeIndex_TextureCoordinates, 2, GL_FLOAT, 0, 0, quadTextureData);
                } else {
                    GLfloat quadTextureData[] = {
                        (GLfloat)CGRectGetMinX(textureSamplingRect), (GLfloat)CGRectGetMaxY(textureSamplingRect),
                        (GLfloat)CGRectGetMaxX(textureSamplingRect), (GLfloat)CGRectGetMaxY(textureSamplingRect),
                        (GLfloat)CGRectGetMinX(textureSamplingRect), (GLfloat)CGRectGetMinY(textureSamplingRect),
                        (GLfloat)CGRectGetMaxX(textureSamplingRect), (GLfloat)CGRectGetMinY(textureSamplingRect)
                    };
                    glVertexAttribPointer(AttributeIndex_TextureCoordinates, 2, GL_FLOAT, 0, 0, quadTextureData);
                }
                
                glEnableVertexAttribArray(AttributeIndex_TextureCoordinates);
                
                glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            }
        }
        
        glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferHandle);
        
        [[TGGLVideoContext instance] presentRenderbuffer:GL_RENDERBUFFER];
        
        if (chromaTexture != NULL) {
            CFRelease(chromaTexture);
        }
        
        if (lumaTexture != NULL) {
            CFRelease(lumaTexture);
        }
    }
    
    pthread_mutex_unlock(&_inBackgroundMutex);
}

- (void)setPath:(NSString *)path {
    [[TGGLVideoFrameQueueGuard controlQueue] dispatch:^{
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
        
        if (!TGStringCompare(realPath, _path)) {
            _path = realPath;
            _frameQueueGuard = nil;
            
            if (_path.length != 0) {
                __weak TGGLVideoView *weakSelf = self;
                _frameQueueGuard = [[TGGLVideoFrameQueueGuard alloc] initWithDraw:^(TGGLVideoFrame *frame) {
                    __strong TGGLVideoView *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        OSSpinLockLock(&strongSelf->_pendingFramesLock);
                        bool scheduleDisplay = false;
                        if (strongSelf->_pendingFrames.count < 3) {
                            [strongSelf->_pendingFrames addObject:frame];
                            scheduleDisplay = true;
                        }
                        OSSpinLockUnlock(&strongSelf->_pendingFramesLock);
                        
                        if (scheduleDisplay) {
                            [[TGGLVideoContext instance] performAsynchronouslyWithContext:^{
                                __strong TGGLVideoView *strongSelf = weakSelf;
                                if (strongSelf != nil) {
                                    TGGLVideoFrame *pendingFrame = nil;
                                    OSSpinLockLock(&strongSelf->_pendingFramesLock);
                                    if (strongSelf->_pendingFrames.count != 0) {
                                        pendingFrame = strongSelf->_pendingFrames.firstObject;
                                        [strongSelf->_pendingFrames removeObjectAtIndex:0];
                                    }
                                    OSSpinLockUnlock(&strongSelf->_pendingFramesLock);
                                    
                                    if (pendingFrame != nil) {
                                        [strongSelf displayFrame:frame];
                                    }
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [strongSelf.layer position];
                                    });
                                }
                            }];
                        }
                    }
                } path:_path];
                
                [TGGLVideoFrameQueueGuard addGuardForPath:_path guard:_frameQueueGuard];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.layer position];
        });
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    [[TGGLVideoContext instance] performAsynchronouslyWithContext:^{
        if ((_backingWidth != (int)bounds.size.width || _backingHeight != (int)bounds.size.height)) {
            if (_buffersInitialized) {
                if (_frameBufferHandle) {
                    glDeleteFramebuffers(1, &_frameBufferHandle);
                    _frameBufferHandle = 0;
                }
                
                if (_colorBufferHandle) {
                    glDeleteRenderbuffers(1, &_colorBufferHandle);
                    _colorBufferHandle = 0;
                }
                
                _buffersInitialized = false;
            }
            
            if (bounds.size.width > FLT_EPSILON && bounds.size.height > FLT_EPSILON) {
                [self setupBuffers];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.layer position];
        });
    }];
}

@end
