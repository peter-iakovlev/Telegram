#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLcontacts_Contacts;

@interface TLRPCcontacts_getContacts : TLMetaRpc

@property (nonatomic, retain) NSString *n_hash;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCcontacts_getContacts$contacts_getContacts : TLRPCcontacts_getContacts


@end

