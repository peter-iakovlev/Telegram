#import "TGWidgetSignals.h"
#import <libkern/OSAtomic.h>
#import <CommonCrypto/CommonDigest.h>
#import "TGColor.h"

#import "TGWidgetUser.h"

NSString *const TGWidgetSyncIdentifier = @"org.telegram.WidgetUpdate";

@implementation TGWidgetSignals

#pragma mark - Signal

+ (SSignal *)peopleSignal
{
    SSignal *dataSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        NSDictionary *data = [self widgetData];
        [subscriber putNext:data];
        [subscriber putCompletion];
        
        return nil;
    }];
    
    return dataSignal;
}

#pragma mark - 

+ (SSignal *)userAvatarWithUser:(TGWidgetUser *)user clientUserId:(int32_t)clientUserId
{
    int32_t peerId = user.identifier;
    
    SSignal *placeholderSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        NSString *letters = [user initials];
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(56.0f, 56.0f), false, 0.0f);
        CGContextRef contextRef = UIGraphicsGetCurrentContext();
        
        CGContextBeginPath(contextRef);
        CGContextAddEllipseInRect(contextRef, CGRectMake(0.0f, 0.0f, 56.0f, 56.0f));
        CGContextClip(contextRef);
        
        NSArray *gradientColors = [self gradientColorsForPeerId:peerId myUserId:clientUserId];
        CGColorRef colors[2] =
        {
            CGColorRetain(((UIColor *)gradientColors[0]).CGColor),
            CGColorRetain(((UIColor *)gradientColors[1]).CGColor)
        };
        
        CFArrayRef colorsArray = CFArrayCreate(kCFAllocatorDefault, (const void **)&colors, 2, NULL);
        CGFloat locations[2] = {0.0f, 1.0f};
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colorsArray, (CGFloat const *)&locations);
        
        CFRelease(colorsArray);
        CFRelease(colors[0]);
        CFRelease(colors[1]);
        
        CGColorSpaceRelease(colorSpace);
        
        CGContextDrawLinearGradient(contextRef, gradient, CGPointMake(0.0f, 0.0f), CGPointMake(0.0f, 56.0f), 0);
        
        CFRelease(gradient);
        
        UIFont *font = [UIFont systemFontOfSize:letters.length == 1 ? 22.0f : 20.0f weight:UIFontWeightLight];
        CGSize lettersSize = [letters sizeWithAttributes:@{NSFontAttributeName: font}];
        [letters drawAtPoint:CGPointMake((CGFloat)(floor(56.0f - lettersSize.width) / 2.0f), (CGFloat)(floor(56.0f - lettersSize.height) / 2.0f)) withAttributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor whiteColor]}];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    
        [subscriber putNext:image];
        [subscriber putCompletion];
        
        return nil;
    }];
    
    SSignal *avatarSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        if (user.avatarPath == nil)
        {
            [subscriber putError:nil];
            return nil;
        }
        
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:user.avatarPath];
        if (image != nil)
        {
            [subscriber putNext:image];
            [subscriber putCompletion];
            return nil;
        }
        
        [subscriber putError:nil];
        return nil;
    }];
    
    return [avatarSignal catch:^SSignal *(__unused id error)
    {
        return placeholderSignal;
    }];
}

#pragma mark -

+ (NSDictionary *)widgetData
{
    NSData *widgetData = [self loadWidgetData];
    if (widgetData == nil)
        return nil;
    
    NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:widgetData];
    return dict;
}

#pragma mark - File

+ (NSString *)filePath
{
    NSString *documentsPath;
    NSString *groupName = [@"group." stringByAppendingString:[[NSBundle mainBundle] bundleIdentifier]];
    groupName = [groupName substringWithRange:NSMakeRange(0, groupName.length - @".Widget".length)];
    
    NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupName];
    if (groupURL != nil)
    {
        NSString *path = [[groupURL path] stringByAppendingPathComponent:@"Documents"];
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:true attributes:nil error:NULL];
        
        documentsPath = path;
    }

    return [documentsPath stringByAppendingPathComponent:@"widget.data"];
}

+ (NSData *)loadWidgetData
{
    return [NSData dataWithContentsOfFile:[self filePath]];
}

#pragma mark - 

static inline int colorIndexForUid(int32_t uid, int32_t myUserId)
{
    static const int numColors = 8;
    
    int colorIndex = 0;
    
    char buf[16];
    snprintf(buf, 16, "%d%d", (int)uid, (int)myUserId);
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(buf, (CC_LONG)strlen(buf), digest);
    colorIndex = ABS(digest[ABS(uid % 16)]) % numColors;
    
    return colorIndex;
}

+ (NSArray *)gradientColorsForPeerId:(int32_t)peerId myUserId:(int32_t)myUserId
{
    static OSSpinLock lock = 0;
    static NSMutableDictionary *dict = nil;
    static NSArray *colors = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        dict = [[NSMutableDictionary alloc] init];
        colors = @
        [
            @[TGColorWithHex(0xff516a), TGColorWithHex(0xff885e)],
            @[TGColorWithHex(0xffa85c), TGColorWithHex(0xffcd6a)],
            @[TGColorWithHex(0x54cb68), TGColorWithHex(0xa0de7e)],
            @[TGColorWithHex(0x2a9ef1), TGColorWithHex(0x72d5fd)],
            @[TGColorWithHex(0x665fff), TGColorWithHex(0x82b1ff)],
            @[TGColorWithHex(0xd669ed), TGColorWithHex(0xe0a2f3)],
        ];
    });
    
    OSSpinLockLock(&lock);
    NSNumber *key = [NSNumber numberWithLongLong:((long long)peerId)];
    NSNumber *index = dict[key];
    if (index == nil)
    {
        index = @(colorIndexForUid(peerId, myUserId));
        dict[key] = index;
    }
    OSSpinLockUnlock(&lock);
    
    return colors[[index intValue] % 6];
}

@end
