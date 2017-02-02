#import "TGDeleteProfilePhotoFutureAction.h"

@implementation TGDeleteProfilePhotoFutureAction

- (id)initWithImageId:(int64_t)imageId accessHash:(int64_t)accessHash
{
    self = [super initWithType:TGDeleteProfilePhotoFutureActionType];
    if (self != nil)
    {
        _imageId = imageId;
        _accessHash = accessHash;
        
        self.uniqueId = imageId;
    }
    return self;
}

- (NSData *)serialize
{
    NSMutableData *data = [[NSMutableData alloc] init];
    
    [data appendBytes:&_imageId length:8];
    [data appendBytes:&_accessHash length:8];
    
    return data;
}

- (TGFutureAction *)deserialize:(NSData *)data
{
    int ptr = 0;
    
    int64_t valueImageId = 0;
    [data getBytes:&valueImageId range:NSMakeRange(0, 8)];
    ptr += 8;
    
    int64_t valueAccessHash = 0;
    [data getBytes:&valueAccessHash range:NSMakeRange(8, 8)];
    ptr += 8;
    
    return [[TGDeleteProfilePhotoFutureAction alloc] initWithImageId:valueImageId accessHash:valueAccessHash];
}

@end
