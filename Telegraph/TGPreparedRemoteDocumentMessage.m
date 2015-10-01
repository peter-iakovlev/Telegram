/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPreparedRemoteDocumentMessage.h"

#import "TGDocumentMediaAttachment.h"
#import "TGImageInfo.h"
#import "TGMessage.h"

@implementation TGPreparedRemoteDocumentMessage

- (instancetype)initWithDocumentMedia:(TGDocumentMediaAttachment *)documentMedia replyMessage:(TGMessage *)replyMessage
{
    self = [super init];
    if (self != nil)
    {
        _documentId = documentMedia.documentId;
        _accessHash = documentMedia.accessHash;
        _datacenterId = documentMedia.datacenterId;
        _userId = documentMedia.userId;
        _documentDate = documentMedia.date;
        _mimeType = documentMedia.mimeType;
        _size = documentMedia.size;
        _thumbnailInfo = documentMedia.thumbnailInfo;
        _attributes = documentMedia.attributes;
        
        _replyMessage = replyMessage;
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
    
    TGDocumentMediaAttachment *documentAttachment = [[TGDocumentMediaAttachment alloc] init];
    documentAttachment.documentId = _documentId;
    documentAttachment.accessHash = _accessHash;
    documentAttachment.datacenterId = _datacenterId;
    documentAttachment.userId = _userId;
    documentAttachment.date = _documentDate;
    documentAttachment.attributes = _attributes;
    documentAttachment.mimeType = _mimeType;
    documentAttachment.size = _size;
    documentAttachment.thumbnailInfo = _thumbnailInfo;
    [attachments addObject:documentAttachment];
    
    if (_replyMessage != nil)
    {
        TGReplyMessageMediaAttachment *replyMedia = [[TGReplyMessageMediaAttachment alloc] init];
        replyMedia.replyMessageId = _replyMessage.mid;
        replyMedia.replyMessage = _replyMessage;
        [attachments addObject:replyMedia];
    }
    
    message.mediaAttachments = attachments;
    
    return message;
}

@end
