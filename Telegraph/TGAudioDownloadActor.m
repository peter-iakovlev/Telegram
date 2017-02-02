/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGAudioDownloadActor.h"

#import "ActionStage.h"

#import "TL/TLMetaScheme.h"

#import "TGAudioMediaAttachment.h"

#import "TGStringUtils.h"

#import <CommonCrypto/CommonDigest.h>

#import "TGTelegramNetworking.h"

@implementation TGAudioDownloadActor

+ (void)load {
    [ASActor registerActorClass:self];
}

- (instancetype)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

+ (NSString *)genericPath
{
    return @"/tg/media/audio/@";
}

- (void)prepare:(NSDictionary *)options
{
    [super prepare:options];
    
    self.requestQueueName = @"documentDownload";
}

- (void)execute:(NSDictionary *)options
{
    TGAudioMediaAttachment *audioAttachment = options[@"audioAttachment"];
    if (audioAttachment != nil)
    {
        TLInputFileLocation *inputFileLocation = nil;
        int datacenterId = 0;
        int encryptedSize = audioAttachment.fileSize;
        int decryptedSize = audioAttachment.fileSize;
        NSDictionary *encryptionArgs = @{};
        
        NSString *storeAudioPathDirectory = nil;
        NSString *audioFilePath = nil;
        if (audioAttachment.audioId != 0)
        {
            storeAudioPathDirectory = [TGAudioMediaAttachment localAudioFileDirectoryForRemoteAudioId:audioAttachment.audioId];
            audioFilePath = [TGAudioMediaAttachment localAudioFilePathForRemoteAudioId:audioAttachment.audioId];
        }
        else
        {
            storeAudioPathDirectory = [TGAudioMediaAttachment localAudioFileDirectoryForLocalAudioId:audioAttachment.localAudioId];
            audioFilePath = [TGAudioMediaAttachment localAudioFilePathForLocalAudioId:audioAttachment.localAudioId];
        }
        
        [[NSFileManager defaultManager] createDirectoryAtPath:storeAudioPathDirectory withIntermediateDirectories:true attributes:nil error:nil];
        
       // NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:audioFilePath error:nil];
        
        if (audioAttachment.audioUri.length != 0)
        {
            if ([audioAttachment.audioUri hasPrefix:@"mt-encrypted-file://"])
            {
                NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[audioAttachment.audioUri substringFromIndex:@"mt-encrypted-file://?".length]];
                
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
            inputDocumentLocation.n_id = audioAttachment.audioId;
            inputDocumentLocation.access_hash = audioAttachment.accessHash;
            inputFileLocation = inputDocumentLocation;
            
            datacenterId = audioAttachment.datacenterId;
        }
        
        if (inputFileLocation != nil)
        {
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/multipart-file/(audio:%" PRId64 ":%d:%@)", audioAttachment.audioId, audioAttachment.datacenterId, audioAttachment.audioUri.length != 0 ? audioAttachment.audioUri : @""] options:@{
                @"fileLocation": inputFileLocation,
                @"encryptedSize": @(encryptedSize),
                @"decryptedSize": @(decryptedSize),
                @"storeFilePath": audioFilePath,
                @"datacenterId": @(datacenterId),
                @"encryptionArgs": encryptionArgs,
                @"mediaTypeTag": @(TGNetworkMediaTypeTagAudio)
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

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)__unused result
{
    if ([path hasPrefix:@"/tg/multipart-file/"])
    {
        if (status == ASStatusSuccess)
        {
            [ActionStageInstance() actionCompleted:self.path result:nil];
        }
        else
        {
            [ActionStageInstance() actionFailed:self.path reason:-1];
        }
    }
}

@end
