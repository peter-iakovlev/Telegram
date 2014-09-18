#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLRPCauth_sendInvites : TLMetaRpc

@property (nonatomic, retain) NSArray *phone_numbers;
@property (nonatomic, retain) NSString *message;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCauth_sendInvites$auth_sendInvites : TLRPCauth_sendInvites


@end

