#import "TGMemoryImageCache+Signals.h"

@implementation TGMemoryImageCacheEvent

- (instancetype)initWithImage:(UIImage *)image attributes:(NSDictionary *)attributes
{
    self = [super init];
    if (self != nil)
    {
        _image = image;
        _attributes = attributes;
    }
    return self;
}

@end

@implementation TGMemoryImageCache (Signals)

- (SSignal *)signalForKey:(NSString *)key
{
    NSDictionary *attributes = nil;
    UIImage *image = [self imageForKey:key attributes:&attributes];
    if (image != nil)
        return [SSignal single:[[TGMemoryImageCacheEvent alloc] initWithImage:image attributes:attributes]];
    else
        return [SSignal fail:nil];
}

- (SSignal *)imageSignalForKey:(NSString *)key
{
    UIImage *image = [self imageForKey:key attributes:NULL];
    if (image != nil)
        return [SSignal single:image];
    else
        return [SSignal fail:nil];
}

@end
