#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLNewSession : NSObject <TLObject>

@property (nonatomic) int64_t first_msg_id;
@property (nonatomic) int64_t unique_id;
@property (nonatomic) int64_t server_salt;

@end

@interface TLNewSession$new_session_created : TLNewSession


@end

