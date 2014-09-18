#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLhelp_AppUpdate;

@interface TLRPChelp_getAppUpdate : TLMetaRpc

@property (nonatomic, retain) NSString *device_model;
@property (nonatomic, retain) NSString *system_version;
@property (nonatomic, retain) NSString *app_version;
@property (nonatomic, retain) NSString *lang_code;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPChelp_getAppUpdate$help_getAppUpdate : TLRPChelp_getAppUpdate


@end

