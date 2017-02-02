#import <Foundation/Foundation.h>

@class TGBotReplyMarkup;

@interface TGBotContextResultSendMessageText : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSString *message;
@property (nonatomic, strong, readonly) NSArray *entities;
@property (nonatomic, readonly) bool noWebpage;
@property (nonatomic, strong, readonly) TGBotReplyMarkup *replyMarkup;

- (instancetype)initWithMessage:(NSString *)message entities:(NSArray *)entities noWebpage:(bool)noWebpage replyMarkup:(TGBotReplyMarkup *)replyMarkup;

@end
