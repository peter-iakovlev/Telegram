#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLDocument;

@interface TLRPCmessages_getDocumentByHash : TLMetaRpc

@property (nonatomic, retain) NSData *sha256;
@property (nonatomic) int32_t size;
@property (nonatomic, retain) NSString *mime_type;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_getDocumentByHash$messages_getDocumentByHash : TLRPCmessages_getDocumentByHash


@end

