#import "TGRecentHashtagsSignal.h"

#import "PSKeyValueEncoder.h"

@implementation TGRecentHashtagsSignal

+ (NSString *)recentHashtagsKeyForSpace:(TGHashtagSpace)space
{
    switch (space)
    {
        case TGHashtagSpaceEntered:
            return @"autocompletion.recentHashtags.entered";
        case TGHashtagSpaceSearchedBy:
            return @"autocompletion.recentHashtags.searchedBy";
    }
}

+ (SSignal *)recentHashtagsFromSpaces:(int)spaces
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        NSMutableArray *resultHashtags = [[NSMutableArray alloc] init];
        
        if (spaces & TGHashtagSpaceEntered)
        {
            NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:[self recentHashtagsKeyForSpace:TGHashtagSpaceEntered]];
            if (data != nil)
            {
                NSArray *hashtags = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                [resultHashtags addObjectsFromArray:hashtags];
            }
        }
        
        if (spaces & TGHashtagSpaceSearchedBy)
        {
            NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:[self recentHashtagsKeyForSpace:TGHashtagSpaceSearchedBy]];
            if (data != nil)
            {
                NSArray *hashtags = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                NSMutableArray *unionArray = [[NSMutableArray alloc] initWithArray:hashtags];
                [unionArray removeObjectsInArray:resultHashtags];
                [resultHashtags addObjectsFromArray:unionArray];
            }
        }
        
        [subscriber putNext:resultHashtags];
        [subscriber putCompletion];
        
        return nil;
    }];
}

+ (void)addRecentHashtagsFromText:(NSString *)text space:(TGHashtagSpace)space
{
    bool containsSomething = false;
    
    int length = (int)text.length;
    
    SEL sel = @selector(characterAtIndex:);
    unichar (*characterAtIndexImp)(id, SEL, NSUInteger) = (typeof(characterAtIndexImp))[text methodForSelector:sel];
    
    for (int i = 0; i < length; i++)
    {
        unichar c = characterAtIndexImp(text, sel, i);
        
        if (c == '#')
        {
            containsSomething = true;
            break;
        }
    }
    
    if (containsSomething)
    {
        NSMutableArray *hashtags = [[NSMutableArray alloc] init];
        
        int hashtagStart = -1;
        
        for (int i = 0; i < length; i++)
        {
            unichar c = characterAtIndexImp(text, sel, i);
            if (hashtagStart != -1)
            {
                static NSCharacterSet *characterSet = nil;
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^
                {
                    characterSet = [NSCharacterSet alphanumericCharacterSet];
                });
                
                if (c == ' ' || (![characterSet characterIsMember:c] && c != '_'))
                {
                    if (i > hashtagStart + 1)
                    {
                        NSRange range = NSMakeRange(hashtagStart + 1, i - hashtagStart - 1);
                        NSString *hashtag = [text substringWithRange:range];
                        if (![hashtags containsObject:hashtag])
                            [hashtags addObject:hashtag];
                    }
                    hashtagStart = -1;
                }
            }
            
            if (c == '#')
            {
                hashtagStart = i;
            }
        }
        
        if (hashtagStart != -1 && hashtagStart + 1 < length - 1)
        {
            NSRange range = NSMakeRange(hashtagStart + 1, length - hashtagStart - 1);
            NSString *hashtag = [text substringWithRange:range];
            if (![hashtags containsObject:hashtag])
                [hashtags addObject:hashtag];
        }
        
        if (hashtags.count != 0)
        {
            NSMutableArray *previousHashtags = [[NSMutableArray alloc] init];
            NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:[self recentHashtagsKeyForSpace:space]];
            if (data != nil)
                [previousHashtags addObjectsFromArray:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
            
            [previousHashtags removeObjectsInArray:hashtags];
            
            NSArray *resultingHashtags = [hashtags arrayByAddingObjectsFromArray:previousHashtags];
            NSData *resultingData = [NSKeyedArchiver archivedDataWithRootObject:resultingHashtags];
            [[NSUserDefaults standardUserDefaults] setObject:resultingData forKey:[self recentHashtagsKeyForSpace:space]];
        }
    }
}

+ (void)clearRecentHashtags
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self recentHashtagsKeyForSpace:TGHashtagSpaceEntered]];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self recentHashtagsKeyForSpace:TGHashtagSpaceSearchedBy]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
