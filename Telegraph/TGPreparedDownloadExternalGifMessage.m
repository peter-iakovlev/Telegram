#import "TGPreparedDownloadExternalGifMessage.h"

#import "TGMessage.h"

#import "PSKeyValueCoder.h"

#import "TGDocumentHttpFileReference.h"

#import "TGMediaStoreContext.h"

#import "TGAppDelegate.h"
#import "TGPreparedLocalDocumentMessage.h"

@implementation TGPreparedDownloadExternalGifMessage

- (instancetype)initWithSearchResult:(TGExternalGifSearchResult *)searchResult localDocumentId:(int64_t)localDocumentId mimeType:(NSString *)mimeType thumbnailInfo:(TGImageInfo *)thumbnailInfo attributes:(NSArray *)attributes caption:(NSString *)caption replyMessage:(TGMessage *)replyMessage botContextResult:(TGBotContextResultAttachment *)botContextResult replyMarkup:(TGReplyMarkupAttachment *)replyMarkup {
    self = [super init];
    if (self != nil) {
        _searchResult = searchResult;
        _localDocumentId = localDocumentId;
        _mimeType = mimeType;
        _thumbnailInfo = thumbnailInfo;
        _attributes = attributes;
        _caption = caption;
        self.replyMessage = replyMessage;
        self.botContextResult = botContextResult;
        self.replyMarkup = replyMarkup;
        _documentUrl = searchResult.originalUrl;
        
        self.executeOnAdd = ^{
            NSString *fileName = nil;
            for (id attribute in attributes) {
                if ([attribute isKindOfClass:[TGDocumentAttributeFilename class]]) {
                    fileName = ((TGDocumentAttributeFilename *)attribute).filename;
                    break;
                }
            }
            
            if (fileName.length != 0) {
                NSString *videoFilePath = [[[TGMediaStoreContext instance] temporaryFilesCache] getValuePathForKey:[searchResult.originalUrl dataUsingEncoding:NSUTF8StringEncoding]];

                if (videoFilePath != nil) {
                    NSString *documentPath = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:localDocumentId version:0];
                    [[NSFileManager defaultManager] createDirectoryAtPath:documentPath withIntermediateDirectories:true attributes:nil error:nil];
                    NSError *error = nil;
                    [[NSFileManager defaultManager] linkItemAtPath:videoFilePath toPath:[documentPath stringByAppendingPathComponent:fileName] error:&error];
                    if (error != nil) {
                        TGLog(@"linkItemAtPath error: %@", error);
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
    documentAttachment.localDocumentId = _localDocumentId;
    documentAttachment.size = _size;
    documentAttachment.mimeType = _mimeType;
    documentAttachment.thumbnailInfo = _thumbnailInfo;
    documentAttachment.documentUri = _searchResult.originalUrl;
    documentAttachment.attributes = _attributes;
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
    message.contentProperties = @{@"downloadExternalGifInfo": [[TGDownloadExternalGifInfo alloc] initWithSearchResult:_searchResult]};
    
    return message;
}

@end

@implementation TGDownloadExternalGifInfo

- (instancetype)initWithSearchResult:(TGExternalGifSearchResult *)searchResult {
    self = [super init];
    if (self != nil) {
        _searchResult = searchResult;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder {
    return [self initWithSearchResult:[NSKeyedUnarchiver unarchiveObjectWithData:[coder decodeDataCorCKey:"searchResult"]]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder {
    [coder encodeData:[NSKeyedArchiver archivedDataWithRootObject:_searchResult] forCKey:"searchResult"];
}

@end
