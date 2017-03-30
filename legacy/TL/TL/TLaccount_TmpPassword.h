#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLaccount_TmpPassword : NSObject <TLObject>

@property (nonatomic, retain) NSData *tmp_password;
@property (nonatomic) int32_t valid_until;

@end

@interface TLaccount_TmpPassword$account_tmpPassword : TLaccount_TmpPassword


@end

