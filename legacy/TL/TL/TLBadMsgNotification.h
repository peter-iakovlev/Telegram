#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLBadMsgNotification : NSObject <TLObject>

@property (nonatomic) int64_t bad_msg_id;
@property (nonatomic) int32_t bad_msg_seqno;
@property (nonatomic) int32_t error_code;

@end

@interface TLBadMsgNotification$bad_msg_notification : TLBadMsgNotification


@end

@interface TLBadMsgNotification$bad_server_salt : TLBadMsgNotification

@property (nonatomic) int64_t n_new_server_salt;

@end

