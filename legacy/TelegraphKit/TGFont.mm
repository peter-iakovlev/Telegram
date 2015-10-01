#import "TGFont.h"

#import "NSObject+TGLock.h"

#import <map>

NSString *TGSystemFontBaseName() {
    if (iosMajorVersion() >= 9) {
        return @".SFUIText";
    } else {
        return @"HelveticaNeue";
    }
}

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
    static bool useSystem = false;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        useSystem = iosMajorVersion() >= 9;
    });
    
    if (useSystem) {
        return [UIFont systemFontOfSize:size weight:UIFontWeightMedium];
    } else {
        return [UIFont fontWithName:@"HelveticaNeue-Medium" size:size];
    }
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
    static bool useSystem = false;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        useSystem = iosMajorVersion() >= 9;
    });
    
    if (useSystem) {
        return [UIFont systemFontOfSize:size weight:UIFontWeightLight];
    } else {
        return [UIFont fontWithName:@"HelveticaNeue-Light" size:size];
    }
}

UIFont *TGUltralightSystemFontOfSize(CGFloat size)
{
    if (iosMajorVersion() >= 7)
        return [UIFont fontWithName:@"HelveticaNeue-Thin" size:size];
    else
        return [UIFont fontWithName:@"HelveticaNeue-Light" size:size];
}

UIFont *TGItalicSystemFontOfSize(CGFloat size)
{
    return [UIFont italicSystemFontOfSize:size];
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

static std::map<int, CTFontRef> systemFontCache;
static std::map<int, CTFontRef> lightFontCache;
static std::map<int, CTFontRef> mediumFontCache;
static TG_SYNCHRONIZED_DEFINE(systemFontCache) = PTHREAD_MUTEX_INITIALIZER;

CTFontRef TGCoreTextSystemFontOfSize(CGFloat size)
{
    int key = (int)(size * 2.0f);
    CTFontRef result = NULL;
    
    TG_SYNCHRONIZED_BEGIN(systemFontCache);
    auto it = systemFontCache.find(key);
    if (it != systemFontCache.end())
        result = it->second;
    else
    {
        if (false && iosMajorVersion() >= 9) {
            result = CTFontCreateWithName(CFSTR(".SFUIText-Regular"), CGFloor(size * 2.0f) / 2.0f, NULL);
        } else {
            result = CTFontCreateWithName(CFSTR("HelveticaNeue"), CGFloor(size * 2.0f) / 2.0f, NULL);
        }
        systemFontCache[key] = result;
    }
    TG_SYNCHRONIZED_END(systemFontCache);
    
    return result;
}

CTFontRef TGCoreTextLightFontOfSize(CGFloat size)
{
    int key = (int)(size * 2.0f);
    CTFontRef result = NULL;
    
    TG_SYNCHRONIZED_BEGIN(systemFontCache);
    auto it = lightFontCache.find(key);
    if (it != lightFontCache.end())
        result = it->second;
    else
    {
        if (false && iosMajorVersion() >= 9) {
            result = CTFontCreateWithName(CFSTR(".SFUIText-Light"), CGFloor(size * 2.0f) / 2.0f, NULL);
        } else {
            result = CTFontCreateWithName(CFSTR("HelveticaNeue-Light"), CGFloor(size * 2.0f) / 2.0f, NULL);
        }
        lightFontCache[key] = result;
    }
    TG_SYNCHRONIZED_END(systemFontCache);
    
    return result;
}

CTFontRef TGCoreTextMediumFontOfSize(CGFloat size)
{
    int key = (int)(size * 2.0f);
    CTFontRef result = NULL;
    
    TG_SYNCHRONIZED_BEGIN(systemFontCache);
    auto it = mediumFontCache.find(key);
    if (it != mediumFontCache.end())
        result = it->second;
    else
    {
        if (false && iosMajorVersion() >= 9) {
            result = CTFontCreateWithName(CFSTR(".SFUIText-Medium"), CGFloor(size * 2.0f) / 2.0f, NULL);
        } else {
            result = CTFontCreateWithName(CFSTR("HelveticaNeue-Medium"), CGFloor(size * 2.0f) / 2.0f, NULL);
        }
        mediumFontCache[key] = result;
    }
    TG_SYNCHRONIZED_END(systemFontCache);
    
    return result;
}
