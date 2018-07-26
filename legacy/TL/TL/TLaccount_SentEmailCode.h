#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLaccount_SentEmailCode : NSObject <TLObject>

@property (nonatomic, retain) NSString *email_pattern;
@property (nonatomic) int32_t length;

@end

@interface TLaccount_SentEmailCode$account_sentEmailCode : TLaccount_SentEmailCode

@end
