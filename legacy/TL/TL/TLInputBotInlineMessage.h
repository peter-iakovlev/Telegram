#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLReplyMarkup;

@interface TLInputBotInlineMessage : NSObject <TLObject>

@property (nonatomic, retain) TLReplyMarkup *reply_markup;

@end

@interface TLInputBotInlineMessage$inputBotInlineMessageGame : TLInputBotInlineMessage


@end

