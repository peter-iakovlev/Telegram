#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputChannel;
@class TLInputUser;
@class TLChannelParticipantRole;

@interface TLRPCchannels_editAdmin : TLMetaRpc

@property (nonatomic, retain) TLInputChannel *channel;
@property (nonatomic, retain) TLInputUser *user_id;
@property (nonatomic, retain) TLChannelParticipantRole *role;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCchannels_editAdmin$channels_editAdmin : TLRPCchannels_editAdmin


@end

