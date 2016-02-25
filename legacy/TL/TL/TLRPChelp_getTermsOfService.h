#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLhelp_TermsOfService;

@interface TLRPChelp_getTermsOfService : TLMetaRpc

@property (nonatomic, retain) NSString *lang_code;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPChelp_getTermsOfService$help_getTermsOfService : TLRPChelp_getTermsOfService


@end

