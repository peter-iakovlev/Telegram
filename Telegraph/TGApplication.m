#import "TGApplication.h"

#import "TGAppDelegate.h"
#import "TGViewController.h"

#import "TGHacks.h"

#import "TGStringUtils.h"

#import <SafariServices/SafariServices.h>

@interface TGApplication ()
{
}

@end

@implementation TGApplication

- (id)init
{
    self = [super init];
    if (self != nil)
    {
    }
    return self;
}

- (NSString *)telegramMeLinkFromText:(NSString *)text startPrivatePayload:(__autoreleasing NSString **)startPrivatePayload startGroupPayload:(__autoreleasing NSString **)startGroupPayload
{
    NSString *pattern = @"https?:\\/\\/telegram\\.me\\/([a-zA-Z0-9_\\/]+)(\\?.*)?$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
    NSTextCheckingResult *match = [regex firstMatchInString:text options:0 range:NSMakeRange(0, [text length])];
    if (match != nil)
    {
        NSString *arguments = ([match numberOfRanges] >= 2 && [match rangeAtIndex:2].location != NSNotFound) ? [[text substringWithRange:[match rangeAtIndex:2]] substringFromIndex:1] : nil;
        if (arguments.length != 0)
        {
            NSDictionary *dict = [TGStringUtils argumentDictionaryInUrlString:arguments];
            if (dict.count == 1 && (dict[@"start"] != nil || dict[@"startgroup"]))
            {
                if (startPrivatePayload)
                    *startPrivatePayload = dict[@"start"];
                if (startGroupPayload)
                    *startGroupPayload = dict[@"startgroup"];
            }
            else
                return nil;
        }
        return [text substringWithRange:[match rangeAtIndex:1]];
    }
    return nil;
}

- (NSString *)shareLinkFromText:(NSString *)text {
    NSString *pattern = @"https?:\\/\\/telegram\\.me\\/share\\/url\\?(.*)$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
    NSTextCheckingResult *match = [regex firstMatchInString:text options:0 range:NSMakeRange(0, [text length])];
    if (match != nil) {
        NSString *arguments = ([match numberOfRanges] >= 1 && [match rangeAtIndex:1].location != NSNotFound) ? [text substringWithRange:[match rangeAtIndex:1]] : nil;
        if (arguments.length != 0)
        {
            return arguments;
        }
        return [text substringWithRange:[match rangeAtIndex:1]];
    }
    return nil;
}

