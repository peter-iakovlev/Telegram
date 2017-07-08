#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLupload_CdnFile : NSObject <TLObject>


@end

@interface TLupload_CdnFile$upload_cdnFileReuploadNeeded : TLupload_CdnFile

@property (nonatomic, retain) NSData *request_token;

@end

@interface TLupload_CdnFile$upload_cdnFile : TLupload_CdnFile

@property (nonatomic, retain) NSData *bytes;

@end

