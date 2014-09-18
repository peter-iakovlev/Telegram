#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLhelp_AppPrefs;

@interface TLRPChelp_getAppPrefs : TLMetaRpc

@property (nonatomic) int32_t api_id;
@property (nonatomic, retain) NSString *api_hash;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPChelp_getAppPrefs$help_getAppPrefs : TLRPChelp_getAppPrefs


@end

