#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLReplyMarkup : NSObject <TLObject>

@property (nonatomic) int32_t flags;

@end

@interface TLReplyMarkup$replyKeyboardHide : TLReplyMarkup


@end

@interface TLReplyMarkup$replyKeyboardForceReply : TLReplyMarkup


@end

@interface TLReplyMarkup$replyKeyboardMarkup : TLReplyMarkup

@property (nonatomic, retain) NSArray *rows;

@end

