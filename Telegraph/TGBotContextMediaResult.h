#import "TGBotContextResult.h"

#import "TGImageMediaAttachment.h"
#import "TGDocumentMediaAttachment.h"

//botInlineMediaResult flags:# id:string type:string photo:flags.0?Photo document:flags.1?Document title:flags.2?string description:flags.3?string send_message:BotInlineMessage = BotInlineResult;

@interface TGBotContextMediaResult : TGBotContextResult

@property (nonatomic, strong, readonly) TGImageMediaAttachment *photo;
@property (nonatomic, strong, readonly) TGDocumentMediaAttachment *document;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *resultDescription;

- (instancetype)initWithQueryId:(int64_t)queryId resultId:(NSString *)resultId type:(NSString *)type photo:(TGImageMediaAttachment *)photo document:(TGDocumentMediaAttachment *)document title:(NSString *)title resultDescription:(NSString *)resultDescription sendMessage:(id)sendMessage;

@end
