#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class NSArray_CdnFileHash;

@interface TLRPCupload_getCdnFileHashes : TLMetaRpc

@property (nonatomic, retain) NSData *file_token;
@property (nonatomic) int32_t offset;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCupload_getCdnFileHashes$upload_getCdnFileHashes : TLRPCupload_getCdnFileHashes


@end

