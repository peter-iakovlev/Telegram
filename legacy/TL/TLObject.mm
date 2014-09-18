#import "TLObject.h"

#import <objc/runtime.h>

//static const char *constructorNameKey = "TL.constructorName";

@implementation NSArray (TL)

- (void)TLtagConstructorName:(int32_t)__unused constructorName
{
    //objc_setAssociatedObject(self, constructorNameKey, [[NSNumber alloc] initWithInt:constructorName], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (int32_t)TLconstructorName
{
    return 0;
    //return [(NSNumber *)objc_getAssociatedObject(self, constructorNameKey) intValue];
}

@end
