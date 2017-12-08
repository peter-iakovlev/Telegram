#import <Foundation/Foundation.h>

#import "TL/TLMetaScheme.h"

@interface TLRPCmessages_search : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic, strong) TLInputPeer *peer;
@property (nonatomic, strong) NSString *q;
@property (nonatomic) TLInputUser *from_id;
@property (nonatomic, strong) TLMessagesFilter *filter;
@property (nonatomic) int32_t min_date;
@property (nonatomic) int32_t max_date;
@property (nonatomic) int32_t offset;
@property (nonatomic) int32_t max_id;
@property (nonatomic) int32_t limit;

@end
