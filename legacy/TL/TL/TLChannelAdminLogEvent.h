#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLChannelAdminLogEventAction;

@interface TLChannelAdminLogEvent : NSObject <TLObject>

@property (nonatomic) int64_t n_id;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t user_id;
@property (nonatomic, retain) TLChannelAdminLogEventAction *action;

@end

@interface TLChannelAdminLogEvent$channelAdminLogEvent : TLChannelAdminLogEvent


@end

