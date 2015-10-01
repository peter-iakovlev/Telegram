#import "TGUploadAvatarFutureAction.h"

#import "TGAppDelegate.h"

@implementation TGUploadAvatarFutureAction

- (id)initWithOriginalFileUrl:(NSString *)originalFileUrl latitude:(double)latitude longitude:(double)longitude
{
    self = [super initWithType:TGUploadAvatarFutureActionType];
    if (self != nil)
    {
        _originalFileUrl = originalFileUrl;
        _latitude = latitude;
        _longitude = longitude;
    }
    return self;
}

- (NSData *)serialize
{
    NSMutableData *data = [[NSMutableData alloc] init];
    
    NSData *originalFileUrlBytes = [_originalFileUrl dataUsingEncoding:NSUTF8StringEncoding];
    int length = (int)originalFileUrlBytes.length;
    [data appendBytes:&length length:4];
    [data appendData:originalFileUrlBytes];
    
    [data appendBytes:&_latitude length:8];
    [data appendBytes:&_longitude length:8];
    
    return data;
}

- (TGFutureAction *)deserialize:(NSData *)data
{
    int ptr = 0;
    
    int length = 0;
    [data getBytes:&length range:NSMakeRange(ptr, 4)];
    ptr += 4;
    
    uint8_t *bytes = malloc(length);
    [data getBytes:bytes range:NSMakeRange(ptr, length)];
    ptr += length;
    
    NSString *originalFileUrl = [[NSString alloc] initWithBytesNoCopy:bytes length:length encoding:NSUTF8StringEncoding freeWhenDone:true];
    
    double latitude = 0.0;
    double longitude = 0.0;
    
    if (ptr + 16 <= (int)data.length)
    {
        [data getBytes:&latitude range:NSMakeRange(ptr, 8)];
        ptr += 8;
        [data getBytes:&longitude range:NSMakeRange(ptr, 8)];
        ptr += 8;
    }
    
    return [[TGUploadAvatarFutureAction alloc] initWithOriginalFileUrl:originalFileUrl latitude:latitude longitude:longitude];
}

- (void)prepareForDeletion
{
    NSString *tmpImagesPath = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"upload"];
    static NSFileManager *fileManager = nil;
    if (fileManager == nil)
        fileManager = [[NSFileManager alloc] init];
    NSError *error = nil;
    [fileManager createDirectoryAtPath:tmpImagesPath withIntermediateDirectories:true attributes:nil error:&error];
    NSString *absoluteFilePath = [tmpImagesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bin", _originalFileUrl]];
    
    [fileManager removeItemAtPath:absoluteFilePath error:nil];
    
    [super prepareForDeletion];
}

@end
