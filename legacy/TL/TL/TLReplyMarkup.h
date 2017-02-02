#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLReplyMarkup : NSObject <TLObject>


@end

@interface TLReplyMarkup$replyKeyboardHide : TLReplyMarkup

@property (nonatomic) int32_t flags;

@end

@interface TLReplyMarkup$replyKeyboardForceReply : TLReplyMarkup

@property (nonatomic) int32_t flags;

@end

@interface TLReplyMarkup$replyKeyboardMarkup : TLReplyMarkup

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) NSArray *rows;

@end

@interface TLReplyMarkup$replyInlineMarkup : TLReplyMarkup

@property (nonatomic, retain) NSArray *rows;

@end

