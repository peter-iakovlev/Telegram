#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLauth_SentCode;

@interface TLRPCauth_sendCode : TLMetaRpc

@property (nonatomic, retain) NSString *phone_number;
@property (nonatomic) int32_t sms_type;
@property (nonatomic) int32_t api_id;
@property (nonatomic, retain) NSString *api_hash;
@property (nonatomic, retain) NSString *lang_code;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCauth_sendCode$auth_sendCode : TLRPCauth_sendCode


@end

