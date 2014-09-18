#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLGeoChatMessage;

@interface TLgeochats_StatedMessage : NSObject <TLObject>

@property (nonatomic, retain) TLGeoChatMessage *message;
@property (nonatomic, retain) NSArray *chats;
@property (nonatomic, retain) NSArray *users;
@property (nonatomic) int32_t seq;

@end

@interface TLgeochats_StatedMessage$geochats_statedMessage : TLgeochats_StatedMessage


@end

