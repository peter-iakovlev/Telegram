#import "NSOutputStream+TL.h"

#import <endian.h>

static inline int roundUp(int numToRound, int multiple)
{
    if (multiple == 0)
    {
        return numToRound;
    }
    
    int remainder = numToRound % multiple;
    if (remainder == 0)
    {
        return numToRound;
    }
    
    return numToRound + multiple - remainder;
}

@implementation NSOutputStream (TL)

- (NSData *)currentBytes
{
    return [self propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
}

- (void)writeInt32:(int32_t)value
{
#if __BYTE_ORDER == __LITTLE_ENDIAN
    [self write:(const uint8_t *)&value maxLength:4];
#elif __BYTE_ORDER == __BIG_ENDIAN
#   error "Big endian is not implemented"
#else
#   error "Unknown byte order"
#endif
}

- (void)writeInt64:(int64_t)value
{
#if __BYTE_ORDER == __LITTLE_ENDIAN
    [self write:(const uint8_t *)&value maxLength:8];
#elif __BYTE_ORDER == __BIG_ENDIAN
#   error "Big endian is not implemented"
#else
#   error "Unknown byte order"
#endif
}

- (void)writeDouble:(double)value
{
#if __BYTE_ORDER == __LITTLE_ENDIAN
    [self write:(const uint8_t *)&value maxLength:8];
#elif __BYTE_ORDER == __BIG_ENDIAN
#   error "Big endian is not implemented"
#else
#   error "Unknown byte order"
#endif
}

- (void)writeData:(NSData *)data
{
    [self write:(uint8_t *)data.bytes maxLength:data.length];
}

- (void)writeString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    int32_t length = (int32_t)data.length;
    
    if (data == nil || length == 0)
    {
        [self writeInt32:0];
        return;
    }
    
    int paddingBytes = 0;
    
    if (length >= 254)
    {
        uint8_t tmp = 254;
        [self write:&tmp maxLength:1];
        
#if __BYTE_ORDER == __LITTLE_ENDIAN
        [self write:(const uint8_t *)&length maxLength:3];
#elif __BYTE_ORDER == __BIG_ENDIAN
#   error "Big endian is not implemented"
#else
#   error "Unknown byte order"
#endif
        
        paddingBytes = roundUp(length, 4) - length;
    }
    else
    {
        [self write:(const uint8_t *)&length maxLength:1];
        paddingBytes = roundUp(length + 1, 4) - (length + 1);
    }
    
    [self write:(uint8_t *)data.bytes maxLength:length];
    
    uint8_t tmp = 0;
    for (int i = 0; i < paddingBytes; i++)
        [self write:&tmp maxLength:1];
}

- (void)writeBytes:(NSData *)data
{
    int32_t length = (int32_t)data.length;
    
    if (data == nil || length == 0)
    {
        [self writeInt32:0];
        return;
    }
    
    int paddingBytes = 0;
    
    if (length >= 254)
    {
        uint8_t tmp = 254;
        [self write:&tmp maxLength:1];
        
#if __BYTE_ORDER == __LITTLE_ENDIAN
        [self write:(const uint8_t *)&length maxLength:3];
#elif __BYTE_ORDER == __BIG_ENDIAN
#   error "Big endian is not implemented"
#else
#   error "Unknown byte order"
#endif
        
        paddingBytes = roundUp(length, 4) - length;
    }
    else
    {
        [self write:(const uint8_t *)&length maxLength:1];
        paddingBytes = roundUp(length + 1, 4) - (length + 1);
    }
    
    [self write:(uint8_t *)data.bytes maxLength:length];
    
    uint8_t tmp = 0;
    for (int i = 0; i < paddingBytes; i++)
        [self write:&tmp maxLength:1];
}

@end
