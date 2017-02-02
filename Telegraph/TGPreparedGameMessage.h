#import "TGPreparedMessage.h"

@class TGGameMediaAttachment;
@class TGReplyMarkupAttachment;
@class TGMessage;

@interface TGPreparedGameMessage : TGPreparedMessage

@property (nonatomic, strong, readonly) TGGameMediaAttachment *game;

- (instancetype)initWithGame:(TGGameMediaAttachment *)game replyMessage:(TGMessage *)replyMessage replyMarkup:(TGReplyMarkupAttachment *)replyMarkup;

@end
