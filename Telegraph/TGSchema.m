#import "TGSchema.h"

@implementation TGSchema

+ (NSObject *)makeMutable:(NSObject *)object
{
    return object;
}

+ (NSString *)stringFromObject:(id)object
{
    if (object == nil)
        return nil;
    if ([object isKindOfClass:[NSString class]])
        return (NSString *)object;
    else if ([object isKindOfClass:[NSNumber class]])
        return [(NSNumber *)object stringValue];
    else if ([object isKindOfClass:[NSNull class]])
        return nil;
    
    TGLog(@"Warning: stringFromObject couldn't convert object");
    
    return nil;
}

+ (bool)canCreateStringFromObject:(id)object
{
    if ([object isKindOfClass:[NSString class]])
        return true;
    else if ([object isKindOfClass:[NSNumber class]])
        return true;
    else if ([object isKindOfClass:[NSNull class]])
        return false;
    
    return false;
}

+ (int)intFromObject:(id)object
{
    if ([object isKindOfClass:[NSNumber class]])
        return [(NSNumber *)object intValue];
    else if ([object isKindOfClass:[NSString class]])
        return [(NSString *)object intValue];
    else if ([object isKindOfClass:[NSNull class]])
        return 0;
    
    TGLog(@"Warning: intFromObject couldn't convert object");
    
    return 0;
}

+ (bool)canCreateIntFromObject:(id)object
{
    if ([object isKindOfClass:[NSNumber class]])
        return true;
    else if ([object isKindOfClass:[NSString class]])
        return true;
    else if ([object isKindOfClass:[NSNull class]])
        return false;
    
    return false;
}

+ (bool)boolFromObject:(id)object
{
    if ([object isKindOfClass:[NSNumber class]])
        return [(NSNumber *)object boolValue];
    else if ([object isKindOfClass:[NSString class]])
        return [(NSString *)object boolValue];
    else if ([object isKindOfClass:[NSNull class]])
        return false;
    
    TGLog(@"Warning: boolFromObject couldn't convert object");
    
    return false;
}

+ (bool)canCreateBoolFromObject:(id)object
{
    if ([object isKindOfClass:[NSNumber class]])
        return true;
    else if ([object isKindOfClass:[NSString class]])
        return true;
    else if ([object isKindOfClass:[NSNull class]])
        return false;
    
    return false;
}

+ (double)doubleFromObject:(id)object
{
    if ([object isKindOfClass:[NSNumber class]])
        return [(NSNumber *)object doubleValue];
    else if ([object isKindOfClass:[NSString class]])
        return [(NSString *)object doubleValue];
    else if ([object isKindOfClass:[NSNull class]])
        return 0;
    
    TGLog(@"Warning: doubleFromObject couldn't convert object");
    
    return 0;
}

+ (bool)canCreateDoubleFromObject:(id)object
{
    if ([object isKindOfClass:[NSNumber class]])
        return true;
    else if ([object isKindOfClass:[NSString class]])
        return true;
    else if ([object isKindOfClass:[NSNull class]])
        return false;
    
    return false;
}

+ (NSArray *)arrayFromObject:(id)object
{
    if ([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *arrayDescription = (NSDictionary *)object;
        int count = [self intFromObject:[arrayDescription objectForKey:@"count"]];
        NSArray *items = [arrayDescription objectForKey:@"items"];
        if (items != nil && [items isKindOfClass:[NSArray class]])
        {
            if (items.count != (NSUInteger)count)
            {
                TGLog(@"Warning: arrayFromObject: array.count != count");
            }
            return items;
        }
    }
    else if ([object isKindOfClass:[NSArray class]])
    {
        return object;
    }
    
    return nil;
}

+ (bool)canCreateArrayFromObject:(id)object
{
    if ([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *arrayDescription = (NSDictionary *)object;
        int count = [self intFromObject:[arrayDescription objectForKey:@"count"]];
        NSArray *items = [arrayDescription objectForKey:@"items"];
        if (items != nil && [items isKindOfClass:[NSArray class]])
        {
            if ((int)items.count != count)
            {
                return false;
            }
            return true;
        }
    }
    else if ([object isKindOfClass:[NSArray class]])
    {
        return true;
    }
    
    return false;
}

+ (NSObject *)checkSchema:(NSObject *)__unused object
{
    TGLog(@"Error: TGSchema::checkSchema: no default implementation provided");
    return nil;
}

@end
