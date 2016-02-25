#import <Foundation/Foundation.h>

#import "TLMetaRpc.h"
#import "TLObject.h"

#import "TLMetaRpc.h"

@class TLInputChannel;

@interface TLRPCchannels_editMessage : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic) bool no_webpage;
@property (nonatomic, strong) TLInputChannel *channel;
@property (nonatomic) int32_t n_id;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSArray *entities;

@end
