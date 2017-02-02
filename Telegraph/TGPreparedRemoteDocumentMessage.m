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

#import "TGMediaStoreContext.h"

#import "TGMusicPlayerItemSignals.h"

#import "TGPreparedLocalDocumentMessage.h"

@implementation TGPreparedRemoteDocumentMessage

- (instancetype)initWithDocumentMedia:(TGDocumentMediaAttachment *)documentMedia replyMessage:(TGMessage *)replyMessage botContextResult:(TGBotContextResultAttachment *)botContextResult replyMarkup:(TGReplyMarkupAttachment *)replyMarkup
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
        _caption = documentMedia.caption;
        
        self.replyMessage = replyMessage;
        self.botContextResult = botContextResult;
        self.replyMarkup = replyMarkup;
        
        self.executeOnAdd = ^{
            NSString *fileName = nil;
            for (id attribute in documentMedia.attributes) {
                if ([attribute isKindOfClass:[TGDocumentAttributeFilename class]]) {
                    fileName = ((TGDocumentAttributeFilename *)attribute).filename;
                    break;
                }
            }
            
            if (fileName.length != 0) {
                NSString *cacheKey = cacheKeyForDocument(documentMedia);
                NSString *documentFilePath = [[[TGMediaStoreContext instance] temporaryFilesCache] getValuePathForKey:[cacheKey dataUsingEncoding:NSUTF8StringEncoding]];
                
                if (documentFilePath != nil) {
                    NSString *documentPath = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:documentMedia.documentId version:documentMedia.version];
                    [[NSFileManager defaultManager] createDirectoryAtPath:documentPath withIntermediateDirectories:true attributes:nil error:nil];
                    NSError *error = nil;
                    if (![[NSFileManager defaultManager] fileExistsAtPath:[documentPath stringByAppendingPathComponent:fileName]]) {
                        [[NSFileManager defaultManager] linkItemAtPath:documentFilePath toPath:[documentPath stringByAppendingPathComponent:fileName] error:&error];
                        if (error != nil) {
                            TGLog(@"linkItemAtPath error: %@", error);
                        }
                    }
                }
            }
        };
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
    documentAttachment.caption = _caption;
    [attachments addObject:documentAttachment];
    
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

- (TGDocumentMediaAttachment *)document {
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
    documentAttachment.caption = _caption;
    return documentAttachment;
}

@end
