/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGDocumentDownloadActor.h"

#import "ActionStage.h"
#import "ASQueue.h"

#import "TL/TLMetaScheme.h"
#import "TGDocumentMediaAttachment.h"

#import "TGStringUtils.h"
#import "TGImageUtils.h"
#import "TGRemoteImageView.h"

#import "TGGenericModernConversationCompanion.h"
#import "TGFileDownloadActor.h"

#import <CommonCrypto/CommonDigest.h>

#import "TGAppDelegate.h"

#import "TGDocumentHttpFileReference.h"
#import "PSKeyValueDecoder.h"

#import "TGRemoteHttpLocationSignal.h"

#import "TGTelegramNetworking.h"

@interface TGDocumentDownloadActor ()
{
    TGDocumentMediaAttachment *_documentAttachment;
    NSString *_storeFilePath;
    SDisposableSet *_disposables;
}

@end

@implementation TGDocumentDownloadActor

- (instancetype)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
        _disposables = [[SDisposableSet alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    [_disposables dispose];
}

+ (NSString *)genericPath
{
    return @"/tg/media/document/@";
}

- (void)prepare:(NSDictionary *)options
{
    [super prepare:options];
    
    self.requestQueueName = @"documentDownload";
}

- (void)execute:(NSDictionary *)options
{
    TGDocumentMediaAttachment *documentAttachment = options[@"documentAttachment"];
    _documentAttachment = documentAttachment;
    
    if (documentAttachment != nil)
    {
        TLInputFileLocation *inputFileLocation = nil;
        int datacenterId = 0;
        int encryptedSize = documentAttachment.size;
        int decryptedSize = documentAttachment.size;
        NSDictionary *encryptionArgs = @{};
        
        NSString *documentsDirectory = [TGAppDelegate documentsPath];
        NSString *currentDocumentDirectory = nil;
        if (documentAttachment.documentId != 0)
        {
            currentDocumentDirectory = [[documentsDirectory stringByAppendingPathComponent:@"files"] stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%" PRIx64 "", documentAttachment.documentId]];
        }
        else
        {
            currentDocumentDirectory = [[documentsDirectory stringByAppendingPathComponent:@"files"] stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"local%" PRIx64 "", documentAttachment.localDocumentId]];
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:currentDocumentDirectory])
            [[NSFileManager defaultManager] createDirectoryAtPath:currentDocumentDirectory withIntermediateDirectories:true attributes:nil error:nil];
        
        _storeFilePath = [currentDocumentDirectory stringByAppendingPathComponent:documentAttachment.safeFileName];
        
        if (documentAttachment.documentUri.length != 0)
        {
            if ([documentAttachment.documentUri hasPrefix:@"mt-encrypted-file://"])
            {
                NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[documentAttachment.documentUri substringFromIndex:@"mt-encrypted-file://?".length]];
                
                NSData *key = [args[@"key"] dataByDecodingHexString];
                
                if (key.length != 64)
                    TGLog(@"***** Invalid file key length");
                else
                {
                    NSData *encryptionKey = [key subdataWithRange:NSMakeRange(0, 32)];
                    NSData *encryptionIv = [key subdataWithRange:NSMakeRange(32, 32)];
                    
                    unsigned char digest[CC_MD5_DIGEST_LENGTH];
                    CC_MD5(key.bytes, 32 + 32, digest);
                    
                    int32_t digestHigh = 0;
                    int32_t digestLow = 0;
                    memcpy(&digestHigh, digest, 4);
                    memcpy(&digestLow, digest + 4, 4);
                    
                    int32_t key_fingerprint = digestHigh ^ digestLow;
                    if (args[@"fingerprint"] != nil && [args[@"fingerprint"] intValue] != key_fingerprint)
                        TGLog(@"***** Invalid file key fingerprint");
                    else
                    {
                        TLInputFileLocation$inputEncryptedFileLocation *inputEncryptedLocation = [[TLInputFileLocation$inputEncryptedFileLocation alloc] init];
                        inputEncryptedLocation.n_id = [args[@"id"] longLongValue];
                        inputEncryptedLocation.access_hash = [args[@"accessHash"] longLongValue];
                        inputFileLocation = inputEncryptedLocation;
                        
                        datacenterId = [args[@"dc"] intValue];
                        encryptedSize = [args[@"size"] intValue];
                        decryptedSize = [args[@"decryptedSize"] intValue];
                        
                        encryptionArgs = @{@"key": encryptionKey, @"iv": encryptionIv};
                    }
                }
            }
        }
        else
        {
            TLInputFileLocation$inputDocumentFileLocation *inputDocumentLocation = [[TLInputFileLocation$inputDocumentFileLocation alloc] init];
            inputDocumentLocation.n_id = documentAttachment.documentId;
            inputDocumentLocation.access_hash = documentAttachment.accessHash;
            inputFileLocation = inputDocumentLocation;
            
            datacenterId = documentAttachment.datacenterId;
        }
        
        if (inputFileLocation != nil)
        {
            TGNetworkMediaTypeTag mediaTypeTag = TGNetworkMediaTypeTagDocument;
            for (id attribute in documentAttachment.attributes) {
                if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                    mediaTypeTag = TGNetworkMediaTypeTagAudio;
                    break;
                }
            }
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/multipart-file/(document:%" PRId64 ":%d:%@)", documentAttachment.documentId, documentAttachment.datacenterId, documentAttachment.documentUri.length != 0 ? documentAttachment.documentUri : @""] options:@{
                @"fileLocation": inputFileLocation,
                @"encryptedSize": @(encryptedSize),
                @"decryptedSize": @(decryptedSize),
                @"storeFilePath": _storeFilePath,
                @"datacenterId": @(datacenterId),
                @"encryptionArgs": encryptionArgs,
                @"mediaTypeTag": @(mediaTypeTag)
            } watcher:self];
        }
        else
            [ActionStageInstance() actionFailed:self.path reason:-1];
    }
    else
    {
        [ActionStageInstance() actionFailed:self.path reason:-1];
    }
}

