#import "TGCallIdenticonView.h"

@implementation TGCallIdenticonView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.layer.magnificationFilter = kCAFilterNearest;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if (self.onTap != nil)
        self.onTap();
}

static int32_t get_bits(uint8_t const *bytes, unsigned int bitOffset, unsigned int numBits)
{
    uint8_t const *data = bytes;
    numBits = (unsigned int)pow(2, numBits) - 1; //this will only work up to 32 bits, of course
    data += bitOffset / 8;
    bitOffset %= 8;
    return (*((int*)data) >> bitOffset) & numBits;
}

- (void)setSha1:(NSData *)sha1 sha256:(NSData *)sha256
{
    CGSize size = CGSizeMake(24, 24);
    uint8_t bits[128];
    memset(bits, 0, 128);
    
    uint8_t additionalBits[256 * 8];
    memset(additionalBits, 0, 256 * 8);
    
    [sha1 getBytes:bits length:MIN((NSUInteger)128, sha1.length)];
    [sha256 getBytes:additionalBits length:MIN((NSUInteger)256, sha256.length)];
    
    static NSArray *colors;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        colors = @
        [
         UIColorRGBA(0xffffff, 0.0f),
         UIColorRGBA(0xffffff, 1.0f),
         UIColorRGBA(0xffffff, 0.6f),
         UIColorRGBA(0xffffff, 0.2f)
        ];
    });
    
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [colors[0] CGColor]);
    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, size.width, size.height));
    
    if (sha256 == nil) {
        int bitPointer = 0;
        
        CGFloat rectSize = size.width / 8.0f;
        
        for (int iy = 0; iy < 8; iy++)
        {
            for (int ix = 0; ix < 8; ix++)
            {
                int32_t byteValue = get_bits(bits, bitPointer, 2);
                bitPointer += 2;
                int colorIndex = ABS(byteValue) % 4;
                
                CGContextSetFillColorWithColor(context, [colors[colorIndex] CGColor]);
                
                CGRect rect = CGRectMake(ix * rectSize, iy * rectSize, rectSize, rectSize);
                if (size.width > 200) {
                    rect.origin.x = CGCeil(rect.origin.x);
                    rect.origin.y = CGCeil(rect.origin.y);
                    rect.size.width = CGCeil(rect.size.width);
                    rect.size.height = CGCeil(rect.size.height);
                }
                CGContextFillRect(context, rect);
            }
        }
    } else {
        int bitPointer = 0;
        
        CGFloat rectSize = size.width / 12.0f;
        
        for (int iy = 0; iy < 12; iy++)
        {
            for (int ix = 0; ix < 12; ix++)
            {
                int32_t byteValue = 0;
                if (bitPointer < 128) {
                    byteValue = get_bits(bits, bitPointer, 2);
                } else {
                    byteValue = get_bits(additionalBits, bitPointer - 128, 2);
                }
                bitPointer += 2;
                int colorIndex = ABS(byteValue) % 4;
                
                CGContextSetFillColorWithColor(context, [colors[colorIndex] CGColor]);
                
                CGRect rect = CGRectMake(ix * rectSize, iy * rectSize, rectSize, rectSize);
                if (size.width > 200) {
                    rect.origin.x = CGCeil(rect.origin.x);
                    rect.origin.y = CGCeil(rect.origin.y);
                    rect.size.width = CGCeil(rect.size.width);
                    rect.size.height = CGCeil(rect.size.height);
                }
                CGContextFillRect(context, rect);
            }
        }
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self setImage:image];
}

@end
