#import "TGInstagramContentPropertiesActor.h"

#import "TGTelegraph.h"
#import "TGDatabase.h"
#import "TGInstagramDataContentProperty.h"

@interface TGInstagramContentPropertiesActor () <TGRawHttpActor>
{
    NSMutableArray *_messageIds;
}

@end

@implementation TGInstagramContentPropertiesActor

+ (void)load
{
    [ASActor registerActorClass:self];
}

+ (NSString *)genericPath
{
    return @"/instagram/contentProperties/@";
}

- (void)execute:(NSDictionary *)options
{
    _messageIds = [[NSMutableArray alloc] init];
    
    [_messageIds addObject:options[@"messageId"]];
    
    self.cancelToken = [TGTelegraphInstance doRequestRawHttp:[[NSString alloc] initWithFormat:@"http://api.instagram.com/oembed?url=http://instagram.com/p/%@/&maxwidth=400", options[@"shortcode"]] maxRetryCount:-1 acceptCodes:@[@200] actor:self];
}

- (void)watcherJoined:(ASHandle *)watcherHandle options:(NSDictionary *)options waitingInActorQueue:(bool)waitingInActorQueue
{
    [super watcherJoined:watcherHandle options:options waitingInActorQueue:waitingInActorQueue];
    
    [_messageIds addObject:options[@"messageId"]];
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
    NSString *imageUrl = nil;
    NSString *mediaId = nil;
    
    @try {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
        if ([dict respondsToSelector:@selector(objectForKey:)])
        {
            NSString *dictImageUrl = [self objectAtDictionaryPath:@"url" dictionary:dict];
            if ([dictImageUrl respondsToSelector:@selector(characterAtIndex:)])
                imageUrl = dictImageUrl;
            if (imageUrl == nil)
            {
                dictImageUrl = [self objectAtDictionaryPath:@"thumbnail_url" dictionary:dict];
                if ([dictImageUrl respondsToSelector:@selector(characterAtIndex:)])
                    imageUrl = dictImageUrl;
            }
            
            NSString *dictMediaId = [self objectAtDictionaryPath:@"media_id" dictionary:dict];
            if ([dictMediaId respondsToSelector:@selector(characterAtIndex:)])
                mediaId = dictMediaId;
        }
    } @catch(__unused id exception) {
    }
    
    TGInstagramDataContentProperty *property = [[TGInstagramDataContentProperty alloc] initWithImageUrl:imageUrl mediaId:mediaId];
    
    NSArray *messageIds = _messageIds;
    
    [ActionStageInstance() actionCompleted:self.path result:@{@"instagram": property}];
    
    [TGDatabaseInstance() dispatchOnDatabaseThread:^
    {
        for (NSNumber *nMessageId in messageIds)
        {
            TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:[nMessageId intValue] peerId:0];
            if (message != nil)
            {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:message.contentProperties];
                dict[@"instagram"] = property;
                [TGDatabaseInstance() replaceContentPropertiesInMessageWithId:[nMessageId intValue] contentProperties:dict];
            }
        }
    } synchronous:false];
}

- (void)httpRequestFailed:(NSString *)__unused url
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
