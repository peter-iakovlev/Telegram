#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputBotInlineMessage;

@interface TLInputBotInlineResult : NSObject <TLObject>

@property (nonatomic, retain) NSString *n_id;
@property (nonatomic, retain) NSString *short_name;
@property (nonatomic, retain) TLInputBotInlineMessage *send_message;

@end

@interface TLInputBotInlineResult$inputBotInlineResultGame : TLInputBotInlineResult


@end

