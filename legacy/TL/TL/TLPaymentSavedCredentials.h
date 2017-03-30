#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLPaymentSavedCredentials : NSObject <TLObject>

@property (nonatomic, retain) NSString *n_id;
@property (nonatomic, retain) NSString *title;

@end

@interface TLPaymentSavedCredentials$paymentSavedCredentialsCard : TLPaymentSavedCredentials


@end

