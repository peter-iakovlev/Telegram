#import "TGBotContextResult.h"

#import "TGImageMediaAttachment.h"

@interface TGBotContextImageResult : TGBotContextResult

@property (nonatomic, strong, readonly) TGImageMediaAttachment *image;

- (instancetype)initWithQueryId:(int64_t)queryId resultId:(NSString *)resultId type:(NSString *)type image:(TGImageMediaAttachment *)image sendMessage:(id)sendMessage;

@end
