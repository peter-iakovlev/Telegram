#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLmessages_AffectedMessages : NSObject <TLObject>

@property (nonatomic) int32_t pts;
@property (nonatomic) int32_t pts_count;

@end

@interface TLmessages_AffectedMessages$messages_affectedMessages : TLmessages_AffectedMessages


@end

