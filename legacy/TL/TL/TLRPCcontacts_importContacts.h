#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLcontacts_ImportedContacts;

@interface TLRPCcontacts_importContacts : TLMetaRpc

@property (nonatomic, retain) NSArray *contacts;
@property (nonatomic) bool replace;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCcontacts_importContacts$contacts_importContacts : TLRPCcontacts_importContacts


@end

