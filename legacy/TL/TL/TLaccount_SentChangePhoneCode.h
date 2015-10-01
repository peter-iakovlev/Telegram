#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLaccount_SentChangePhoneCode : NSObject <TLObject>

@property (nonatomic, retain) NSString *phone_code_hash;
@property (nonatomic) int32_t send_call_timeout;

@end

@interface TLaccount_SentChangePhoneCode$account_sentChangePhoneCode : TLaccount_SentChangePhoneCode


@end

