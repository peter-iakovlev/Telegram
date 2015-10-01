#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputChannel;
@class TLUpdates;

@interface TLRPCchannels_editTitle : TLMetaRpc

@property (nonatomic, retain) TLInputChannel *channel;
@property (nonatomic, retain) NSString *title;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCchannels_editTitle$channels_editTitle : TLRPCchannels_editTitle


@end

