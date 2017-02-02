#import "TGOpenInBrowserItems.h"

#import "TGStringUtils.h"

@interface TGOpenInSafariItem : TGOpenInBrowserItem

@end

@interface TGOpenInChromeItem : TGOpenInBrowserItem

@end

@interface TGOpenInFirefoxItem : TGOpenInBrowserItem

@end

@interface TGOpenInOperaItem : TGOpenInBrowserItem

@end

@interface TGOpenInYandexItem : TGOpenInBrowserItem

@end


@interface TGOpenInBrowserItem ()

@end

@implementation TGOpenInBrowserItem

+ (NSArray *)appItemsClasses
{
    static dispatch_once_t onceToken;
    static NSArray *appItems;
    dispatch_once(&onceToken, ^
    {
        appItems = @
        [
            [TGOpenInSafariItem class],
            [TGOpenInChromeItem class],
            [TGOpenInFirefoxItem class],
            [TGOpenInOperaItem class],
            [TGOpenInYandexItem class]
        ];
    });
    return appItems;
}

+ (NSArray *)appItemsForURL:(NSURL *)url suppressSafariItem:(bool)suppressSafariItem
{
    NSArray *appItemsClasses = [self appItemsClasses];
    NSMutableArray *appItems = [[NSMutableArray alloc] init];
    for (id class in appItemsClasses)
    {
        if ([class canOpen:url] && [class isAvailable] && !(suppressSafariItem && class == [TGOpenInSafariItem class]))
        {
            TGOpenInBrowserItem *item = [[class alloc] initWithObject:url userInfo:nil];
            [appItems addObject:item];
        }

    }
    return appItems;
}

+ (bool)canOpen:(id)object
{
    return ([object isKindOfClass:[NSURL class]]);
}

@end


@implementation TGOpenInSafariItem

- (NSString *)title
{
    return @"Safari";
}

- (UIImage *)appIcon
{
    return [UIImage imageNamed:@"OpenInSafariIcon"];
}

- (void)performOpenIn
{
    NSURL *url = (NSURL *)self.object;
    [TGOpenInBrowserItem openURL:url];
}

+ (bool)isAvailable
{
    return true;
}

@end


@implementation TGOpenInChromeItem

- (NSString *)title
{
    return @"Chrome";
}

- (NSInteger)storeIdentifier
{
    return 535886823;
}

- (void)performOpenIn
{
    NSURL *url = (NSURL *)self.object;
    NSString *scheme = [url.scheme lowercaseString];
    
    bool secure = [scheme isEqualToString:@"https"];
    if (!secure && ![scheme isEqualToString:@"http"])
        return;
    
    NSURL *openInURL = nil;
    if (iosMajorVersion() >= 7)
    {
        NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:true];
        components.scheme = secure ? @"googlechromes" : @"googlechrome";
        openInURL = components.URL;
    }
    else
    {
        NSString *str = url.absoluteString;
        NSInteger colon = [str rangeOfString:@":"].location;
        if (colon != NSNotFound)
            str = [(secure ? @"googlechromes" : @"googlechrome") stringByAppendingString:[str substringFromIndex:colon]];
        openInURL = [NSURL URLWithString:str];
    }
    
    [TGOpenInBrowserItem openURL:openInURL];
}

+ (NSString *)defaultURLScheme
{
    return @"googlechrome";
}

@end


@implementation TGOpenInFirefoxItem

- (NSString *)title
{
    return @"Firefox";
}

- (NSInteger)storeIdentifier
{
    return 989804926;
}

- (void)performOpenIn
{
    NSURL *url = (NSURL *)self.object;
    NSString *scheme = [url.scheme lowercaseString];
    
    if (![scheme isEqualToString:@"http"] && ![scheme isEqualToString:@"https"])
        return;
    
    NSURL *openInURL = [NSURL URLWithString:[NSString stringWithFormat:@"firefox://open-url?url=%@", [TGStringUtils stringByEscapingForURL:url.absoluteString]]];
    [TGOpenInBrowserItem openURL:openInURL];
}

+ (NSString *)defaultURLScheme
{
    return @"firefox";
}

@end


@implementation TGOpenInOperaItem

- (NSString *)title
{
    return @"Opera Mini";
}

- (NSInteger)storeIdentifier
{
    return 363729560;
}

- (void)performOpenIn
{
    NSURL *url = (NSURL *)self.object;
    NSString *scheme = [url.scheme lowercaseString];
    
    bool secure = [scheme isEqualToString:@"https"];
    if (!secure && ![scheme isEqualToString:@"http"])
        return;
    
    NSURL *openInURL = nil;
    if (iosMajorVersion() >= 7)
    {
        NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:true];
        components.scheme = secure ? @"opera-https" : @"opera-http";
        openInURL = components.URL;
    }
    else
    {
        NSString *str = url.absoluteString;
        NSInteger colon = [str rangeOfString:@":"].location;
        if (colon != NSNotFound)
            str = [(secure ? @"opera-https" : @"opera-http") stringByAppendingString:[str substringFromIndex:colon]];
        openInURL = [NSURL URLWithString:str];
    }
    
    [TGOpenInBrowserItem openURL:openInURL];
}

+ (NSString *)defaultURLScheme
{
    return @"opera-http";
}

@end


@implementation TGOpenInYandexItem

- (NSString *)title
{
    return @"Yandex";
}

- (NSInteger)storeIdentifier
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        return 483693909;
    else
        return 574939428;
}

- (void)performOpenIn
{
    NSURL *url = (NSURL *)self.object;
    NSString *scheme = [url.scheme lowercaseString];
    
    if (![scheme isEqualToString:@"http"] && ![scheme isEqualToString:@"https"])
        return;
    
    NSURL *openInURL = [NSURL URLWithString:[NSString stringWithFormat:@"yandexbrowser-open-url://%@", [TGStringUtils stringByEscapingForURL:url.absoluteString]]];
    [TGOpenInBrowserItem openURL:openInURL];
}

+ (NSString *)defaultURLScheme
{
    return @"yandexbrowser-open-url";
}

@end
