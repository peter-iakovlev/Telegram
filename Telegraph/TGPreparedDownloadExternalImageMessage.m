#import "TGPreparedDownloadExternalImageMessage.h"

#import "TGMessage.h"

#import "PSKeyValueCoder.h"

#import "TGDocumentHttpFileReference.h"

#import "TGMediaStoreContext.h"

#import "TGAppDelegate.h"
#import "TGPreparedLocalImageMessage.h"

@implementation TGPreparedDownloadExternalImageMessage

- (instancetype)initWithSearchResult:(TGExternalImageSearchResult *)searchResult imageInfo:(TGImageInfo *)imageInfo caption:(NSString *)caption replyMessage:(TGMessage *)replyMessage botContextResult:(TGBotContextResultAttachment *)botContextResult replyMarkup:(TGReplyMarkupAttachment *)replyMarkup {
    self = [super init];
    if (self != nil) {
        _searchResult = searchResult;
        _imageInfo = imageInfo;
        _caption = caption;
        self.replyMessage = replyMessage;
        self.botContextResult = botContextResult;
        self.replyMarkup = replyMarkup;
        
        self.executeOnAdd = ^{
            NSString *imageFilePath = [[[TGMediaStoreContext instance] temporaryFilesCache] getValuePathForKey:[searchResult.originalUrl dataUsingEncoding:NSUTF8StringEncoding]];
            
            if (imageFilePath != nil) {
                static NSString *filesDirectory = nil;
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^
                {
                    filesDirectory = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"files"];
                });
                
                NSString *photoDirectoryName = nil;
                photoDirectoryName = [[NSString alloc] initWithFormat:@"image-local-%" PRIx64 "", [TGImageMediaAttachment localImageIdForImageInfo:imageInfo]];
                NSString *photoDirectory = [filesDirectory stringByAppendingPathComponent:photoDirectoryName];
                
                NSString *imagePath = [photoDirectory stringByAppendingPathComponent:@"image.jpg"];
                [[NSFileManager defaultManager] createDirectoryAtPath:photoDirectory withIntermediateDirectories:true attributes:nil error:nil];
                NSError *error = nil;
                [[NSFileManager defaultManager] linkItemAtPath:imageFilePath toPath:imagePath error:&error];
                if (error != nil) {
                    TGLog(@"linkItemAtPath error: %@", error);
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
    
    TGImageMediaAttachment *imageAttachment = [[TGImageMediaAttachment alloc] init];
    imageAttachment.caption = _caption;
    imageAttachment.imageInfo = _imageInfo;
    
    [attachments addObject:imageAttachment];
    
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
    message.contentProperties = @{@"downloadExternalImageInfo": [[TGDownloadExternalImageInfo alloc] initWithSearchResult:_searchResult]};
    
    return message;
}

@end

@implementation TGDownloadExternalImageInfo

- (instancetype)initWithSearchResult:(TGExternalImageSearchResult *)searchResult {
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
