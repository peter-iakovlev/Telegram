#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLRPChelp_saveNetworkStats : TLMetaRpc

@property (nonatomic, retain) NSArray *stats;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPChelp_saveNetworkStats$help_saveNetworkStats : TLRPChelp_saveNetworkStats


@end

