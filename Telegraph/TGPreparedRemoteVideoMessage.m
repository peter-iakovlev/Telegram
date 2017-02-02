/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPreparedRemoteVideoMessage.h"

#import "TGMessage.h"

@implementation TGPreparedRemoteVideoMessage

- (instancetype)initWithVideoId:(int64_t)videoId accessHash:(int64_t)accessHash videoSize:(CGSize)videoSize size:(int32_t)size duration:(NSTimeInterval)duration videoInfo:(TGVideoInfo *)videoInfo thumbnailInfo:(TGImageInfo *)thumbnailInfo caption:(NSString *)caption replyMessage:(TGMessage *)replyMessage replyMarkup:(TGReplyMarkupAttachment *)replyMarkup
{
    self = [super init];
    if (self != nil)
    {
        _videoId = videoId;
        _accessHash = accessHash;
        _videoSize = videoSize;
        _size = size;
        _duration = duration;
        _videoInfo = videoInfo;
        _thumbnailInfo = thumbnailInfo;
        _caption = caption;
        self.replyMessage = replyMessage;
        self.replyMarkup = replyMarkup;
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
    
    NSMutableArray *attachments = [[NSMutableArray alloc] init];
    
    [attachments addObject:[self video]];
    
    if (self.replyMessage != nil)
    {
        TGReplyMessageMediaAttachment *replyMedia = [[TGReplyMessageMediaAttachment alloc] init];
        replyMedia.replyMessageId = self.replyMessage.mid;
        replyMedia.replyMessage = self.replyMessage;
        [attachments addObject:replyMedia];
    }
    
    if (self.botContextResult != nil) {
        [attachments addObject:self.botContextResult];   
        [attachments addObject:[[TGViaUserAttachment alloc] initWithUserId:self.botContextResult.userId username:nil]];
    }
    
    if (self.replyMarkup != nil) {
        [attachments addObject:self.replyMarkup];
    }
    
    message.mediaAttachments = attachments;
    
    return message;
}

- (TGVideoMediaAttachment *)video {
    TGVideoMediaAttachment *videoAttachment = [[TGVideoMediaAttachment alloc] init];
    videoAttachment.videoId = _videoId;
    videoAttachment.accessHash = _accessHash;
    videoAttachment.duration = (int)_duration;
    videoAttachment.dimensions = _videoSize;
    videoAttachment.thumbnailInfo = _thumbnailInfo;
    videoAttachment.videoInfo = _videoInfo;
    videoAttachment.caption = _caption;
    return videoAttachment;
}

@end
