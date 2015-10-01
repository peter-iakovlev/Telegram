#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLRPCupdates_subscribe : TLMetaRpc

@property (nonatomic, retain) NSArray *users;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCupdates_subscribe$updates_subscribe : TLRPCupdates_subscribe


@end

