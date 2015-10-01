#import "TGGiphySearchActor.h"

#import "ActionStage.h"

#import "TGTelegraph.h"
#import "TGStringUtils.h"

#import "TGGiphySearchResultItem.h"

@interface TGGiphySearchActor () <TGRawHttpActor>
{
    NSArray *_currentItems;
}

@end

@implementation TGGiphySearchActor

+ (void)load
{
    [ASActor registerActorClass:self];
}

+ (NSString *)genericPath
{
    return @"/search/giphy/@";
}

- (void)execute:(NSDictionary *)options
{
    _currentItems = options[@"currentItems"];
    NSString *url = [[NSString alloc] initWithFormat:@"https://api.giphy.com/v1/gifs/search?q=%@&offset=%d&limit=60&api_key=141Wa2KDAfNfxu", [TGStringUtils stringByEscapingForURL:options[@"query"]], (int)_currentItems.count];
    self.cancelToken = [TGTelegraphInstance doRequestRawHttp:url maxRetryCount:0 acceptCodes:@[@200] actor:self];
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

- (void)httpRequestSuccess:(NSString *)__unused url response:(NSData *)response
{
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:_currentItems];
    bool moreResultsAvailable = false;
    
    @try {
        NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
        NSArray *list = [self objectAtDictionaryPath:@"data" dictionary:rootDict];
        if ([list respondsToSelector:@selector(objectAtIndex:)])
        {
            for (NSDictionary *dict in list)
            {
                NSString *gifId = [self objectAtDictionaryPath:@"id" dictionary:dict];
                
                NSString *previewUrl = [self objectAtDictionaryPath:@"images.fixed_width_still.url" dictionary:dict];
                NSNumber *previewWidth = [self objectAtDictionaryPath:@"images.fixed_width_still.width" dictionary:dict];
                NSNumber *previewHeight = [self objectAtDictionaryPath:@"images.fixed_width_still.height" dictionary:dict];
                
                NSString *gifUrl = [self objectAtDictionaryPath:@"images.original.url" dictionary:dict];
                NSNumber *gifWidth = [self objectAtDictionaryPath:@"images.original.width" dictionary:dict];
                NSNumber *gifHeight = [self objectAtDictionaryPath:@"images.original.height" dictionary:dict];
                NSNumber *gifSize = [self objectAtDictionaryPath:@"images.original.size" dictionary:dict];
                
                if ([gifId respondsToSelector:@selector(characterAtIndex:)] && [previewUrl respondsToSelector:@selector(characterAtIndex:)] && [previewWidth respondsToSelector:@selector(intValue)] && [previewHeight respondsToSelector:@selector(intValue)] && [gifUrl respondsToSelector:@selector(characterAtIndex:)] && [gifWidth respondsToSelector:@selector(intValue)] && [gifHeight respondsToSelector:@selector(intValue)] && [gifSize respondsToSelector:@selector(intValue)])
                {
                    [items addObject:[[TGGiphySearchResultItem alloc] initWithGifId:gifId gifUrl:gifUrl gifSize:CGSizeMake(gifWidth.intValue, gifHeight.intValue) gifFileSize:(NSUInteger)[gifSize intValue] previewUrl:previewUrl previewSize:CGSizeMake(previewWidth.intValue, previewHeight.intValue)]];
                }
            }
        }
        
        if (items.count != 0)
        {
            NSNumber *totalCount = [self objectAtDictionaryPath:@"pagination.total_count" dictionary:rootDict];
            if ([totalCount respondsToSelector:@selector(intValue)])
                moreResultsAvailable = totalCount.intValue > (int)items.count;
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
