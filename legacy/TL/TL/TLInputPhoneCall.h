#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLInputPhoneCall : NSObject <TLObject>

@property (nonatomic) int64_t n_id;
@property (nonatomic) int64_t access_hash;

@end

@interface TLInputPhoneCall$inputPhoneCall : TLInputPhoneCall


@end

