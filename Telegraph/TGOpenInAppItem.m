#import "TGOpenInAppItem.h"
#import "TGOpenInBrowserItems.h"
#import "TGOpenInLocationItems.h"
#import "TGOpenInSocialItems.h"
#import "TGOpenInVideoItems.h"

#import "TGApplication.h"
#import "TGWebPageMediaAttachment.h"

NSString *const TGOpenInEmbedURLKey = @"embedURL";

@implementation TGOpenInAppItem

- (instancetype)initWithObject:(id)object userInfo:(NSDictionary *)userInfo
{
    self = [super init];
    if (self != nil)
    {
        _object = object;
        _userInfo = userInfo;
    }
    return self;
}

- (void)performOpenIn
{
    
}

+ (NSArray *)appItemsForURL:(NSURL *)url
{
    return [self appItemsForURL:url userInfo:[NSDictionary dictionary]];
}

+ (NSArray *)appItemsForURL:(NSURL *)url userInfo:(NSDictionary *)userInfo
{
    bool suppressSafariItem = false;
    NSArray *videoItems = [TGOpenInVideoItem appItemsForURL:url userInfo:userInfo];
    
    for (TGOpenInAppItem *item in videoItems)
    {
        if (item.suppressSafariItem)
        {
            suppressSafariItem = true;
            break;
        }
    }
    
    NSArray *browserItems = [TGOpenInBrowserItem appItemsForURL:url suppressSafariItem:suppressSafariItem];
    
    NSArray *combinedItems = [videoItems arrayByAddingObjectsFromArray:browserItems];
    return combinedItems;
}

+ (NSArray *)appItemsForWebPageAttachment:(TGWebPageMediaAttachment *)webPage
{
    NSDictionary *userInfo = [[NSDictionary alloc] init];
    if (webPage.embedUrl != nil)
        userInfo = @{ TGOpenInEmbedURLKey: webPage.embedUrl };
    
    return [self appItemsForURL:[NSURL URLWithString:[webPage url]] userInfo:userInfo];
}

+ (NSArray *)appItemsForLocationAttachment:(TGLocationMediaAttachment *)location directions:(bool)directions
{
    return [TGOpenInLocationItem appItemsForLocationAttachment:location directions:directions];
}

+ (bool)canOpen:(id)__unused object
{
    return false;
}

+ (NSString *)defaultURLScheme
{
    return @"";
}

+ (bool)isAvailable
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://", self.defaultURLScheme]]];
}

+ (void)openURL:(NSURL *)url
{
    [(TGApplication *)[TGApplication sharedApplication] nativeOpenURL:url];
}

@end
