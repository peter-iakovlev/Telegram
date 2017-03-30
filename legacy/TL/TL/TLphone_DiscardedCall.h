#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLUpdates;

@interface TLphone_DiscardedCall : NSObject <TLObject>

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) TLUpdates *updates;

@end

@interface TLphone_DiscardedCall$phone_discardedCall : TLphone_DiscardedCall


@end

