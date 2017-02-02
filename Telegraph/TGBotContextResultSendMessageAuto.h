#import <Foundation/Foundation.h>

@class TGBotReplyMarkup;

@interface TGBotContextResultSendMessageAuto : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSString *caption;
@property (nonatomic, strong, readonly) TGBotReplyMarkup *replyMarkup;

- (instancetype)initWithCaption:(NSString *)caption replyMarkup:(TGBotReplyMarkup *)replyMarkup;

@end
