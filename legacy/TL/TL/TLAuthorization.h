#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLAuthorization : NSObject <TLObject>

@property (nonatomic) int64_t n_hash;
@property (nonatomic) int32_t flags;
@property (nonatomic, retain) NSString *device_model;
@property (nonatomic, retain) NSString *platform;
@property (nonatomic, retain) NSString *system_version;
@property (nonatomic) int32_t api_id;
@property (nonatomic, retain) NSString *app_name;
@property (nonatomic, retain) NSString *app_version;
@property (nonatomic) int32_t date_created;
@property (nonatomic) int32_t date_active;
@property (nonatomic, retain) NSString *ip;
@property (nonatomic, retain) NSString *country;
@property (nonatomic, retain) NSString *region;

@end

@interface TLAuthorization$authorization : TLAuthorization


@end