- (void)cancel
{
    [ActionStageInstance() removeWatcher:self];
    
    [_disposables dispose];
    
    [super cancel];
}

- (void)actorMessageReceived:(NSString *)path messageType:(NSString *)messageType message:(id)message
{
    if ([path hasPrefix:@"/tg/multipart-file/"])
    {
        if ([messageType isEqualToString:@"progress"])
        {
            [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:messageType message:message];
        }
    }
}

+ (ASQueue *)previewGenerationQueue
{
    static ASQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        queue = [[ASQueue alloc] initWithName:"org.telegram.documentDownloadPreviewGeneration"];
    });
    
    return queue;
}

- (bool)fileIsImage
{
    NSArray *imageFileExtensions = @[@"gif", @"png", @"jpg", @"jpeg"];
    NSArray *imageMimeTypes = @[@"image/gif"];
    
    NSString *extension = [_documentAttachment.fileName pathExtension];
    for (NSString *sampleExtension in imageFileExtensions)
    {
        if ([[extension lowercaseString] isEqualToString:sampleExtension])
            return true;
    }
    
    for (NSString *sampleMimeType in imageMimeTypes)
    {
        if ([_documentAttachment.mimeType isEqualToString:sampleMimeType])
            return true;
    }
    
    return false;
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)__unused result
{
    if ([path hasPrefix:@"/tg/multipart-file/"])
    {
        if (status == ASStatusSuccess)
        {
            NSString *thumbnailUri = [_documentAttachment.thumbnailInfo imageUrlForLargestSize:NULL];
            
            if (thumbnailUri != nil)
            {
                //bool isImage = [self fileIsImage];
                
                [ActionStageInstance() actionCompleted:self.path result:nil];
                
                //if (isImage)
                {
                    [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/as/media/imageThumbnailUpdated"] resource:thumbnailUri];
                }
            }
            else
                [ActionStageInstance() actionCompleted:self.path result:nil];
        }
        else
        {
            [ActionStageInstance() actionFailed:self.path reason:-1];
        }
    }
}

@end
