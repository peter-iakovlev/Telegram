#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPeer;
@class TLReportReason;

@interface TLRPCaccount_reportPeer : TLMetaRpc

@property (nonatomic, retain) TLInputPeer *peer;
@property (nonatomic, retain) TLReportReason *reason;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_reportPeer$account_reportPeer : TLRPCaccount_reportPeer


@end

