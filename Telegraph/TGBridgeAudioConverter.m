#import "TGBridgeAudioConverter.h"
#import <AVFoundation/AVFoundation.h>

#import "ATQueue.h"

#import "ActionStage.h"
#import "TGLiveUploadActor.h"

#import "opus.h"
#import "opusenc.h"

#import "TGDataItem.h"

const NSInteger TGBridgeAudioConverterSampleRate = 16000;

@interface TGBridgeAudioConverter () <ASWatcher>
{
    AVAssetReader *_assetReader;
    AVAssetReaderOutput *_readerOutput;
    
    NSMutableData *_audioBuffer;
    TGDataItem *_tempFileItem;
    TGOggOpusWriter *_oggWriter;
    
    NSString *_liveUploadPath;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGBridgeAudioConverter

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self != nil)
    {
        self.actionHandle = [[ASHandle alloc] init];
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
        if (asset == nil)
        {
            TGLog(@"Asset create fail");
        }
        
        NSError *error;
        _assetReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
        
        NSDictionary *outputSettings = @
        {
            AVFormatIDKey: @(kAudioFormatLinearPCM),
            AVSampleRateKey: @(TGBridgeAudioConverterSampleRate),
            AVNumberOfChannelsKey: @1,
            AVLinearPCMBitDepthKey: @16,
            AVLinearPCMIsFloatKey: @false,
            AVLinearPCMIsBigEndianKey: @false,
            AVLinearPCMIsNonInterleaved: @false
        };
        
        _readerOutput = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:asset.tracks audioSettings:outputSettings];
        
        [_assetReader addOutput:_readerOutput];
        
        _tempFileItem = [[TGDataItem alloc] initWithTempFile];
        
        [[TGBridgeAudioConverter processingQueue] dispatch:^
        {
            static int nextActionId = 10000;
            int actionId = nextActionId++;
            _liveUploadPath = [[NSString alloc] initWithFormat:@"/tg/liveUpload/(%d)", actionId];
            
            [ActionStageInstance() requestActor:_liveUploadPath options:@{ @"fileItem": _tempFileItem,
                                                                           @"encryptFile": @(false)
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

- (void)cleanup
{
    _oggWriter = nil;
}

+ (ATQueue *)processingQueue
{
    static ATQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        queue = [[ATQueue alloc] initWithName:@"org.telegram.opusAudioConverterQueue"];
    });
    
    return queue;
}

- (void)startWithCompletion:(void (^)(TGDataItem *, int32_t, TGLiveUploadActorData *))completion
{
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    
    [[TGBridgeAudioConverter processingQueue] dispatch:^
    {
        _oggWriter = [[TGOggOpusWriter alloc] init];
        if (![_oggWriter beginWithDataItem:_tempFileItem])
        {
            TGLog(@"[TGBridgeAudioConverter#%x error initializing ogg opus writer]", self);
            [self cleanup];
            return;
        }
        
        [_assetReader startReading];
        
        while (_assetReader.status != AVAssetReaderStatusCompleted)
        {
            if (_assetReader.status == AVAssetReaderStatusReading)
            {
                CMSampleBufferRef nextBuffer = [_readerOutput copyNextSampleBuffer];
                
                if (nextBuffer)
                {
                    AudioBufferList abl;
                    CMBlockBufferRef blockBuffer;
                    CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(nextBuffer, NULL, &abl, sizeof(abl), NULL, NULL, kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment, &blockBuffer);
                    
                    [[TGBridgeAudioConverter processingQueue] dispatch:^
                    {
                        [self _processBuffer:&abl.mBuffers[0]];
                        
                        CFRelease(nextBuffer);
                        CFRelease(blockBuffer);
                    }];
                }
                else
                {
                    break;
                }
            }
        }
        
        TGDataItem *dataItemResult = nil;
        NSTimeInterval durationResult = 0.0;
        
        NSUInteger totalBytes = 0;
        
        if (_assetReader.status == AVAssetReaderStatusCompleted)
        {
            if (_oggWriter != nil && [_oggWriter writeFrame:NULL frameByteCount:0])
            {
                dataItemResult = _tempFileItem;
                durationResult = [_oggWriter encodedDuration];
                totalBytes = [_oggWriter encodedBytes];
            }
             
            [self cleanup];
        }
        
        __block TGLiveUploadActorData *liveData;
        dispatch_sync([ActionStageInstance() globalStageDispatchQueue], ^
        {
            TGLiveUploadActor *actor = (TGLiveUploadActor *)[ActionStageInstance() executingActorWithPath:_liveUploadPath];
            liveData = [actor finishRestOfFile:totalBytes];
        });
        
        TGLog(@"[TGBridgeAudioConverter#%x convert time: %f ms]", self, (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0);
        
        if (completion != nil)
            completion(dataItemResult, (int32_t)durationResult, liveData);
    }];
}

- (void)_processBuffer:(AudioBuffer const *)buffer
{
    @autoreleasepool
    {
        if (_oggWriter == nil)
            return;
        
        static const int millisecondsPerPacket = 60;
        static const int encoderPacketSizeInBytes = TGBridgeAudioConverterSampleRate / 1000 * millisecondsPerPacket * 2;
        
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

@end
