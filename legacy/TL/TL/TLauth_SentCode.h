#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLauth_SentCode : NSObject <TLObject>

@property (nonatomic) bool phone_registered;

@end

@interface TLauth_SentCode$auth_sentCodePreview : TLauth_SentCode

@property (nonatomic, retain) NSString *phone_code_hash;
@property (nonatomic, retain) NSString *phone_code_test;

@end

@interface TLauth_SentCode$auth_sentPassPhrase : TLauth_SentCode


@end

@interface TLauth_SentCode$auth_sentCode : TLauth_SentCode

@property (nonatomic, retain) NSString *phone_code_hash;
@property (nonatomic) int32_t send_call_timeout;
@property (nonatomic) bool is_password;

@end

@interface TLauth_SentCode$auth_sentAppCode : TLauth_SentCode

@property (nonatomic, retain) NSString *phone_code_hash;
@property (nonatomic) int32_t send_call_timeout;
@property (nonatomic) bool is_password;

@end

