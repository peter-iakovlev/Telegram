#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLstorage_FileType;

@interface TLupload_File : NSObject <TLObject>

@property (nonatomic, retain) TLstorage_FileType *type;
@property (nonatomic) int32_t mtime;
@property (nonatomic, retain) NSData *bytes;

@end

@interface TLupload_File$upload_file : TLupload_File


@end

