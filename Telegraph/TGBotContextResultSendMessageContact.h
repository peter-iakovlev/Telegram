#import <Foundation/Foundation.h>

@class TGContactMediaAttachment;
@class TGBotReplyMarkup;

@interface TGBotContextResultSendMessageContact : NSObject <NSCoding>

@property (nonatomic, strong, readonly) TGContactMediaAttachment *contact;
@property (nonatomic, strong, readonly) TGBotReplyMarkup *replyMarkup;

- (instancetype)initWithContact:(TGContactMediaAttachment *)contact replyMarkup:(TGBotReplyMarkup *)replyMarkup;

@end
