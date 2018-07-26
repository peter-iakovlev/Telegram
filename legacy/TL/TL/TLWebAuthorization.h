#import "TLObject.h"
#import "TLMetaRpc.h"

@interface TLWebAuthorization : NSObject <TLObject>

@property (nonatomic) int64_t n_hash;
@property (nonatomic) int32_t bot_id;
@property (nonatomic, strong) NSString *domain;
@property (nonatomic, strong) NSString *browser;
@property (nonatomic, strong) NSString *platform;
@property (nonatomic) int32_t date_created;
@property (nonatomic) int32_t date_active;
@property (nonatomic, strong) NSString *ip;
@property (nonatomic, strong) NSString *region;

@end


@interface TLWebAuthorization$webAuthorization : TLWebAuthorization

@end
