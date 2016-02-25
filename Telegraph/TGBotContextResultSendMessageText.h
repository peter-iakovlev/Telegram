#import <Foundation/Foundation.h>

//message:string no_webpage:flags.0?true entities:flags.1?Vector<MessageEntity>

@interface TGBotContextResultSendMessageText : NSObject

@property (nonatomic, strong, readonly) NSString *message;
@property (nonatomic, strong, readonly) NSArray *entities;
@property (nonatomic, readonly) bool noWebpage;

- (instancetype)initWithMessage:(NSString *)message entities:(NSArray *)entities noWebpage:(bool)noWebpage;

@end
