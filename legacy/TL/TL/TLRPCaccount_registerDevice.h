#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLRPCaccount_registerDevice : TLMetaRpc

@property (nonatomic) int32_t token_type;
@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) NSString *device_model;
@property (nonatomic, retain) NSString *system_version;
@property (nonatomic, retain) NSString *app_version;
@property (nonatomic) bool app_sandbox;
@property (nonatomic, retain) NSString *lang_code;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_registerDevice$account_registerDevice : TLRPCaccount_registerDevice


@end

