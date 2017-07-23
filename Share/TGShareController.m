#import "TGShareController.h"
#import "TGShareRecipientController.h"

#import <LegacyDatabase/LegacyDatabase.h>

#import "TGShareVideoConverter.h"

#import "TGSharePasscodeView.h"
#import "TGShareToolbarView.h"
#import "TGProgressAlert.h"
#import "TGShareNavigationBar.h"

#import "TGItemProviderSignals.h"

#import <LegacyDatabase/LegacyDatabase.h>

#import <LegacyDatabase/TGLegacyDatabase.h>

@interface TGShareController ()
{
    NSArray *_items;
    SVariable *_shareContext;
    TGShareContext *_currentShareContext;
    SMetaDisposable *_sendMessagesDisposable;
    
    TGSharePasscodeView *_passcodeView;
    TGProgressAlert *_progressAlert;
}
@end

@implementation TGShareController

- (instancetype)init
{
    self = [super initWithNavigationBarClass:[TGShareNavigationBar class] toolbarClass:nil];
    if (self != nil)
    {
        self.viewControllers = @[ [[TGShareRecipientController alloc] init] ];
        [self.navigationBar setTintColor:TGColorWithHex(0x007ee5)];
    }
    return self;
}

- (void)beginRequestWithExtensionContext:(NSExtensionContext *)context
{
    [super beginRequestWithExtensionContext:context];
    
    _items = context.inputItems;
}

- (void)dealloc
{
    [_sendMessagesDisposable dispose];
}

- (void)loadView
{
    [super loadView];
    
    self.view.alpha = 0.0f;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _shareContext = [[SVariable alloc] init];
    [_shareContext set:[[TGShareContextSignal shareContext] catch:^SSignal *(id error)
    {
        return [SSignal single:[[TGUnauthorizedShareContext alloc] init]];
    }]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.center = CGPointMake(self.view.center.x, self.view.center.y + self.view.frame.size.height);
    
    __weak TGShareController *weakSelf = self;
    [[_shareContext.signal deliverOn:[SQueue mainQueue]] startWithNext:^(id next)
    {
        __strong TGShareController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf setShareContext:next];
    }];
}

- (void)setShareContext:(id)context
{    
    if ([context isKindOfClass:[TGShareContext class]])
    {
        _currentShareContext = context;
        [self animateAppearance];
        
        if (_passcodeView != nil)
        {
            UIView *passcodeView = _passcodeView;
            _passcodeView = nil;
            
            [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^
            {
                passcodeView.frame = CGRectOffset(passcodeView.frame, 0.0f, passcodeView.frame.size.height);
            } completion:^(BOOL finished)
            {
                [passcodeView removeFromSuperview];
            }];
        }
        
        [self.recipientController setShareContext:context];
    }
    else if ([context isKindOfClass:[TGEncryptedShareContext class]])
    {
        _currentShareContext = nil;
        [self animateAppearance];
        
        TGEncryptedShareContext *encryptedShareContext = context;
        
        if (_passcodeView == nil)
        {
            __weak TGShareController *weakSelf = self;
            _passcodeView = [[TGSharePasscodeView alloc] initWithSimpleMode:encryptedShareContext.simplePassword cancel:^
            {
                __strong TGShareController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf dismissForCancel:true];
            } verify:^(NSString *passcode, void (^result)(bool))
            {
                result(encryptedShareContext.verifyPassword(passcode));
            } alertPresentationController:self allowTouchId:false]; //encryptedShareContext.allowTouchId];
            
            _passcodeView.frame = self.view.bounds;
            _passcodeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.view addSubview:_passcodeView];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
            {
                [_passcodeView showKeyboard];
                //[_passcodeView refreshTouchId];
            });
        }
    }
    else if ([context isKindOfClass:[TGUnauthorizedShareContext class]])
    {
        _currentShareContext = nil;
        [self showAuthRequiredAlert];
    }
}

