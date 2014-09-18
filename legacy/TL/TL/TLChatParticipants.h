#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLChatParticipants : NSObject <TLObject>

@property (nonatomic) int32_t chat_id;

@end

@interface TLChatParticipants$chatParticipantsForbidden : TLChatParticipants


@end

@interface TLChatParticipants$chatParticipants : TLChatParticipants

@property (nonatomic) int32_t admin_id;
@property (nonatomic, retain) NSArray *participants;
@property (nonatomic) int32_t version;

@end

