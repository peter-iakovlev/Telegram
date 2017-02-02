/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGDownloadLocalizationActor.h"

#import "ActionStage.h"

#import "TGProgressWindow.h"
#import "TGTelegraph.h"

#import "TGAppDelegate.h"

#import "TGAlertView.h"

@interface TGDownloadLocalizationActor () <TGRawHttpActor>
{
    TGProgressWindow *_progressWindow;
}

@end

@implementation TGDownloadLocalizationActor

+ (void)load
{
    [ASActor registerActorClass:self];
}

+ (NSString *)genericPath
{
    return @"/tg/downloadLocalization/@";
}

- (void)dealloc
{
    TGProgressWindow *progressWindow = _progressWindow;
    _progressWindow = nil;
    
    TGDispatchOnMainThread(^
    {
        [progressWindow dismiss:true];
    });
}

- (void)execute:(NSDictionary *)options
{
    if (options[@"url"] != nil)
    {
        NSString *url = options[@"url"];
        if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"])
        {
            TGDispatchOnMainThread(^
            {
                _progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                [_progressWindow show:false];
            });
            
            self.cancelToken = [TGTelegraphInstance doRequestRawHttp:url maxRetryCount:1 acceptCodes:@[@(200)] actor:self];
        }
    }
    else
        [ActionStageInstance() actionFailed:self.path reason:-1];
}

- (void)httpRequestSuccess:(NSString *)__unused url response:(NSData *)response
{
    int64_t randomId = 0;
    arc4random_buf(&randomId, 8);
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%" PRId64 ".strings", randomId]];
    [response writeToFile:filePath atomically:true];
    
    TGProgressWindow *progressWindow = _progressWindow;
    _progressWindow = nil;
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
    
    TGDispatchOnMainThread(^
    {
        [progressWindow dismiss:true];
        
        NSBundle *referenceBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"]];
        NSDictionary *referenceDict = [NSDictionary dictionaryWithContentsOfFile:[referenceBundle pathForResource:@"Localizable" ofType:@"strings"]];
        
        NSDictionary *localizationDict = [NSDictionary dictionaryWithContentsOfFile:filePath];
        
        __block bool valid = true;
        NSMutableArray *missingKeys = [[NSMutableArray alloc] init];
        NSMutableArray *invalidFormatKeys = [[NSMutableArray alloc] init];
        NSString *invalidFileString = nil;
        
        if (localizationDict != nil && referenceDict != nil)
        {
            [referenceDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *sourceValue, __unused BOOL *stop)
             {
                 NSString *targetValue = localizationDict[key];
                 if (targetValue == nil)
                 {
                     [missingKeys addObject:key];
                 }
                 else
                 {
                     for (int i = 0; i < 2; i++)
                     {
                         NSString *firstValue = i == 0 ? sourceValue : targetValue;
                         NSString *secondValue = i == 0 ? targetValue : sourceValue;
                         
                         NSRange firstRange = NSMakeRange(0, firstValue.length);
                         NSRange secondRange = NSMakeRange(0, secondValue.length);
                         
                         while (firstRange.length != 0)
                         {
                             NSRange range = [firstValue rangeOfString:@"%" options:0 range:firstRange];
                             if (range.location == NSNotFound || range.location == firstValue.length - 1)
                                 break;
                             else
                             {
                                 firstRange.location = range.location + range.length;
                                 firstRange.length = firstValue.length - firstRange.location;
                                 
                                 NSString *findPositionalString = nil;
                                 NSString *findFreeString = nil;
                                 
                                 unichar c = [firstValue characterAtIndex:range.location + 1];
                                 if (c == 'd' || c == 'f')
                                     findPositionalString = [[NSString alloc] initWithFormat:@"%%%c", (char)c];
                                 else if (c >= '0' && c <= '9')
                                 {
                                     if (range.location + 3 < firstValue.length)
                                     {
                                         if ([firstValue characterAtIndex:range.location + 2] == '$')
                                         {
                                             unichar formatChar = [firstValue characterAtIndex:range.location + 3];
                                             
                                             findFreeString = [[NSString alloc] initWithFormat:@"%%%c$%c", (char)c, (char)formatChar];
                                         }
                                     }
                                 }
                                 
                                 if (findPositionalString != nil)
                                 {
                                     NSRange foundRange = [secondValue rangeOfString:findPositionalString options:0 range:secondRange];
                                     if (foundRange.location != NSNotFound)
                                     {
                                         secondRange.location = foundRange.location + foundRange.length;
                                         secondRange.length = secondValue.length - secondRange.location;
                                     }
                                     else
                                     {
                                         valid = false;
                                         [invalidFormatKeys addObject:key];
                                         
                                         break;
                                     }
                                 }
                                 else if (findFreeString != nil)
                                 {
                                     if ([secondValue rangeOfString:findFreeString].location == NSNotFound)
                                     {
                                         valid = false;
                                         [invalidFormatKeys addObject:key];
                                         
                                         break;
                                     }
                                 }
                             }
                         }
                     }
                 }
             }];
        }
        else
        {
            valid = false;
            
            invalidFileString = @"invalid localization file format";
        }
        
        if (valid)
        {
            NSMutableString *missingKeysString = [[NSMutableString alloc] init];
            static const int maxKeys = 5;
            for (int i = 0; i < maxKeys && i < (int)missingKeys.count; i++)
            {
                if (missingKeysString.length != 0)
                    [missingKeysString appendString:@", "];
                [missingKeysString appendString:missingKeys[i]];
                
                if (i == maxKeys - 1 && maxKeys < (int)missingKeys.count)
                    [missingKeysString appendFormat:@" and %d more", (int)(missingKeys.count - maxKeys)];
            }
            
            NSString *warnings = nil;
            if (missingKeysString.length != 0)
            {
                warnings = [[NSString alloc] initWithFormat:@"Localization file is valid, but the following keys are missing: %@", missingKeysString];
            }
            
            [TGAppDelegateInstance readyToApplyLocalizationFromFile:filePath warnings:warnings];
        }
        else
        {
            NSString *reasonString = nil;
            
            if (invalidFileString.length != 0)
                reasonString = invalidFileString;
            else if (invalidFormatKeys.count != 0)
            {
                NSMutableString *invalidFormatKeysString = [[NSMutableString alloc] init];
                static const int maxKeys = 5;
                for (int i = 0; i < maxKeys && i < (int)invalidFormatKeys.count; i++)
                {
                    if (invalidFormatKeysString.length != 0)
                        [invalidFormatKeysString appendString:@", "];
                    [invalidFormatKeysString appendString:invalidFormatKeys[i]];
                    
                    if (i == maxKeys - 1 && maxKeys < (int)invalidFormatKeys.count)
                        [invalidFormatKeysString appendFormat:@" and %d more", (int)(invalidFormatKeys.count - maxKeys)];
                }
                reasonString = [[NSString alloc] initWithFormat:@"invalid value format for keys %@", invalidFormatKeysString];
            }
            
            TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:[[NSString alloc] initWithFormat:@"Invalid localization file: %@", reasonString] delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil];
            [alertView show];
        }
    });
}

- (void)httpRequestFailed:(NSString *)__unused url
{
    TGProgressWindow *progressWindow = _progressWindow;
    _progressWindow = nil;
    
    TGDispatchOnMainThread(^
    {
        [progressWindow dismiss:true];
        
        [[[UIAlertView alloc] initWithTitle:nil message:TGLocalized(@"Service.LocalizationDownloadError") delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil] show];
    });
    
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
