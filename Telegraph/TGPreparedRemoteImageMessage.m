/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPreparedRemoteImageMessage.h"

#import "TGMessage.h"

@implementation TGPreparedRemoteImageMessage

- (instancetype)initWithImageId:(int64_t)imageId accessHash:(int64_t)accessHash imageInfo:(TGImageInfo *)imageInfo
{
    self = [super init];
    if (self != nil)
    {
#ifdef DEBUG
        NSAssert(imageId != 0, @"imageId should not be 0");
        NSAssert(accessHash != 0, @"accessHash should not be 0");
        NSAssert(imageInfo != nil, @"imageInfo should not be nil");
#endif
        
        _imageId = imageId;
        _accessHash = accessHash;
        _imageInfo = imageInfo;
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
    
    TGImageMediaAttachment *imageAttachment = [[TGImageMediaAttachment alloc] init];
    imageAttachment.imageId = _imageId;
    imageAttachment.accessHash = _accessHash;
    imageAttachment.imageInfo = _imageInfo;
    message.mediaAttachments = @[imageAttachment];
    
    return message;
}

@end
