#import <Foundation/Foundation.h>

@class TGBotReplyMarkup;

@interface TGBotContextResultSendMessageAuto : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSString *text;
@property (nonatomic, strong, readonly) NSArray *entities;
@property (nonatomic, strong, readonly) TGBotReplyMarkup *replyMarkup;

- (instancetype)initWithText:(NSString *)text entities:(NSArray *)entities replyMarkup:(TGBotReplyMarkup *)replyMarkup;

@end
