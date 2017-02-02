#import "EMImageData.h"

#import "EMImage.h"

static void EMImageDataRelease(void *info, const void *data, size_t size)
{
    if (info != NULL)
    {
        NSPurgeableData *data = (__bridge_transfer NSPurgeableData *)info;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^
        {
            [data endContentAccess]; 
        });
    }
}

typedef struct {
    NSUInteger width, height;
} EMImagePixelSize;

@interface EMImageData ()
{
    NSPurgeableData *_data;
    NSUInteger _bytesPerRow;
    EMImagePixelSize _pixelSize;
    
    void *_cachedImagePtr;
    UIImage *_cachedImage;
}

@end

@implementation EMImageData

- (instancetype)initWithSize:(CGSize)size generator:(void (^)(uint8_t *memory, NSUInteger bytesPerRow))generator image:(UIImage *__autoreleasing *)image
{
    self = [super init];
    if (self != nil)
    {
        _size = size;
        
        _pixelSize = (EMImagePixelSize){.width = (NSUInteger)size.width, .height = (NSUInteger)size.height};
        _bytesPerRow = ((4 * (int)_pixelSize.width) + 15) & (~15);
        _data = [[NSPurgeableData alloc] initWithLength:_bytesPerRow * _pixelSize.height];
        generator([_data mutableBytes], _bytesPerRow);
        
        if (image)
            *image = [self _createImage];
        else
            [_data endContentAccess];
    }
    return self;
}

- (void)dealloc
{
}

- (bool)isDiscarded
{
    return [_data isContentDiscarded];
}

- (UIImage *)image
{
    if ([_data beginContentAccess])
        return [self _createImage];
    
    return nil;
}

- (UIImage *)_createImage
{
    static CGColorSpaceRef colorSpace = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    });
    
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
    
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData((__bridge_retained void *)_data, [_data bytes], _bytesPerRow, EMImageDataRelease);
    
    CGImageRef image = CGImageCreate(_pixelSize.width, _pixelSize.height, 8, 32, _bytesPerRow, colorSpace, bitmapInfo, dataProvider, NULL, false, (CGColorRenderingIntent)0);
    
    CGDataProviderRelease(dataProvider);
    
    UIImage *result = [[UIImage alloc] initWithCGImage:image];
    
    CGImageRelease(image);
    
    return result;
}

@end
