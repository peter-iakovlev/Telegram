#import "TGSharedLocationSignals.h"

#import "TGSharedMediaSignals.h"
#import "TGImageBlur.h"

@implementation TGSharedLocationSignals

+ (SSignal *)squareLocationThumbnailForLatitude:(double)latitude longitude:(double)longitude ofSize:(CGSize)size threadPool:(SThreadPool *)threadPool memoryCache:(TGMemoryImageCache *)__unused memoryCache persistentCache:(TGModernCache *)__unused persistentCache pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock
{
    CGSize pixelSize = CGSizeMake(size.width * 2.0f, size.height * 2.0f);
    CGSize renderSize = CGSizeMake(pixelSize.width, pixelSize.height + 30.0f);
    
    NSString *url = [[NSString alloc] initWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%.5f,%.5f&zoom=15&size=%dx%d&sensor=false&scale=%d&format=jpg&mobile=true", latitude, longitude, (int)(renderSize.width), (int)(renderSize.height), 2];
    
    SSignal *downloadSignal = [TGSharedMediaSignals memoizedDataSignalForHttpUrl:url];
    
    return [[downloadSignal deliverOnThreadPool:threadPool] map:^id(NSData *data)
    {
        UIImage *image = [[UIImage alloc] initWithData:data];
        return TGScaleAndCropImageToPixelSize(image, pixelSize, renderSize, NULL, pixelProcessingBlock);
    }];
}

@end
