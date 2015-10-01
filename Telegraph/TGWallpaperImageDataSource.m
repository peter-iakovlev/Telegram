/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGWallpaperImageDataSource.h"

#import "TGStringUtils.h"

@implementation TGWallpaperImageDataSource

+ (void)load
{
    @autoreleasepool
    {
        [TGImageDataSource registerDataSource:[[TGWallpaperImageDataSource alloc] init]];
    }
}

- (bool)canHandleUri:(NSString *)uri
{
    return [uri hasPrefix:@"builtin-wallpaper://"];
}

- (TGDataResource *)loadDataSyncWithUri:(NSString *)uri canWait:(bool)canWait acceptPartialData:(bool)__unused acceptPartialData asyncTaskId:(__autoreleasing id *)__unused asyncTaskId progress:(void (^)(float))__unused progress partialCompletion:(void (^)(TGDataResource *))__unused partialCompletion completion:(void (^)(TGDataResource *))__unused completion
{
    if (![uri hasPrefix:@"builtin-wallpaper://?"])
        return nil;
    
    if (!canWait)
        return nil;
    
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:@"builtin-wallpaper://?".length]];
    int builtinId = [args[@"id"] intValue];
    NSString *sizeVariant = args[@"size"];
    
    return [self _loadWallpaper:builtinId sizeVariant:sizeVariant];
}

- (TGDataResource *)_loadWallpaper:(int)wallpaperId sizeVariant:(NSString *)sizeVariant
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[[NSString alloc] initWithFormat:@"%@builtin-wallpaper-%d%@", [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? @"pad-" : @"", wallpaperId, sizeVariant == nil ? @"" : [[NSString alloc] initWithFormat:@"-%@", sizeVariant]] ofType:@"jpg"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    return [[TGDataResource alloc] initWithData:data];
}

- (id)loadDataAsyncWithUri:(NSString *)uri progress:(void (^)(float progress))progress partialCompletion:(void (^)(TGDataResource *resource))__unused partialCompletion completion:(void (^)(TGDataResource *resource))completion
{
    if ([uri hasPrefix:@"builtin-wallpaper://?"])
    {
        NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:@"builtin-wallpaper://?".length]];
        int builtinId = [args[@"id"] intValue];
        NSString *sizeVariant = args[@"size"];
        
        TGDataResource *resource = [self _loadWallpaper:builtinId sizeVariant:sizeVariant];
        
        if (progress)
            progress(1.0f);
        
        if (completion)
            completion(resource);
    }
    else
    {
#ifdef DEBUG
        NSAssert(false, @"Unrecognized URI");
#endif
        
        if (completion)
            completion(nil);
    }
    
    return nil;
}

- (void)cancelRetrievalById:(id)__unused retrievalId
{
}

@end
