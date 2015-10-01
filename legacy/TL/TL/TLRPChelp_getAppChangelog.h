#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLhelp_AppChangelog;

@interface TLRPChelp_getAppChangelog : TLMetaRpc

@property (nonatomic, retain) NSString *device_model;
@property (nonatomic, retain) NSString *system_version;
@property (nonatomic, retain) NSString *app_version;
@property (nonatomic, retain) NSString *lang_code;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPChelp_getAppChangelog$help_getAppChangelog : TLRPChelp_getAppChangelog


@end

