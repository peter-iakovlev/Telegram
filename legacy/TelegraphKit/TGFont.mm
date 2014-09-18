#import "TGFont.h"

#import "NSObject+TGLock.h"

#import <map>

UIFont *TGSystemFontOfSize(CGFloat size)
{
    static bool useSystem = false;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        useSystem = iosMajorVersion() >= 7;
    });
    
    if (useSystem)
        return [UIFont systemFontOfSize:size];
    else
        return [UIFont fontWithName:@"HelveticaNeue" size:size];
}

UIFont *TGMediumSystemFontOfSize(CGFloat size)
{
    return [UIFont fontWithName:@"HelveticaNeue-Medium" size:size];
}

UIFont *TGBoldSystemFontOfSize(CGFloat size)
{
    static bool useSystem = false;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        useSystem = iosMajorVersion() >= 7;
    });
    
    if (useSystem)
        return [UIFont boldSystemFontOfSize:size];
    else
        return [UIFont fontWithName:@"HelveticaNeue-Medium" size:size];
}

UIFont *TGLightSystemFontOfSize(CGFloat size)
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:size];
}

UIFont *TGUltralightSystemFontOfSize(CGFloat size)
{
    return [UIFont fontWithName:@"HelveticaNeue-Thin" size:size];
}

UIFont *TGItalicSystemFontOfSize(CGFloat size)
{
    return [UIFont fontWithName:@"HelveticaNeue-Italic" size:size];
}

@implementation TGFont

+ (UIFont *)systemFontOfSize:(CGFloat)size
{
    return TGSystemFontOfSize(size);
}

+ (UIFont *)boldSystemFontOfSize:(CGFloat)size
{
    return TGBoldSystemFontOfSize(size);
}

@end

static std::map<int, CTFontRef> fontCache;
static TG_SYNCHRONIZED_DEFINE(fontCache) = PTHREAD_MUTEX_INITIALIZER;

CTFontRef TGCoreTextSystemFontOfSize(CGFloat size)
{
    int key = (int)(size * 2.0f);
    CTFontRef result = NULL;
    
    TG_SYNCHRONIZED_BEGIN(fontCache);
    auto it = fontCache.find(key);
    if (it != fontCache.end())
        result = it->second;
    else
    {
        result = CTFontCreateWithName(CFSTR("HelveticaNeue"), floorf(size * 2.0f) / 2.0f, NULL);
        fontCache[key] = result;
    }
    TG_SYNCHRONIZED_END(fontCache);
    
    return result;
}