- (void)sendToPeers:(NSArray *)peers models:(NSArray *)models caption:(NSString *)caption
{
    __weak TGShareController *weakSelf = self;
    
    SSignal *itemsSignal = [SSignal complete];
    NSArray *dataSignals = [TGItemProviderSignals itemSignalsForInputItems:_items];
    
    NSInteger providerIndex = 0;
    NSInteger providerCount = dataSignals.count;
    
    for (SSignal *dataSignal in dataSignals)
    {
        SSignal *sendSignal = [dataSignal mapToSignal:^SSignal *(id value)
        {
            __strong TGShareController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return [SSignal fail:nil];
            
            if (![value isKindOfClass:[NSDictionary class]])
                return [SSignal fail:nil];
            
            SSignal *uploadMediaSignal = nil;
            
            NSDictionary *description = (NSDictionary *)value;
            
            if (description[@"image"] != nil)
            {
                UIImage *image = description[@"image"];
                if (image != nil)
                {
                    image = TGScaleImage(image, TGFitSize(CGSizeMake(image.size.width * image.scale, image.size.height * image.scale), CGSizeMake(1280.0f, 1280.0f)));
                    NSData *imageData = UIImageJPEGRepresentation(image, 0.54f);
                    uploadMediaSignal = [TGUploadMediaSignals uploadPhotoWithContext:strongSelf->_currentShareContext data:imageData];
                }
            }
            else if (description[@"data"] != nil)
            {
                NSData *data = description[@"data"];
                NSString *fileName = description[@"fileName"];
                NSString *mimeType = description[@"mimeType"];
                
                UIImage *image = [[UIImage alloc] initWithData:data];
                if (image != nil)
                {
                    bool isGif = false;
                    if (data.length > 4)
                    {
                        uint8_t header[4];
                        [data getBytes:header length:4];
                        if (header[0] == 'G' && header[1] == 'I' && header[2] == 'F' && header[3] == '8')
                            isGif = true;
                    }
                    if (isGif)
                    {
                        uploadMediaSignal = [TGUploadMediaSignals uploadFileWithContext:strongSelf->_currentShareContext data:data name:fileName == nil ? @"animation.gif" : fileName mimeType:@"image/gif" attributes:@[ [Api70_DocumentAttribute documentAttributeAnimated], [Api70_DocumentAttribute documentAttributeImageSizeWithW:@((int32_t)image.size.width) h:@((int32_t)image.size.height)] ]];
                    }
                    else
                    {
                        image = TGScaleImage(image, TGFitSize(CGSizeMake(image.size.width * image.scale, image.size.height * image.scale), CGSizeMake(1280.0f, 1280.0f)));
                        NSData *imageData = UIImageJPEGRepresentation(image, 0.54f);
                        uploadMediaSignal = [TGUploadMediaSignals uploadPhotoWithContext:strongSelf->_currentShareContext data:imageData];
                    }
                }
                else
                {
                    uploadMediaSignal = [TGUploadMediaSignals uploadFileWithContext:strongSelf->_currentShareContext data:data name:fileName == nil ? @"file" : fileName mimeType:mimeType == nil ? @"application/octet-stream" : mimeType attributes:@[]];
                }

            }
            else if (description[@"video"] != nil)
            {
                AVURLAsset *asset = description[@"video"];
                uploadMediaSignal = [[TGShareVideoConverter convertAVAsset:asset] mapToSignal:^SSignal *(id value)
                {
                    if ([value isKindOfClass:[NSDictionary class]])
                    {
                        NSDictionary *desc = (NSDictionary *)value;
                        NSError *error;
                        NSData *videoData = [NSData dataWithContentsOfURL:desc[@"fileUrl"] options:NSDataReadingMappedIfSafe error:&error];
                        if (error != nil)
                            return [SSignal fail:nil];
                        
                        UIImage *resizedThumbnail = desc[@"previewImage"];
                        resizedThumbnail = TGScaleImage(resizedThumbnail, TGFitSize(resizedThumbnail.size, CGSizeMake(90, 90)));
                        NSData *thumbnailData = UIImageJPEGRepresentation(resizedThumbnail, 0.6);
                        
                        int32_t duration = (int32_t)[desc[@"duration"] doubleValue];
                        CGSize dimensions = [desc[@"dimensions"] CGSizeValue];
                        
                        return [[TGUploadMediaSignals uploadVideoWithContext:strongSelf->_currentShareContext data:videoData thumbData:thumbnailData duration:duration width:dimensions.width height:dimensions.height mimeType:desc[@"mimeType"]] map:^id(id value)
                        {
                            if ([value isKindOfClass:[NSNumber class]])
                                return @(0.5f + [value floatValue] / 2.0f);
                            else
                                return value;
                        }];
                    }
                    else if ([value isKindOfClass:[NSNumber class]])
                    {
                        return [SSignal single:@([value floatValue] / 2.0f)];
                    }
                    else
                    {
                        return [SSignal single:value];
                    }
                }];
            }
            else if (description[@"audio"] != nil)
            {
                NSURL *url = description[@"audio"];
                
                NSError *error;
                NSData *audioData = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
                if (error != nil)
                    return [SSignal fail:nil];
                
                NSString *fileName = url.lastPathComponent;
                
                NSTimeInterval duration = [description[@"duration"] doubleValue];
                bool isVoice = [description[@"isVoice"] boolValue] || (duration > DBL_EPSILON && duration < 30.0);
                NSString *title = description[@"title"] ? : @"";
                NSString *artist = description[@"artist"] ? : @"";
                
                int32_t flags = 0;
                if (isVoice) {
                    flags |= (1 << 10);
                }
                if (title.length > 0) {
                    flags |= (1 << 0);
                }
                if (artist != nil) {
                    flags |= (1 << 1);
                }
                
                NSData *waveform = nil;
                if (isVoice) {
                    waveform = [TGShareController audioWaveform:url];
                }
                
                if (waveform != nil) {
                    flags |= (1 << 2);
                }
                
                NSMutableArray *attributes = [[NSMutableArray alloc] init];
                [attributes addObject:[Api70_DocumentAttribute_documentAttributeAudio documentAttributeAudioWithFlags:@(flags) duration:description[@"duration"] title:title performer:artist waveform:waveform]];
                
                uploadMediaSignal = [TGUploadMediaSignals uploadFileWithContext:strongSelf->_currentShareContext data:audioData name:fileName mimeType:description[@"mimeType"] attributes:attributes];
            }
            else if (description[@"text"] != nil)
            {
                NSString *text = description[@"text"];
                return [SSignal single:[[TGUploadedMessageContentText alloc] initWithText:text]];
            }
            else if (description[@"url"] != nil)
            {
                NSURL *url = (NSURL *)description[@"url"];
                if ([TGShareLocationSignals isLocationURL:url])
                    return [TGShareLocationSignals locationMessageContentForURL:url];
                else
                    return [SSignal single:[[TGUploadedMessageContentText alloc] initWithText:url.absoluteString]];
            }
            else if (description[@"contact"] != nil)
            {
                TGContactModel *contact = (TGContactModel *)description[@"contact"];
                return [TGShareContactSignals contactMessageContentForContact:contact parentController:strongSelf];
            }
            
            if (uploadMediaSignal == nil)
                return [SSignal fail:nil];
            
            return [uploadMediaSignal mapToSignal:^SSignal *(id next)
            {
                __strong TGShareController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return [SSignal fail:nil];
                
                if ([next isKindOfClass:[Api70_InputMedia class]])
                {
                    return [SSignal single:[[TGUploadedMessageContentMedia alloc] initWithInputMedia:next]];
                }
                else
                {
                    return [SSignal single:@((providerIndex + [next floatValue]) / providerCount)];
                }
            }];
        }];
        
        if (sendSignal != nil)
            itemsSignal = [itemsSignal then:sendSignal];
        
        providerIndex++;
    }
    
    itemsSignal = [itemsSignal reduceLeftWithPassthrough:@[] with:^id (NSArray *currentUploadedMessageContents, id next, void (^passthrough)(id))
    {
        if ([next isKindOfClass:[TGUploadedMessageContent class]])
            return [currentUploadedMessageContents arrayByAddingObject:next];
        else
            passthrough(next);
        
        return currentUploadedMessageContents;
    }];
    
    itemsSignal = [itemsSignal mapToSignal:^SSignal *(id next)
    {
        if ([next respondsToSelector:@selector(floatValue)])
            return [SSignal single:next];
        else
        {
            __strong TGShareController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return [SSignal fail:nil];
            
            SSignal *sendMessages = [SSignal complete];
            for (NSValue *peerVal in peers)
            {
                TGPeerId peerId;
                [peerVal getValue:&peerId];
                
                [TGShareRecentPeersSignals addRecentPeerResult:peerId];
                
                if (caption.length > 0)
                {
                    sendMessages = [sendMessages then:[TGSendMessageSignals sendTextMessageWithContext:strongSelf->_currentShareContext peerId:peerId users:models text:caption]];
                }
                
                for (id content in next)
                {
                    if ([content isKindOfClass:[TGUploadedMessageContentText class]])
                    {
                        sendMessages = [sendMessages then:[TGSendMessageSignals sendTextMessageWithContext:strongSelf->_currentShareContext peerId:peerId users:models text:((TGUploadedMessageContentText *)content).text]];
                    }
                    else if ([content isKindOfClass:[TGUploadedMessageContentMedia class]])
                    {
                        sendMessages = [sendMessages then:[TGSendMessageSignals sendMediaWithContext:strongSelf->_currentShareContext peerId:peerId users:models inputMedia:((TGUploadedMessageContentMedia *)content).inputMedia]];
                    }
                }
            }
            
            return sendMessages;
        }
    }];
    
    if (_sendMessagesDisposable == nil)
        _sendMessagesDisposable = [[SMetaDisposable alloc] init];
    
    _progressAlert = [[TGProgressAlert alloc] initWithFrame:self.view.bounds];
    _progressAlert.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _progressAlert.text = NSLocalizedString(@"Share.Sharing", nil);
    _progressAlert.alpha = 0.0f;
    [self.view addSubview:_progressAlert];
    [UIView animateWithDuration:0.3 animations:^
    {
        _progressAlert.alpha = 1.0f;
    }];
    
    _progressAlert.cancel = ^
    {
        __strong TGShareController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;

        [strongSelf->_sendMessagesDisposable setDisposable:nil];
        
        [UIView animateWithDuration:0.3 animations:^
        {
            strongSelf->_progressAlert.alpha = 0.0f;
        } completion:^(BOOL finished)
        {
            [strongSelf->_progressAlert removeFromSuperview];
            strongSelf->_progressAlert = nil;
        }];
    };
    
    itemsSignal = [[itemsSignal then:[SSignal single:@(1.0f)]] then:[[SSignal complete] delay:0.4 onQueue:[SQueue mainQueue]]];
    
    [_sendMessagesDisposable setDisposable:[[[itemsSignal deliverOn:[SQueue mainQueue]] onDispose:^
    {
    }] startWithNext:^(id next)
    {
        if ([next respondsToSelector:@selector(floatValue)])
        {
            __strong TGShareController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf->_progressAlert setProgress:[next floatValue] animated:true];
        }
    } error:^(id error)
    {
        NSLog(@"error: %@", error);
        
        __strong TGShareController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;

        [UIView animateWithDuration:0.3 animations:^
        {
            strongSelf->_progressAlert.alpha = 0.0f;
        } completion:^(BOOL finished)
        {
            [strongSelf->_progressAlert removeFromSuperview];
            strongSelf->_progressAlert = nil;
        }];
    } completed:^
    {
        __strong TGShareController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf dismissForCancel:false];
    }]];
}

