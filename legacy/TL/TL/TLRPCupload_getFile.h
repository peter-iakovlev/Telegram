#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputFileLocation;
@class TLupload_File;

@interface TLRPCupload_getFile : TLMetaRpc

@property (nonatomic, retain) TLInputFileLocation *location;
@property (nonatomic) int32_t offset;
@property (nonatomic) int32_t limit;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCupload_getFile$upload_getFile : TLRPCupload_getFile


@end

