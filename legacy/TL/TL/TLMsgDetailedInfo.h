#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLMsgDetailedInfo : NSObject <TLObject>

@property (nonatomic) int64_t answer_msg_id;
@property (nonatomic) int32_t bytes;
@property (nonatomic) int32_t status;

@end

@interface TLMsgDetailedInfo$msg_detailed_info : TLMsgDetailedInfo

@property (nonatomic) int64_t msg_id;

@end

@interface TLMsgDetailedInfo$msg_new_detailed_info : TLMsgDetailedInfo


@end