#pragma mark -

static void set_bits(uint8_t *bytes, int32_t bitOffset, int32_t numBits, int32_t value) {
    numBits = (unsigned int)pow(2, numBits) - 1; //this will only work up to 32 bits, of course
    uint8_t *data = bytes;
    data += bitOffset / 8;
    bitOffset %= 8;
    *((int32_t *)data) |= ((value) << bitOffset);
}

+ (NSData *)audioWaveform:(NSURL *)url {
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                    [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                    [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                    nil];
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    if (asset == nil) {
        NSLog(@"asset is not defined!");
        return nil;
    }
    
    NSError *assetError = nil;
    AVAssetReader *iPodAssetReader = [AVAssetReader assetReaderWithAsset:asset error:&assetError];
    if (assetError) {
        NSLog (@"error: %@", assetError);
        return nil;
    }
    
    AVAssetReaderOutput *readerOutput = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:asset.tracks audioSettings:outputSettings];
    
    if (! [iPodAssetReader canAddOutput: readerOutput]) {
        NSLog (@"can't add reader output... die!");
        return nil;
    }
    
    // add output reader to reader
    [iPodAssetReader addOutput: readerOutput];
    
    if (! [iPodAssetReader startReading]) {
        NSLog(@"Unable to start reading!");
        return nil;
    }
    
    NSMutableData *_waveformSamples = [[NSMutableData alloc] init];
    int16_t _waveformPeak = 0;
    int _waveformPeakCount = 0;
    
    while (iPodAssetReader.status == AVAssetReaderStatusReading) {
        // Check if the available buffer space is enough to hold at least one cycle of the sample data
        CMSampleBufferRef nextBuffer = [readerOutput copyNextSampleBuffer];
        
        if (nextBuffer) {
            AudioBufferList abl;
            CMBlockBufferRef blockBuffer = NULL;
            CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(nextBuffer, NULL, &abl, sizeof(abl), NULL, NULL, kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment, &blockBuffer);
            UInt64 size = CMSampleBufferGetTotalSampleSize(nextBuffer);
            if (size != 0) {
                int16_t *samples = (int16_t *)(abl.mBuffers[0].mData);
                int count = (int)size / 2;
                
                for (int i = 0; i < count; i++) {
                    int16_t sample = samples[i];
                    if (sample < 0) {
                        sample = -sample;
                    }
                    
                    if (_waveformPeak < sample) {
                        _waveformPeak = sample;
                    }
                    _waveformPeakCount++;
                    
                    if (_waveformPeakCount >= 100) {
                        [_waveformSamples appendBytes:&_waveformPeak length:2];
                        _waveformPeak = 0;
                        _waveformPeakCount = 0;
                    }
                }
            }
            
            CFRelease(nextBuffer);
            if (blockBuffer) {
                CFRelease(blockBuffer);
            }
        }
        else {
            break;
        }
    }
    
    int16_t scaledSamples[100];
    memset(scaledSamples, 0, 100 * 2);
    int16_t *samples = _waveformSamples.mutableBytes;
    int count = (int)_waveformSamples.length / 2;
    for (int i = 0; i < count; i++) {
        int16_t sample = samples[i];
        int index = i * 100 / count;
        if (scaledSamples[index] < sample) {
            scaledSamples[index] = sample;
        }
    }
    
    int16_t peak = 0;
    int64_t sumSamples = 0;
    for (int i = 0; i < 100; i++) {
        int16_t sample = scaledSamples[i];
        if (peak < sample) {
            peak = sample;
        }
        sumSamples += sample;
    }
    uint16_t calculatedPeak = 0;
    calculatedPeak = (uint16_t)(sumSamples * 1.8f / 100);
    
    if (calculatedPeak < 2500) {
        calculatedPeak = 2500;
    }
    
    for (int i = 0; i < 100; i++) {
        uint16_t sample = (uint16_t)((int64_t)samples[i]);
        if (sample > calculatedPeak) {
            scaledSamples[i] = calculatedPeak;
        }
    }
    
    int numSamples = 100;
    int bitstreamLength = (numSamples * 5) / 8 + (((numSamples * 5) % 8) == 0 ? 0 : 1);
    NSMutableData *result = [[NSMutableData alloc] initWithLength:bitstreamLength];
    {
        int32_t maxSample = peak;
        uint16_t const *samples = (uint16_t *)scaledSamples;
        uint8_t *bytes = result.mutableBytes;
        
        for (int i = 0; i < numSamples; i++) {
            int32_t value = MIN(31, ABS((int32_t)samples[i]) * 31 / maxSample);
            set_bits(bytes, i * 5, 5, value & 31);
        }
    }
    
    return result;
}

