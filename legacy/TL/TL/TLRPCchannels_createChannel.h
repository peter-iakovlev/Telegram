#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLUpdates;

@interface TLRPCchannels_createChannel : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *about;
@property (nonatomic, retain) NSArray *users;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCchannels_createChannel$channels_createChannel : TLRPCchannels_createChannel


@end

