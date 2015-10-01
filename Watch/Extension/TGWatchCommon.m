#import "TGWatchCommon.h"

#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>

void TGSwizzleMethodImplementation(Class class, SEL originalSelector, SEL modifiedSelector)
{
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method modifiedMethod = class_getInstanceMethod(class, modifiedSelector);
    
    if (class_addMethod(class, originalSelector, method_getImplementation(modifiedMethod), method_getTypeEncoding(modifiedMethod)))
    {
        class_replaceMethod(class, modifiedSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else
    {
        method_exchangeImplementations(originalMethod, modifiedMethod);
    }
}

CGSize TGWatchScreenSize()
{
    static CGSize size;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        size = [[WKInterfaceDevice currentDevice] screenBounds].size;
    });
    
    return size;
}

TGScreenType TGWatchScreenType()
{
    static TGScreenType type;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        CGSize size = TGWatchScreenSize();
        if (size.width < 150)
            type = TGScreenType38mm;
        else
            type = TGScreenType42mm;
    });
    
    return type;
}

@implementation NSNumber (IntegerTypes)

- (int32_t)int32Value
{
    return (int32_t)[self intValue];
}

- (int64_t)int64Value
{
    return (int64_t)[self longLongValue];
}

@end
