#import "TLMetaRpc.h"

@class TLInputPeer;
@class TLReportReason;

@interface TLRPCmessages_report : TLMetaRpc

@property (nonatomic, strong) TLInputPeer *peer;
@property (nonatomic, strong) NSArray *n_id;
@property (nonatomic, strong) TLReportReason *reason;

@end
