#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class NSArray_string;

@interface TLRPChelp_getRecentMeUrls : TLMetaRpc

@property (nonatomic, retain) NSString *referer;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPChelp_getRecentMeUrls$help_getRecentMeUrls : TLRPChelp_getRecentMeUrls


@end

