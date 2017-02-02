#import <Foundation/Foundation.h>

@class TGLocationMediaAttachment;
@class TGBotReplyMarkup;

@interface TGBotContextResultSendMessageGeo : NSObject <NSCoding>

@property (nonatomic, strong, readonly) TGLocationMediaAttachment *location;
@property (nonatomic, strong, readonly) TGBotReplyMarkup *replyMarkup;

- (instancetype)initWithLocation:(TGLocationMediaAttachment *)location replyMarkup:(TGBotReplyMarkup *)replyMarkup;

@end
