#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLaccount_SentChangePhoneCode;

@interface TLRPCaccount_sendChangePhoneCode : TLMetaRpc

@property (nonatomic, retain) NSString *phone_number;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_sendChangePhoneCode$account_sendChangePhoneCode : TLRPCaccount_sendChangePhoneCode


@end

