#import "TGBingSearchActor.h"

#import "ActionStage.h"

#import "TGTelegraph.h"

#import "TGStringUtils.h"
#import "TGPhoneUtils.h"

#import "TGBingSearchResultItem.h"

@interface TGBingSearchActor () <TGRawHttpActor>
{
    NSArray *_currentItems;
}

@end

@implementation TGBingSearchActor

+ (void)load
{
    [ASActor registerActorClass:self];
}

+ (NSString *)genericPath
{
    return @"/search/bing/@";
}

- (id)objectAtDictionaryPath:(NSString *)path dictionary:(NSDictionary *)dictionary
{
    if ([dictionary respondsToSelector:@selector(objectForKey:)])
    {
        NSRange range = [path rangeOfString:@"."];
        if (range.location == NSNotFound)
            return dictionary[path];
        else
            return [self objectAtDictionaryPath:[path substringFromIndex:range.location + 1] dictionary:dictionary[[path substringToIndex:range.location]]];
    }
    
    return nil;
}

- (void)execute:(NSDictionary *)options
{
    _currentItems = options[@"currentItems"];
    
    NSString *authKey = @"300f7735cfd04393a38d7838a0bf246b";
    
    bool enableFilter = false;
    TGUser *user = [TGDatabaseInstance() loadUser:[TGTelegraphInstance clientUserId]];
    if (user.phoneNumber.length != 0)
    {
        NSString *cleanPhone = [TGPhoneUtils cleanPhone:user.phoneNumber];
        NSArray *filterPrefixes = @[@"44", @"49", @"43", @"1", @"31"];
        for (NSString *prefix in filterPrefixes)
        {
            if ([cleanPhone hasPrefix:prefix])
            {
                enableFilter = true;
                break;
            }
        }
    }
    
    NSDictionary *headers = @{ @"Ocp-Apim-Subscription-Key": authKey };
    
    self.cancelToken = [TGTelegraphInstance doRequestRawHttp:[[NSString alloc] initWithFormat:@"https://api.cognitive.microsoft.com/bing/v5.0/images/search?q='%@'&offset=%d&count=%d&$format=json&safeSearch=%@", [TGStringUtils stringByEscapingForURL:options[@"query"]], (int)_currentItems.count, 56, enableFilter ? @"Strict" : @"Off"] maxRetryCount:0 acceptCodes:@[@400, @403] httpHeaders:headers actor:self];
}

- (void)httpRequestSuccess:(NSString *)__unused url response:(NSData *)response
{
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:_currentItems];
    bool moreResultsAvailable = false;
    
    @try {
        NSInteger offset = _currentItems.count;
        NSInteger count = 56;
        
        NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
        NSArray *list = [self objectAtDictionaryPath:@"value" dictionary:rootDict];
        NSNumber *totalCount = [self objectAtDictionaryPath:@"totalEstimatedMatches" dictionary:rootDict];
        
        if ([totalCount respondsToSelector:@selector(intValue)] && offset < [totalCount intValue] - count)
            moreResultsAvailable = true;
        if ([list respondsToSelector:@selector(objectAtIndex:)])
        {
            for (NSDictionary *dict in list)
            {
                NSString *previewUrl = [self objectAtDictionaryPath:@"thumbnailUrl" dictionary:dict];
                NSNumber *previewWidth = [self objectAtDictionaryPath:@"thumbnail.width" dictionary:dict];
                NSNumber *previewHeight = [self objectAtDictionaryPath:@"thumbnail.height" dictionary:dict];
                
                NSString *imageUrl = [self objectAtDictionaryPath:@"contentUrl" dictionary:dict];
                NSNumber *imageWidth = [self objectAtDictionaryPath:@"width" dictionary:dict];
                NSNumber *imageHeight = [self objectAtDictionaryPath:@"height" dictionary:dict];
                
                if ([previewUrl respondsToSelector:@selector(characterAtIndex:)] && [previewWidth respondsToSelector:@selector(intValue)] && [previewHeight respondsToSelector:@selector(intValue)] && [imageUrl respondsToSelector:@selector(characterAtIndex:)] && [imageWidth respondsToSelector:@selector(intValue)] && [imageHeight respondsToSelector:@selector(intValue)])
                {
                    [items addObject:[[TGBingSearchResultItem alloc] initWithImageUrl:imageUrl imageSize:CGSizeMake(imageWidth.intValue, imageHeight.intValue) previewUrl:previewUrl previewSize:CGSizeMake(previewWidth.intValue, previewHeight.intValue)]];
                }
            }
        }
    } @catch(__unused id exception) {
    }
    
    [ActionStageInstance() actionCompleted:self.path result:@{@"items": items, @"moreResultsAvailable": @(moreResultsAvailable)}];
}

- (void)httpRequestFailed:(NSString *)__unused url
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
