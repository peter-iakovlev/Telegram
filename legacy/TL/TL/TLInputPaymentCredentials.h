#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLDataJSON;

@interface TLInputPaymentCredentials : NSObject <TLObject>


@end

@interface TLInputPaymentCredentials$inputPaymentCredentialsSaved : TLInputPaymentCredentials

@property (nonatomic, retain) NSString *n_id;
@property (nonatomic, retain) NSData *tmp_password;

@end

@interface TLInputPaymentCredentials$inputPaymentCredentials : TLInputPaymentCredentials

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) TLDataJSON *data;

@end

