#import "TGInstagramMediaIdSignal.h"

#import "TGRemoteHttpLocationSignal.h"

@implementation TGInstagramMediaIdSignal

+ (id)objectAtDictionaryPath:(NSString *)path dictionary:(NSDictionary *)dictionary
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

+ (SSignal *)instagramMediaIdForShortcode:(NSString *)shortcode
{
    NSString *url = [[NSString alloc] initWithFormat:@"http://api.instagram.com/oembed?url=http://instagram.com/p/%@", shortcode];
    return [[TGRemoteHttpLocationSignal dataForHttpLocation:url] mapToSignal:^SSignal *(NSData *response)
    {
        NSString *mediaId = nil;
        @try {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
            if ([dict respondsToSelector:@selector(objectForKey:)])
            {
                NSString *dictMediaId = [self objectAtDictionaryPath:@"media_id" dictionary:dict];
                if ([dictMediaId respondsToSelector:@selector(characterAtIndex:)])
                    mediaId = dictMediaId;
            }
        } @catch(__unused id exception) {
        }
        
        if (mediaId == nil)
            return [SSignal fail:nil];
        else
            return [SSignal single:mediaId];
    }];
}

@end
