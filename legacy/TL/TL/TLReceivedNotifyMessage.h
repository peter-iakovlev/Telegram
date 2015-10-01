#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLReceivedNotifyMessage : NSObject <TLObject>

@property (nonatomic) int32_t n_id;
@property (nonatomic) int32_t flags;

@end

@interface TLReceivedNotifyMessage$receivedNotifyMessage : TLReceivedNotifyMessage


@end

