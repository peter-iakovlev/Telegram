#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLupload_CdnFile;

@interface TLRPCupload_getCdnFile : TLMetaRpc

@property (nonatomic, retain) NSData *file_token;
@property (nonatomic) int32_t offset;
@property (nonatomic) int32_t limit;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCupload_getCdnFile$upload_getCdnFile : TLRPCupload_getCdnFile


@end

