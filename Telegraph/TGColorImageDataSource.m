#import "TGColorImageDataSource.h"

#import "TGStringUtils.h"

@implementation TGColorImageDataSource

+ (void)load
{
    @autoreleasepool
    {
        [TGImageDataSource registerDataSource:[[self alloc] init]];
    }
}

- (bool)canHandleUri:(NSString *)uri
{
    return [uri hasPrefix:@"color://"];
}

- (TGDataResource *)loadDataSyncWithUri:(NSString *)uri canWait:(bool)__unused canWait acceptPartialData:(bool)__unused acceptPartialData asyncTaskId:(__autoreleasing id *)__unused asyncTaskId progress:(void (^)(float))__unused progress partialCompletion:(void (^)(TGDataResource *))__unused partialCompletion completion:(void (^)(TGDataResource *))__unused completion
{
    if (![uri hasPrefix:@"color://?"])
        return nil;
    
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:@"color://?".length]];
    uint32_t color = (uint32_t)[args[@"color"] intValue];
    
    return [[TGDataResource alloc] initWithImage:[self imageWithColor:color] decoded:true];
}

- (id)loadDataAsyncWithUri:(NSString *)uri progress:(void (^)(float progress))progress partialCompletion:(void (^)(TGDataResource *resource))__unused partialCompletion completion:(void (^)(TGDataResource *resource))completion
{
    if ([uri hasPrefix:@"builtin-wallpaper://?"])
    {
        NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:@"color://?".length]];
        uint32_t color = [args[@"color"] intValue];
        
        TGDataResource *resource = [[TGDataResource alloc] initWithImage:[self imageWithColor:color] decoded:true];
        
        if (progress)
            progress(1.0f);
        
        if (completion)
            completion(resource);
    }
    else
    {   
        if (completion)
            completion(nil);
    }
    
    return nil;
}

- (UIImage *)imageWithColor:(uint32_t)color
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), true, 0.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, UIColorRGB(color).CGColor);
    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, 1.0f, 1.0f));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
