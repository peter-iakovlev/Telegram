#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLstorage_FileType;

@interface TLupload_WebFile : NSObject <TLObject>

@property (nonatomic) int32_t size;
@property (nonatomic, retain) NSString *mime_type;
@property (nonatomic, retain) TLstorage_FileType *file_type;
@property (nonatomic) int32_t mtime;
@property (nonatomic, retain) NSData *bytes;

@end

@interface TLupload_WebFile$upload_webFile : TLupload_WebFile


@end

