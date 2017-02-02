#import "EMImage.h"

@interface EMImage ()
{
    NSPurgeableData *_data;
}

@end

@implementation EMImage

- (instancetype)initWithCGImage:(CGImageRef)image data:(NSPurgeableData *)data
{
    self = [super initWithCGImage:image];
    if (self != nil)
    {
        _data = data;
    }
    return self;
}

- (void)dealloc
{
    [_data endContentAccess];
}

@end
