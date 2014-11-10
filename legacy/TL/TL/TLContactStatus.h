#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLUserStatus;

@interface TLContactStatus : NSObject <TLObject>

@property (nonatomic) int32_t user_id;
@property (nonatomic, retain) TLUserStatus *status;

@end

@interface TLContactStatus$contactStatus : TLContactStatus


@end