- (BOOL)openURL:(NSURL *)url forceNative:(BOOL)__unused forceNative
{
    if (url.scheme.length == 0) {
        url = [NSURL URLWithString:[@"http://" stringByAppendingString:[url absoluteString]]];
    }
    
    NSString *rawAbsoluteString = url.absoluteString;
    NSString *absolutePrefixString = [url.absoluteString lowercaseString];
    if ([absolutePrefixString hasPrefix:@"tel:"] || [absolutePrefixString hasPrefix:@"facetime:"])
    {
        [TGAppDelegateInstance performPhoneCall:url];
        
        return true;
    }
    
    if ([absolutePrefixString hasPrefix:@"http://telegram.me/addstickers/"])
    {
        NSString *stickerPackHash = [rawAbsoluteString substringFromIndex:@"http://telegram.me/addstickers/".length];
        NSString *internalUrl = [[NSString alloc] initWithFormat:@"tg://addstickers?set=%@", stickerPackHash];
        [(TGAppDelegate *)self.delegate handleOpenDocument:[NSURL URLWithString:internalUrl] animated:true];
        return true;
    }
    
    if ([absolutePrefixString hasPrefix:@"https://telegram.me/addstickers/"])
    {
        NSString *stickerPackHash = [rawAbsoluteString substringFromIndex:@"https://telegram.me/addstickers/".length];
        NSString *internalUrl = [[NSString alloc] initWithFormat:@"tg://addstickers?set=%@", stickerPackHash];
        [(TGAppDelegate *)self.delegate handleOpenDocument:[NSURL URLWithString:internalUrl] animated:true];
        return true;
    }
    
    if ([absolutePrefixString hasPrefix:@"http://telegram.me/joinchat/"])
    {
        NSString *groupHash = [rawAbsoluteString substringFromIndex:@"http://telegram.me/joinchat/".length];
        NSString *internalUrl = [[NSString alloc] initWithFormat:@"tg://join?invite=%@", groupHash];
        [(TGAppDelegate *)self.delegate handleOpenDocument:[NSURL URLWithString:internalUrl] animated:true];
        return true;
    }
    
    if ([absolutePrefixString hasPrefix:@"https://telegram.me/joinchat/"])
    {
        NSString *groupHash = [rawAbsoluteString substringFromIndex:@"https://telegram.me/joinchat/".length];
        NSString *internalUrl = [[NSString alloc] initWithFormat:@"tg://join?invite=%@", groupHash];
        [(TGAppDelegate *)self.delegate handleOpenDocument:[NSURL URLWithString:internalUrl] animated:true];
        return true;
    }
    
    NSString *startPrivatePayload = nil;
    NSString *startGroupPayload = nil;
    NSString *telegramMeLink = [self telegramMeLinkFromText:rawAbsoluteString startPrivatePayload:&startPrivatePayload startGroupPayload:&startGroupPayload];
    if (telegramMeLink.length != 0)
    {
        NSString *domainName = telegramMeLink;
        NSString *postId = nil;
        NSRange slashRange = [telegramMeLink rangeOfString:@"/"];
        if (slashRange.location != NSNotFound) {
            domainName = [telegramMeLink substringToIndex:slashRange.location];
            postId = [telegramMeLink substringFromIndex:slashRange.location + 1];
        }
        NSMutableString *internalUrl = nil;
        if (postId.length == 0) {
            internalUrl = [[NSMutableString alloc] initWithFormat:@"tg://resolve?domain=%@", domainName];
        } else {
            internalUrl = [[NSMutableString alloc] initWithFormat:@"tg://resolve?domain=%@&post=%@", domainName, postId];
        }
        
        if (startPrivatePayload.length != 0 || startGroupPayload.length != 0)
        {
            if (startPrivatePayload.length != 0)
                [internalUrl appendFormat:@"&start=%@", startPrivatePayload];
            if (startGroupPayload.length != 0)
                [internalUrl appendFormat:@"&startgroup=%@", startGroupPayload];
        }
        [(TGAppDelegate *)self.delegate handleOpenDocument:[NSURL URLWithString:internalUrl] animated:true];
        return true;
    }
    
    NSString *shareLinkFromText = [self shareLinkFromText:rawAbsoluteString];
    if (shareLinkFromText.length != 0) {
        NSMutableString *internalUrl = [[NSMutableString alloc] initWithFormat:@"tg://msg_url?%@", shareLinkFromText];
        [(TGAppDelegate *)self.delegate handleOpenDocument:[NSURL URLWithString:internalUrl] animated:true];
        return true;
    }
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && iosMajorVersion() >= 9 && ([url.scheme isEqual:@"http"] || [url.scheme isEqual:@"https"])) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            dispatch_async(dispatch_get_main_queue(), ^{
                SFSafariViewController *controller = [[SFSafariViewController alloc] initWithURL:url entersReaderIfAvailable:false];
                [TGAppDelegateInstance.window.rootViewController presentViewController:controller animated:true completion:nil];
            });
        } else {
            SFSafariViewController *controller = [[SFSafariViewController alloc] initWithURL:url entersReaderIfAvailable:false];
            [TGAppDelegateInstance.window.rootViewController presentViewController:controller animated:true completion:nil];
        }
        return true;
    }
    
    return [super openURL:url];
}

- (BOOL)openURL:(NSURL *)url
{
    return [self openURL:url forceNative:false];
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle
{
    [self setStatusBarStyle:statusBarStyle animated:false];
}

- (void)setStatusBarStyle:(UIStatusBarStyle)__unused statusBarStyle animated:(BOOL)__unused animated
{
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden
{
    [self setStatusBarHidden:statusBarHidden withAnimation:UIStatusBarAnimationNone];
}

- (void)setStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation
{
    if (_processStatusBarHiddenRequests)
    {
        /*if (animation != UIStatusBarAnimationNone)
         {
         [TGHacks animateApplicationStatusBarAppearance:hidden ? TGStatusBarAppearanceAnimationSlideUp : TGStatusBarAppearanceAnimationSlideUp duration:0.3 completion:^
         {
         if (hidden)
         [TGHacks setApplicationStatusBarAlpha:0.0f];
         }];
         
         if (!hidden)
         [TGHacks setApplicationStatusBarAlpha:1.0f];
         }
         else
         {
         [TGHacks setApplicationStatusBarAlpha:hidden ? 0.0f : 1.0f];
         }*/
        
        [self forceSetStatusBarHidden:hidden withAnimation:animation];
    }
}

- (void)forceSetStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated
{
    [super setStatusBarStyle:statusBarStyle animated:animated];
}

- (void)forceSetStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation
{
    [super setStatusBarHidden:hidden withAnimation:animation];
}

@end
