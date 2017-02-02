#import "TGGiphySearchActor.h"

#import "ActionStage.h"

#import "TGTelegraph.h"
#import "TGStringUtils.h"

#import "TGGiphySearchResultItem.h"

#import "TGTelegramNetworking.h"

#import "TGExternalGifSearchResult.h"
#import "TGInternalGifSearchResult.h"
#import "TGDocumentMediaAttachment+Telegraph.h"
#import "TGWebPageMediaAttachment+Telegraph.h"

#import "TLWebPage$webPageExternal.h"
#import "TLWebPage_manual.h"

#import "TGImageMediaAttachment+Telegraph.h"

@interface TGGiphySearchActor () <TGRawHttpActor>
{
    NSArray *_currentItems;
    id<SDisposable> _disposable;
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
    TLRPCmessages_searchGifs$messages_searchGifs *searchGifs = [[TLRPCmessages_searchGifs$messages_searchGifs alloc] init];
    searchGifs.q = options[@"query"];
    searchGifs.offset = [options[@"moreResultsOffset"] intValue];
    
    NSString *path = self.path;
    _disposable = [[[[TGTelegramNetworking instance] requestSignal:searchGifs] map:^id(TLmessages_FoundGifs *result) {
        NSMutableArray *items = [[NSMutableArray alloc] initWithArray:options[@"currentItems"]];
        NSMutableSet *processedItems = [[NSMutableSet alloc] initWithArray:items];
        
        for (TLFoundGif *gif in result.results) {
            if ([gif isKindOfClass:[TLFoundGif$foundGifCached class]]) {
                TLFoundGif$foundGifCached *concreteGif = (TLFoundGif$foundGifCached *)gif;
                TGDocumentMediaAttachment *document = [[TGDocumentMediaAttachment alloc] initWithTelegraphDocumentDesc:concreteGif.document];
                TGImageMediaAttachment *image = [[TGImageMediaAttachment alloc] initWithTelegraphDesc:concreteGif.photo];
                if (document.documentId != 0) {
                    TGInternalGifSearchResult *item = [[TGInternalGifSearchResult alloc] initWithUrl:concreteGif.url document:document photo:image.imageId == 0 ? nil : image];
                    if (![processedItems containsObject:item]) {
                        [processedItems addObject:item];
                        [items addObject:item];
                    }
                }
            } else if ([gif isKindOfClass:[TLFoundGif$foundGif class]]) {
                TLFoundGif$foundGif *concreteGif = (TLFoundGif$foundGif *)gif;
                TGExternalGifSearchResult *item = [[TGExternalGifSearchResult alloc] initWithUrl:concreteGif.url originalUrl:concreteGif.content_url thumbnailUrl:concreteGif.thumb_url size:CGSizeMake(concreteGif.w, concreteGif.h)];
                if (![processedItems containsObject:item]) {
                    [processedItems addObject:item];
                    [items addObject:item];
                }
            }
        }
        
        return @{@"items": items, @"nextOffset": @(result.next_offset)};;
    }] startWithNext:^(NSDictionary *dict) {
        [ActionStageInstance() actionCompleted:path result:@{@"items": dict[@"items"], @"moreResultsAvailable": @([dict[@"nextOffset"] intValue] != 0), @"moreResultsOffset": dict[@"nextOffset"]}];
    } error:^(__unused id error) {
        [ActionStageInstance() actionFailed:self.path reason:-1];
    } completed:nil];
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

- (void)cancel {
    [_disposable dispose];
}

@end
