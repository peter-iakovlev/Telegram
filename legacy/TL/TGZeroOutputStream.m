#import "TGZeroOutputStream.h"

@implementation TGZeroOutputStream

@synthesize currentLength = _currentLength;

- (NSInteger)write:(const uint8_t *)__unused buffer maxLength:(NSUInteger)len
{
    _currentLength += len;
    return (NSInteger)len;
}

@end
