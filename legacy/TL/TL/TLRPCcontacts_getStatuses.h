#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class NSArray_ContactStatus;

@interface TLRPCcontacts_getStatuses : TLMetaRpc


- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCcontacts_getStatuses$contacts_getStatuses : TLRPCcontacts_getStatuses


@end

