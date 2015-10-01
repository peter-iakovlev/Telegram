#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputChannel;
@class TLmessages_Messages;

@interface TLRPCchannels_getImportantHistory : TLMetaRpc

@property (nonatomic, retain) TLInputChannel *channel;
@property (nonatomic) int32_t offset_id;
@property (nonatomic) int32_t add_offset;
@property (nonatomic) int32_t limit;
@property (nonatomic) int32_t max_id;
@property (nonatomic) int32_t min_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCchannels_getImportantHistory$channels_getImportantHistory : TLRPCchannels_getImportantHistory


@end

