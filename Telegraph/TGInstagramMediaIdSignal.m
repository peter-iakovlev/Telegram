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

+ (NSString *)instagramShortcodeFromText:(NSString *)text
{
    NSArray *prefixList = @
    [
        @"http://instagram.com/p/",
        @"https://instagram.com/p/",
        @"http://www.instagram.com/p/",
        @"https://www.instagram.com/p/",
        @"instagram.com/p/",
        @"www.instagram.com/p/",
    ];
    
    NSString *instagramPrefix = nil;
    for (NSString *prefix in prefixList)
    {
        if ([text hasPrefix:prefix])
        {
            instagramPrefix = prefix;
            break;
        }
    }
    
    if (instagramPrefix.length != 0)
    {
        NSString *prefix = instagramPrefix;
        int length = (int)text.length;
        bool badCharacters = false;
        int slashCount = 0;
        for (int i = (int)prefix.length; i < length; i++)
        {
            unichar c = [text characterAtIndex:i];
            if ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_' || c == '/' || c == '-')
            {
                if (c == '/')
                {
                    if (slashCount >= 2)
                    {
                        badCharacters = true;
                        break;
                    }
                    slashCount++;
                }
            }
            else
            {
                badCharacters = true;
                break;
            }
        }
        
        if (!badCharacters)
        {
            NSString *shortcode = [text substringFromIndex:prefix.length];
            if ([shortcode hasSuffix:@"/"])
                shortcode = [shortcode substringToIndex:shortcode.length - 1];
            
            return shortcode;
        }
    }
    
    return nil;
}

@end
