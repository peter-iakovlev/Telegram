#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputWebFileLocation;
@class TLupload_WebFile;

@interface TLRPCupload_getWebFile : TLMetaRpc

@property (nonatomic, retain) TLInputWebFileLocation *location;
@property (nonatomic) int32_t offset;
@property (nonatomic) int32_t limit;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCupload_getWebFile$upload_getWebFile : TLRPCupload_getWebFile


@end

