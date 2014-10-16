/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPreparedLocalAudioMessage.h"

#import "TGMessage.h"

@implementation TGPreparedLocalAudioMessage

+ (instancetype)messageWithTempAudioPath:(NSString *)tempAudioPath duration:(int32_t)duration
{
#ifdef DEBUG
    NSAssert(tempAudioPath != nil, @"tempAudioPath should not be nil");
#endif
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) objectAtIndex:0];
    NSString *audiosDirectory = [documentsDirectory stringByAppendingPathComponent:@"audio"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:audiosDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:audiosDirectory withIntermediateDirectories:true attributes:nil error:nil];
    
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:tempAudioPath error:nil];
    int fileSize = [attributes[NSFileSize] intValue];
    
    if (fileSize == 0)
        return nil;
    
    int64_t localAudioId = 0;
    arc4random_buf(&localAudioId, 8);
    
    NSString *audioFileDirectory = [TGPreparedLocalAudioMessage localAudioFileDirectoryForLocalAudioId:localAudioId];
    NSString *audioFilePath = [TGPreparedLocalAudioMessage localAudioFilePathForLocalAudioId1:localAudioId];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:audioFileDirectory withIntermediateDirectories:true attributes:nil error:NULL];
    [[NSFileManager defaultManager] moveItemAtPath:tempAudioPath toPath:audioFilePath error:nil];
    
    TGPreparedLocalAudioMessage *message = [[TGPreparedLocalAudioMessage alloc] init];
    message.localAudioId = localAudioId;
    message.duration = duration;
    message.fileSize = (int32_t)fileSize;
    
    return message;
}

+ (instancetype)messageWithLocalAudioId:(int64_t)localAudioId duration:(int32_t)duration fileSize:(int32_t)fileSize
{
#ifdef DEBUG
    NSAssert(localAudioId != 0, @"localAudioId should not be equal to 0");
    NSAssert(fileSize != 0, @"fileSize should not be equal to 0");
#endif
    
    TGPreparedLocalAudioMessage *message = [[TGPreparedLocalAudioMessage alloc] init];
    message.localAudioId = localAudioId;
    message.duration = duration;
    message.fileSize = (int32_t)fileSize;
    
    return message;
}

+ (instancetype)messageByCopyingDataFromMessage:(TGPreparedLocalAudioMessage *)source
{
    for (id mediaAttachment in source.message.mediaAttachments)
    {
        if ([mediaAttachment isKindOfClass:[TGAudioMediaAttachment class]])
        {
            return [self messageByCopyingDataFromMedia:mediaAttachment];
        }
    }
    
    return nil;
}

+ (instancetype)messageByCopyingDataFromMedia:(TGAudioMediaAttachment *)audioMedia
{
#ifdef DEBUG
    NSAssert(audioMedia != nil, @"audioMedia should not be nil");
    NSAssert(audioMedia.localAudioId != 0, @"localAudioId should not be equal to 0");
#endif
    
    int64_t localAudioId = 0;
    arc4random_buf(&localAudioId, 8);
    
    NSString *fileDirectory = [TGPreparedLocalAudioMessage localAudioFileDirectoryForLocalAudioId:audioMedia.localAudioId];
    NSString *updatedFileDirectory = [TGPreparedLocalAudioMessage localAudioFileDirectoryForLocalAudioId:localAudioId];
    
    __autoreleasing NSError *error = nil;
    [[NSFileManager defaultManager] copyItemAtPath:fileDirectory toPath:updatedFileDirectory error:&error];
    if (error != nil)
    {
        TGLog(@"[TGPreparedLocalAudioMessage messageByCopyingDataFromMedia error: %@]", error);
        return nil;
    }
    
    TGPreparedLocalAudioMessage *message = [[TGPreparedLocalAudioMessage alloc] init];
    message.localAudioId = localAudioId;
    message.duration = audioMedia.duration;
    message.fileSize = audioMedia.fileSize;
    
    return message;
}

- (NSString *)localAudioFileDirectory
{
    return [TGPreparedLocalAudioMessage localAudioFileDirectoryForLocalAudioId:_localAudioId];
}

+ (NSString *)localAudioFileDirectoryForLocalAudioId:(int64_t)audioId
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) objectAtIndex:0];
    NSString *audiosDirectory = [documentsDirectory stringByAppendingPathComponent:@"audio"];
    return [audiosDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"local%" PRIx64 "", audioId]];
}

+ (NSString *)localAudioFileDirectoryForRemoteAudioId:(int64_t)audioId
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) objectAtIndex:0];
    NSString *audiosDirectory = [documentsDirectory stringByAppendingPathComponent:@"audio"];
    return [audiosDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%" PRIx64 "", audioId]];
}

- (NSString *)localAudioFilePath1
{
    return [[self localAudioFileDirectory] stringByAppendingPathComponent:@"audio.m4a"];
}

+ (NSString *)localAudioFilePathForLocalAudioId1:(int64_t)audioId
{
    return [[self localAudioFileDirectoryForLocalAudioId:audioId] stringByAppendingPathComponent:@"audio.m4a"];
}

+ (NSString *)localAudioFilePathForRemoteAudioId1:(int64_t)audioId
{
    return [[self localAudioFileDirectoryForRemoteAudioId:audioId] stringByAppendingPathComponent:@"audio.m4a"];
}

- (TGMessage *)message
{
    TGMessage *message = [[TGMessage alloc] init];
    message.mid = self.mid;
    message.date = self.date;
    message.isBroadcast = self.isBroadcast;
    message.messageLifetime = self.messageLifetime;
    
    TGAudioMediaAttachment *audioAttachment = [[TGAudioMediaAttachment alloc] init];
    audioAttachment.localAudioId = _localAudioId;
    audioAttachment.duration = _duration;
    audioAttachment.fileSize = _fileSize;
    
    message.mediaAttachments = @[audioAttachment];
    
    return message;
}

@end
