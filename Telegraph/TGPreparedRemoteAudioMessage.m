/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPreparedRemoteAudioMessage.h"

#import "TGMessage.h"

@implementation TGPreparedRemoteAudioMessage

- (instancetype)initWithAudioMedia:(TGAudioMediaAttachment *)audioMedia
{
    self = [super init];
    if (self != nil)
    {
        _audioId = audioMedia.audioId;
        _accessHash = audioMedia.accessHash;
        _datacenterId = audioMedia.datacenterId;
        _duration = audioMedia.duration;
        _fileSize = audioMedia.fileSize;
    }
    return self;
}

- (TGMessage *)message
{
    TGMessage *message = [[TGMessage alloc] init];
    message.mid = self.mid;
    message.date = self.date;
    message.isBroadcast = self.isBroadcast;
    message.messageLifetime = self.messageLifetime;
    
    TGAudioMediaAttachment *audioAttachment = [[TGAudioMediaAttachment alloc] init];
    audioAttachment.audioId = _audioId;
    audioAttachment.accessHash = _accessHash;
    audioAttachment.datacenterId = _datacenterId;
    audioAttachment.duration = _duration;
    audioAttachment.fileSize = _fileSize;
    
    message.mediaAttachments = @[audioAttachment];
    
    return message;
}

@end
