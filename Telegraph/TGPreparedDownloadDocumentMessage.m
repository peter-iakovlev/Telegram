#import "TGPreparedDownloadDocumentMessage.h"

#import "TGMessage.h"

#import "PSKeyValueCoder.h"

@implementation TGPreparedDownloadDocumentMessage

- (instancetype)initWithGiphyId:(NSString *)giphyId documentUrl:(NSString *)documentUrl localDocumentId:(int64_t)localDocumentId mimeType:(NSString *)mimeType size:(int)size thumbnailInfo:(TGImageInfo *)thumbnailInfo attributes:(NSArray *)attributes replyMessage:(TGMessage *)replyMessage replyMarkup:(TGReplyMarkupAttachment *)replyMarkup
{
    self = [super init];
    if (self != nil)
    {
        _giphyId = giphyId;
        _documentUrl = documentUrl;
        _localDocumentId = localDocumentId;
        _attributes = attributes;
        _mimeType = mimeType;
        _size = size;
        _thumbnailInfo = thumbnailInfo;
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
    
    TGDocumentMediaAttachment *documentAttachment = [[TGDocumentMediaAttachment alloc] init];
    documentAttachment.localDocumentId = _localDocumentId;
    documentAttachment.size = _size;
    documentAttachment.attributes = _attributes;
    documentAttachment.mimeType = _mimeType;
    documentAttachment.thumbnailInfo = _thumbnailInfo;
    
    [attachments addObject:documentAttachment];
    
    if (self.replyMessage != nil)
    {
        TGReplyMessageMediaAttachment *replyMedia = [[TGReplyMessageMediaAttachment alloc] init];
        replyMedia.replyMessageId = self.replyMessage.mid;
        replyMedia.replyMessage = self.replyMessage;
        [attachments addObject:replyMedia];
    }
    
    if (self.replyMarkup != nil) {
        [attachments addObject:self.replyMarkup];
    }
    
    message.mediaAttachments = attachments;
    message.contentProperties = @{@"downloadDocumentUrl": [[TGDownloadDocumentUrl alloc] initWithGiphyId:_giphyId documentUrl:_documentUrl]};
    
    return message;
}

@end

@implementation TGDownloadDocumentUrl

- (instancetype)initWithGiphyId:(NSString *)giphyId documentUrl:(NSString *)documentUrl
{
    self = [super init];
    if (self != nil)
    {
        _giphyId = giphyId;
        _documentUrl = documentUrl;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    return [self initWithGiphyId:[coder decodeStringForCKey:"giphyId"] documentUrl:[coder decodeStringForCKey:"documentUrl"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeString:_giphyId forCKey:"giphyId"];
    [coder encodeString:_documentUrl forCKey:"documentUrl"];
}

@end
