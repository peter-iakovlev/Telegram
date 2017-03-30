#import "TGSendAudioSignal.h"
#import "TGSendMessageSignals.h"

#import "TGAppDelegate.h"

#import "ActionStage.h"
#import "TGLiveUploadActor.h"

#import "TGDataItem.h"

#import "TGDocumentMediaAttachment.h"
#import "TLInputMedia.h"

#import "TLDocumentAttribute$documentAttributeAudio.h"

#import "TGPreparedLocalDocumentMessage.h"

#import "TGAudioWaveformSignal.h"

#import "TLInputMediaUploadedDocument.h"

#import "TGTelegramNetworking.h"

@interface TGUploadFileAdapter : NSObject <ASWatcher>
{
    NSString *_path;
    TGLiveUploadActorData *_liveData;
    NSString *_actorPath;
}

@property (nonatomic, strong) ASHandle *actionHandle;
@property (nonatomic, copy) void(^completion)(NSDictionary *result);

@end

@implementation TGUploadFileAdapter

- (instancetype)initWithPath:(NSString *)path liveData:(TGLiveUploadActorData *)liveData
{
    self = [super init];
    if (self != nil)
    {
        self.actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
        
        _path = path;
        _liveData = liveData;
    }
    return self;
}

- (NSString *)pathForLocalPath:(NSString *)path
{
    if ([path hasPrefix:@"upload/"])
    {
        NSString *localFileUrl = [path substringFromIndex:7];
        NSString *imagePath = [[[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"upload"] stringByAppendingPathComponent:localFileUrl];
        
        return imagePath;
    }
    else if ([path hasPrefix:@"file://"])
        return [path substringFromIndex:@"file://".length];
    
    return path;
}

- (void)startWithCompletion:(void (^)(NSDictionary *))completion
{
    self.completion = completion;
    
    NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithDictionary:@
    {
        @"explicitQueueName": @"sendMessageUploads",
        @"encrypt": @(false),
        @"ext": @"m4a"
    }];
    
    options[@"file"] = [self pathForLocalPath:_path];
    
    options[@"inbandUploadLimit"] = @(2 * 1024);
    
    if (_liveData != nil)
        options[@"liveData"] = _liveData;
    
    options[@"mediaTypeTag"] = @(TGNetworkMediaTypeTagAudio);
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        static int actionId = 100000;
        _actorPath = [[NSString alloc] initWithFormat:@"/tg/upload/(sendMessage%d)", actionId++];
        [ActionStageInstance() requestActor:_actorPath options:options watcher:self];
    }];
}

- (void)_uploadCompleted:(NSDictionary *)result
{
    if (self.completion != nil)
        self.completion(result);
}

- (void)_fail
{
    
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([_actorPath isEqualToString:path])
    {
        if (status == ASStatusSuccess)
            [self _uploadCompleted:result];
        else
            [self _fail];
    }
}

@end

@implementation TGSendAudioSignal

+ (SSignal *)sendAudioWithPeerId:(int64_t)peerId tempDataItem:(TGDataItem *)tempDataItem liveData:(TGLiveUploadActorData *)liveData duration:(int32_t)duration localAudioId:(int64_t)localAudioId replyToMid:(int32_t)replyToMid
{
    int fileSize = (int)[tempDataItem length];
    
    if (fileSize == 0)
        return nil;
    
    TGAudioWaveform *waveform = [TGAudioWaveformSignal waveformForPath:[tempDataItem path]];
    
    TGDocumentMediaAttachment *documentAttachment = [[TGDocumentMediaAttachment alloc] init];
    documentAttachment.localDocumentId = localAudioId;
    documentAttachment.attributes = @[[[TGDocumentAttributeFilename alloc] initWithFilename:@"audio.ogg"], [[TGDocumentAttributeAudio alloc] initWithIsVoice:true title:nil performer:nil duration:duration waveform:waveform]];
    documentAttachment.size = fileSize;
    documentAttachment.mimeType = @"audio/ogg";
    
    NSString *audioFileDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:localAudioId version:0];
    NSString *audioFilePath = [audioFileDirectory stringByAppendingPathComponent:@"audio.ogg"];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:audioFileDirectory withIntermediateDirectories:true attributes:nil error:NULL];
    [tempDataItem moveToPath:audioFilePath];
    
    SSignal *uploadSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGUploadFileAdapter *uploadAdapter = [[TGUploadFileAdapter alloc] initWithPath:audioFilePath liveData:liveData];
        [uploadAdapter startWithCompletion:^(NSDictionary *result)
        {
            if (result != nil)
            {
                [subscriber putNext:result];
                [subscriber putCompletion];
            }
            else
            {
                [subscriber putError:nil];
            }
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [uploadAdapter description];
        }];
    }];
    
    return [TGSendMessageSignals sendMediaWithPeerId:peerId replyToMid:replyToMid attachment:documentAttachment uploadSignal:uploadSignal mediaProducer:^TLInputMedia *(NSDictionary *uploadInfo)
    {
        TLInputMediaUploadedDocument *uploadedDocument = [[TLInputMediaUploadedDocument alloc] init];
        uploadedDocument.file = uploadInfo[@"file"];
        uploadedDocument.mime_type = @"audio/ogg";
        
        TLDocumentAttribute$documentAttributeAudio *audio = [[TLDocumentAttribute$documentAttributeAudio alloc] init];
        audio.duration = duration;
        audio.flags |= (1 << 10);
        if (waveform != nil) {
            audio.waveform = [waveform bitstream];
            audio.flags |= (1 << 2);
        }
        uploadedDocument.attributes = @[audio];
        
        return uploadedDocument;
    }];
}

@end
