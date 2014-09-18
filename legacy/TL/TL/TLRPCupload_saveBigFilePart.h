#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLRPCupload_saveBigFilePart : TLMetaRpc

@property (nonatomic) int64_t file_id;
@property (nonatomic) int32_t file_part;
@property (nonatomic) int32_t file_total_parts;
@property (nonatomic, retain) NSData *bytes;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCupload_saveBigFilePart$upload_saveBigFilePart : TLRPCupload_saveBigFilePart


@end