- (TGShareRecipientController *)recipientController
{
    return (TGShareRecipientController *)self.viewControllers.firstObject;
}

#pragma mark -

- (void)showAuthRequiredAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Share.AuthTitle", nil) message:NSLocalizedString(@"Share.AuthText", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Share.OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
    {
        [self _cancel];
    }];
    
    [alert addAction:action];
    [self presentViewController:alert animated:true completion:nil];
}

#pragma mark -

- (void)dismissForCancel:(bool)forCancel
{
    self.view.userInteractionEnabled = false;
    
    [self animateDismissalWithCompletion:^
    {
        if (!forCancel)
            [self _complete];
        else
            [self _cancel];
    }];
}

#pragma mark -

- (void)_complete
{
    [self.extensionContext completeRequestReturningItems:nil completionHandler:nil];
}

- (void)_cancel
{
    [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:nil]];
}

#pragma mark -

- (void)animateAppearance
{
    self.view.alpha = 1.0f;
    [UIView animateWithDuration:0.3 delay:0.0 options:(7 << 16 | UIViewAnimationOptionAllowAnimatedContent) animations:^
    {
        self.view.center = CGPointMake(self.view.center.x, self.view.frame.size.height / 2);
    } completion:nil];
}

- (void)animateDismissalWithCompletion:(void (^)(void))completion
{
    [UIView animateWithDuration:0.3 delay:0.0 options:(7 << 16) animations:^
    {
        self.view.center = CGPointMake(self.view.center.x, self.view.center.y + self.view.frame.size.height);
    } completion:^(BOOL finished)
    {
        if (completion != nil)
            completion();
    }];
}

@end
