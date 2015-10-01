#import "TGYoutubeContentPropertiesActor.h"

#import "TGTelegraph.h"
#import "TGDatabase.h"
#import "TGYoutubeDataContentProperty.h"

@interface TGYoutubeContentPropertiesActor () <TGRawHttpActor>
{
    NSMutableArray *_messageIds;
}

@end

@implementation TGYoutubeContentPropertiesActor

+ (void)load
{
    [ASActor registerActorClass:self];
}

+ (NSString *)genericPath
{
    return @"/youtube/contentProperties/@";
}

- (void)execute:(NSDictionary *)options
{
    _messageIds = [[NSMutableArray alloc] init];
    
    [_messageIds addObject:options[@"messageId"]];
    
    self.cancelToken = [TGTelegraphInstance doRequestRawHttp:[[NSString alloc] initWithFormat:@"http://gdata.youtube.com/feeds/api/videos/%@?v=2&alt=json", options[@"videoId"]] maxRetryCount:-1 acceptCodes:@[@200] actor:self];
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
    NSString *title = nil;
    NSUInteger duration = 0;
    
    @try {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
        if ([dict respondsToSelector:@selector(objectForKey:)])
        {
            NSString *dictTitle = [self objectAtDictionaryPath:@"entry.title.$t" dictionary:dict];
            if ([dictTitle respondsToSelector:@selector(characterAtIndex:)])
                title = dictTitle;
            NSNumber *dictDuration = [self objectAtDictionaryPath:@"entry.media$group.yt$duration.seconds" dictionary:dict];
            if ([dictDuration respondsToSelector:@selector(intValue)])
                duration = (NSUInteger)[dictDuration intValue];
        }
    } @catch(__unused id exception) {
    }
    
    TGYoutubeDataContentProperty *property = [[TGYoutubeDataContentProperty alloc] initWithTitle:title duration:duration];

    NSArray *messageIds = _messageIds;
    
    [ActionStageInstance() actionCompleted:self.path result:@{@"youtube": property}];
    
    [TGDatabaseInstance() dispatchOnDatabaseThread:^
    {
        for (NSNumber *nMessageId in messageIds)
        {
            TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:[nMessageId intValue] peerId:0];
            if (message != nil)
            {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:message.contentProperties];
                dict[@"youtube"] = property;
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
