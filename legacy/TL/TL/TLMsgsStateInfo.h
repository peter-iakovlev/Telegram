#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLMsgsStateInfo : NSObject <TLObject>

@property (nonatomic) int64_t req_msg_id;
@property (nonatomic, retain) NSString *info;

@end

@interface TLMsgsStateInfo$msgs_state_info : TLMsgsStateInfo


@end

