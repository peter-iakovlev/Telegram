#import "TGBotContextResult.h"

#import <LegacyComponents/LegacyComponents.h>

@interface TGBotContextMediaResult : TGBotContextResult

@property (nonatomic, strong, readonly) TGImageMediaAttachment *photo;
@property (nonatomic, strong, readonly) TGDocumentMediaAttachment *document;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *resultDescription;

- (instancetype)initWithQueryId:(int64_t)queryId resultId:(NSString *)resultId type:(NSString *)type photo:(TGImageMediaAttachment *)photo document:(TGDocumentMediaAttachment *)document title:(NSString *)title resultDescription:(NSString *)resultDescription sendMessage:(id)sendMessage;

@end
