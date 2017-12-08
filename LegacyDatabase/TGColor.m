#import "TGColor.h"
#import <CommonCrypto/CommonDigest.h>

@implementation UIColor (TGColor)

+ (UIColor *)hexColor:(NSInteger)hex
{
    return [[UIColor alloc] initWithRed:(((hex >> 16) & 0xff) / 255.0f) green:(((hex >> 8) & 0xff) / 255.0f) blue:(((hex) & 0xff) / 255.0f) alpha:1.0f];
}

+ (UIColor *)hexColor:(NSInteger)hex withAlpha:(CGFloat)alpha
{
    return [[UIColor alloc] initWithRed:(((hex >> 16) & 0xff) / 255.0f) green:(((hex >> 8) & 0xff) / 255.0f) blue:(((hex) & 0xff) / 255.0f) alpha:alpha];
}

@end

@implementation TGColor

static inline int colorIndexForUid(int32_t uid, int32_t myUserId)
{
    static const int numColors = 8;
    
    int colorIndex = 0;
    
    char buf[16];
    snprintf(buf, 16, "%d%d", (int32_t)uid, (int32_t)myUserId);
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(buf, (CC_LONG)strlen(buf), digest);
    colorIndex = ABS(digest[ABS(uid % 16)]) % numColors;
    
    return colorIndex;
}

static inline int colorIndexForGroupId(int64_t groupId)
{
    static const int numColors = 4;
    
    int colorIndex = 0;
    
    char buf[16];
    snprintf(buf, 16, "%lld", groupId);
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(buf, (CC_LONG)strlen(buf), digest);
    colorIndex = ABS(digest[ABS(groupId % 16)]) % numColors;
    
    return colorIndex;
}

+ (NSArray *)placeholderColors
{
    static NSArray *colors;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        colors = @[ [UIColor hexColor:0xfc5c51],
                    [UIColor hexColor:0xfa790f],
                    [UIColor hexColor:0x0fb297],
                    [UIColor hexColor:0x3ca5ec],
                    [UIColor hexColor:0x3d72ed],
                    [UIColor hexColor:0x895dd5]
                    ];
//        colors = @[ [UIColor hexColor:0xfc5b67],
//                    [UIColor hexColor:0xfd9527],
//                    [UIColor hexColor:0x25dc75],
//                    [UIColor hexColor:0x1eb7fa],
//                    [UIColor hexColor:0x2b96f7],
//                    [UIColor hexColor:0x8d74e8]
//                    ];
    });
    
    return colors;
}

+ (UIColor *)colorForUserId:(int32_t)userId myUserId:(int32_t)myUserId
{
    NSArray *colors = [self placeholderColors];
    return colors[colorIndexForUid(userId, myUserId) % colors.count];
}

+ (UIColor *)colorForGroupId:(int64_t)groupId
{
    NSArray *colors = [self placeholderColors];
    return colors[colorIndexForGroupId(groupId) % colors.count];
}

+ (UIColor *)accentColor
{
    return [UIColor hexColor:0x2ea4e5];
}

+ (UIColor *)subtitleColor
{
    return [UIColor hexColor:0x8f8f8f];
}

@end
