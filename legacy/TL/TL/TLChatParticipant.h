#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLChatParticipant : NSObject <TLObject>

@property (nonatomic) int32_t user_id;
@property (nonatomic) int32_t inviter_id;
@property (nonatomic) int32_t date;

@end

@interface TLChatParticipant$chatParticipant : TLChatParticipant


@end

