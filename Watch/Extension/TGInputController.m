#import "TGInputController.h"
#import "TGBridgeCommon.h"
#import "TGInterfaceController.h"

#import "TGFileCache.h"
#import "TGExtensionDelegate.h"

@implementation TGInputController

+ (void)presentPlainInputControllerForInterfaceController:(TGInterfaceController *)interfaceController completion:(void (^)(NSString *))completion;
{
    [interfaceController presentTextInputControllerWithSuggestions:nil allowedInputMode:WKTextInputModePlain completion:^(NSArray *results)
    {
        if (completion != nil && results.count > 0 && [results.firstObject isKindOfClass:[NSString class]])
            completion(results.firstObject);
    }];
}

+ (void)presentInputControllerForInterfaceController:(TGInterfaceController *)interfaceController suggestionsForText:(NSString *)text completion:(void (^)(NSString *))completion
{
    [interfaceController presentTextInputControllerWithSuggestions:[self suggestionsForText:text] allowedInputMode:WKTextInputModeAllowEmoji completion:^(NSArray *results)
    {
        if (completion != nil && results.count > 0 && [results.firstObject isKindOfClass:[NSString class]])
            completion(results.firstObject);
    }];
}

+ (void)presentAudioControllerForInterfaceController:(TGInterfaceController *)interfaceController completion:(void (^)(int64_t, int32_t, NSURL *))completion
{
    NSDictionary *options = @
    {
        WKAudioRecorderControllerOptionsActionTitleKey: TGLocalized(@"Compose.Send"),
    };
    
    int64_t randomId = 0;
    arc4random_buf(&randomId, sizeof(int64_t));
    
    NSURL *url = [[TGExtensionDelegate instance].audioCache urlForKey:[NSString stringWithFormat:@"%lld", randomId]];
    [interfaceController presentAudioRecorderControllerWithOutputURL:url preset:WKAudioRecorderPresetWideBandSpeech options:options completion:^(BOOL didSave, NSError * _Nullable error)
    {
        WKAudioFileAsset *asset = [WKAudioFileAsset assetWithURL:url];
        
        if (didSave && !error)
            completion(randomId, (int32_t)asset.duration, url);
    }];
}

+ (NSArray *)suggestionsForText:(NSString *)text
{
    return [self customSuggestions];
}

+ (NSArray *)customSuggestions
{
    NSString *groupName = [TGBridgeCommon groupName];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:groupName];
    
    NSMutableArray *finalSuggestions = [[NSMutableArray alloc] initWithArray:[self generalSuggestions]];
    [finalSuggestions addObjectsFromArray:[self laterSuggestions]];
    
    for (NSInteger i = 0; i < 8; i++)
    {
        NSString *key = [NSString stringWithFormat:@"preset_%d", i + 1];
        NSString *preset = [defaults stringForKey:key];
        if (preset.length > 0)
            [finalSuggestions replaceObjectAtIndex:i withObject:preset];
    }
    
    return finalSuggestions;
}

+ (NSArray *)composeSuggestions
{
    static NSArray *suggestions;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        suggestions = @[ TGLocalized(@"Suggestion.WhatsUp"),
                         TGLocalized(@"Suggestion.OnMyWay"),
                         TGLocalized(@"Suggestion.OK"),
                         TGLocalized(@"Suggestion.CantTalk"),
                         TGLocalized(@"Suggestion.CallSoon"),
                         TGLocalized(@"Suggestion.Thanks") ];
    });
    return suggestions;
}

+ (NSArray *)generalSuggestions
{
    static NSArray *suggestions;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        suggestions = @[ TGLocalized(@"Suggestion.OK"),
                         TGLocalized(@"Suggestion.Thanks"),
                         TGLocalized(@"Suggestion.WhatsUp") ];
    });
    return suggestions;
}

+ (NSArray *)yesNoSuggestions
{
    static NSArray *suggestions;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        suggestions = @[ TGLocalized(@"Suggestion.Yes"),
                         TGLocalized(@"Suggestion.No"),
                         TGLocalized(@"Suggestion.Absolutely"),
                         TGLocalized(@"Suggestion.Nope") ];
    });
    return suggestions;
}

+ (NSArray *)laterSuggestions
{
    static NSArray *suggestions;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        suggestions = @[ TGLocalized(@"Suggestion.TalkLater"),
                         TGLocalized(@"Suggestion.CantTalk"),
                         TGLocalized(@"Suggestion.HoldOn"),
                         TGLocalized(@"Suggestion.BRB"),
                         TGLocalized(@"Suggestion.OnMyWay") ];
    });
    return suggestions;
}

@end
