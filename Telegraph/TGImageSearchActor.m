#import "TGImageSearchActor.h"

#import "TGTelegraph.h"

#import "ActionStage.h"
#import "TGStringUtils.h"

#import "TGImageInfo.h"

#import "TGViewController.h"

#import "TGAppDelegate.h"

@interface TGImageSearchActor ()

@property (nonatomic) int offset;

@property (nonatomic, strong) NSString *currentQuery;
@property (nonatomic, strong) NSString *currentArguments;

@end

@implementation TGImageSearchActor


+ (NSString *)genericPath
{
    return @"/tg/content/googleImages/@";
}

- (void)execute:(NSDictionary *)options
{
    _currentQuery = [options objectForKey:@"query"];
    _offset = [[options objectForKey:@"offset"] intValue];
    
    _currentArguments = [[NSString alloc] initWithFormat:@"$skip=%d&$top=%d", [[options objectForKey:@"offset"] intValue], [TGViewController isWidescreen] ? 56 : 48];
    
    NSData *cachedData = [self cachedResponse:_currentQuery arguments:_currentArguments];
    if (cachedData != nil)
        [self httpRequestSuccess:nil response:cachedData];
    else
    {
        self.cancelToken = [TGTelegraphInstance doRequestRawHttp:[[NSString alloc] initWithFormat:@"https://api.datamarket.azure.com/Bing/Search/v1/Image?Query='%@'&$skip=%d&$top=%d&$format=json&Adult='Off'", [TGStringUtils stringByEscapingForURL:_currentQuery], [[options objectForKey:@"offset"] intValue], [TGViewController isWidescreen] ? 56 : 48] maxRetryCount:0 acceptCodes:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:400], [[NSNumber alloc] initWithInt:403], nil] httpHeaders:nil actor:self];
    }
}

- (NSString *)parseImageSize:(NSDictionary *)desc size:(CGSize *)size length:(int *)length
{
    NSString *mediaUrl = [desc objectForKey:@"MediaUrl"];
    NSNumber *nWidth = [desc objectForKey:@"Width"];
    NSNumber *nHeight = [desc objectForKey:@"Height"];
    NSNumber *nSize = desc[@"FileSize"];
    
    if (![mediaUrl isKindOfClass:[NSString class]])
        return nil;
    
    if (![nWidth respondsToSelector:@selector(intValue)])
        return nil;
    
    if (![nHeight respondsToSelector:@selector(intValue)])
        return nil;
    
    if (size != NULL)
        *size = CGSizeMake([nWidth intValue], [nHeight intValue]);
    
    if (length != NULL && [nSize respondsToSelector:@selector(intValue)])
        *length = [nSize intValue];
    
    return mediaUrl;
}

- (NSString *)cachePath
{
    NSString *cachesPath = [TGAppDelegate cachePath];
    
    NSString *diskCachePath = [cachesPath stringByAppendingPathComponent:@"websearch"];
    
    NSFileManager *fileManager = [ActionStageInstance() globalFileManager];
    if (![fileManager fileExistsAtPath:diskCachePath])
        [fileManager createDirectoryAtPath:diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];

    return diskCachePath;
}

- (NSData *)cachedResponse:(NSString *)query arguments:(NSString *)arguments
{
    NSString *filePath = [[self cachePath] stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@_%@.search", TGStringMD5(query), TGStringMD5(arguments)]];
    
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    
    if (data != nil && data.length >= 8)
    {
        int ptr = 0;
        
        int currentTime = (int)(CFAbsoluteTimeGetCurrent());
        
        int version = 0;
        [data getBytes:&version range:NSMakeRange(ptr, 4)];
        ptr += 4;
        
        int date = 0;
        [data getBytes:&date range:NSMakeRange(ptr, 4)];
        ptr += 4;
        
        if (currentTime < date + 60 * 60 * 24 * 5)
        {
            int length = 0;
            [data getBytes:&length range:NSMakeRange(ptr, 4)];
            ptr += 4;
            
            NSData *resultData = [data subdataWithRange:NSMakeRange(ptr, length)];
            ptr += length;
            
            return resultData;
        }
        else
            [[ActionStageInstance() globalFileManager] removeItemAtPath:filePath error:nil];
    }
    
    return nil;
}

- (void)storeCachedResponse:(NSString *)query arguments:(NSString *)arguments response:(NSData *)response
{
    NSMutableData *data = [[NSMutableData alloc] init];
    
    int version = 0;
    [data appendBytes:&version length:4];
    
    int date = (int)(CFAbsoluteTimeGetCurrent());
    [data appendBytes:&date length:4];
    
    int length = (int)response.length;
    [data appendBytes:&length length:4];
    
    [data appendData:response];
    
    [data writeToFile:[[self cachePath] stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@_%@.search", TGStringMD5(query), TGStringMD5(arguments)]] atomically:true];
}

- (void)httpRequestSuccess:(NSString *)__unused url response:(NSData *)response
{
    //TGLog(@"%@", [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]);
    
    id rootObject = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
    if (rootObject == nil || ![rootObject isKindOfClass:[NSDictionary class]])
    {
        TGLog(@"%@", [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]);
        [ActionStageInstance() actionFailed:self.path reason:-1];
        return;
    }
    
    bool canLoadMore = false;
    
    rootObject = [rootObject objectForKey:@"d"];
    if (rootObject == nil || ![rootObject isKindOfClass:[NSDictionary class]])
    {
        TGLog(@"%@", [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]);
        [ActionStageInstance() actionFailed:self.path reason:-1];
        return;
    }
    
    canLoadMore = [[rootObject objectForKey:@"__next"] isKindOfClass:[NSString class]] && [(NSString *)[rootObject objectForKey:@"__next"] length] != 0;
    
    NSArray *results = [rootObject objectForKey:@"results"];
    if (![results isKindOfClass:[NSArray class]])
    {
        TGLog(@"%@", [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]);
        [ActionStageInstance() actionFailed:self.path reason:-1];
        return;
    }
    
    NSMutableArray *imageResults = [[NSMutableArray alloc] init];
    
    for (NSDictionary *itemDesc in results)
    {
        NSDictionary *thumbnail = [itemDesc objectForKey:@"Thumbnail"];
        if (![thumbnail isKindOfClass:[NSDictionary class]])
            continue;
     
        CGSize fullSize = CGSizeZero;
        int fullFileSize = 0;
        NSString *fullUrl = [self parseImageSize:itemDesc size:&fullSize length:&fullFileSize];
        
        CGSize thumbSize = CGSizeZero;
        NSString *thumbUrl = [self parseImageSize:thumbnail size:&thumbSize length:NULL];
        
        if (fullUrl != nil && thumbUrl != nil)
        {
            TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
            [imageInfo addImageWithSize:thumbSize url:thumbUrl fileSize:0];
            [imageInfo addImageWithSize:fullSize url:fullUrl fileSize:fullFileSize];
            
            [imageResults addObject:imageInfo];
        }
    }
    
    if (imageResults.count != 0)
        [self storeCachedResponse:_currentQuery arguments:_currentArguments response:response];
    
    [ActionStageInstance() actionCompleted:self.path result:[[NSDictionary alloc] initWithObjectsAndKeys:imageResults, @"images", [[NSNumber alloc] initWithInt:_offset], @"offset", [[NSNumber alloc] initWithBool:canLoadMore], @"canLoadMore", nil]];
}

- (void)httpRequestFailed:(NSString *)__unused url
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
