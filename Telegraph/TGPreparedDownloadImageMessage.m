#import "TGPreparedDownloadImageMessage.h"

#import "TGMessage.h"

@implementation TGPreparedDownloadImageMessage

- (instancetype)initWithImageInfo:(TGImageInfo *)imageInfo
{
    self = [super init];
    if (self != nil)
    {
#ifdef DEBUG
        NSAssert(imageInfo != nil, @"imageInfo should not be nil");
#endif
        
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
    imageAttachment.imageInfo = _imageInfo;
    message.mediaAttachments = @[imageAttachment];
    
    return message;
}

@end
