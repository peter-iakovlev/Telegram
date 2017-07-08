#import "TGLocalizationSignals.h"

#import "TL/TLMetaScheme.h"
#import "TGTelegramNetworking.h"

#import <MTProtoKit/MTProtoKit.h>

#import "TGLocalization.h"

#import "TGAppDelegate.h"

#import "TGDatabase.h"

#import "TGAccountSignals.h"

@implementation TGAvailableLocalization

- (instancetype)initWithTitle:(NSString *)title localizedTitle:(NSString *)localizedTitle code:(NSString *)code {
    self = [super init];
    if (self != nil) {
        _title = title;
        _localizedTitle = localizedTitle;
        _code = code;
    }
    return self;
}

@end

@implementation TGSuggestedLocalization

- (instancetype)initWithInfo:(TGAvailableLocalization *)info continueWithLanguageString:(NSString *)continueWithLanguageString chooseLanguageString:(NSString *)chooseLanguageString chooseLanguageOtherString:(NSString *)chooseLanguageOtherString englishLanguageNameString:(NSString *)englishLanguageNameString {
    self = [super init];
    if (self != nil) {
        _info = info;
        _continueWithLanguageString = continueWithLanguageString;
        _chooseLanguageString = chooseLanguageString;
        _chooseLanguageOtherString = chooseLanguageOtherString;
        _englishLanguageNameString = englishLanguageNameString;
    }
    return self;
}

@end

@implementation TGLocalizationSignals

+ (SSignal *)suggestedLocalization {
    return [[[TGTelegramNetworking instance] requestSignal:[[TLRPChelp_getConfig$help_getConfig alloc] init]] mapToSignal:^SSignal *(TLConfig *result) {
        if (result.suggested_lang_code.length != 0 && ![result.suggested_lang_code isEqual:currentNativeLocalization().code]) {
            return [self suggestedLocalizationData:result.suggested_lang_code];
        } else {
            return [SSignal single:nil];
        }
    }];
}

+ (SSignal *)suggestedLocalizationData:(NSString *)code {
    TLRPClangpack_getStrings$langpack_getStrings *getStrings = [[TLRPClangpack_getStrings$langpack_getStrings alloc] init];
    getStrings.lang_code = code;
    getStrings.keys = @[@"Login.ContinueWithLocalization", @"Localization.ChooseLanguage", @"Localization.LanguageOther", @"Localization.EnglishLanguageName"];
    return [[SSignal combineSignals:@[[self availableLocalizations], [[TGTelegramNetworking instance] requestSignal:getStrings]]] map:^id(NSArray *values) {
        for (TGAvailableLocalization *info in values[0]) {
            if ([info.code isEqual:code]) {
                NSString *continueWithString = @"Contiune";
                NSString *chooseLanguageString = @"Choose Language";
                NSString *chooseLanguageOtherString = @"Other";
                NSString *englishLanguageNameString = @"English";
                for (TLLangPackString *string in values[1]) {
                    if ([string isKindOfClass:[TLLangPackString$langPackString class]]) {
                        NSString *value = ((TLLangPackString$langPackString *)string).value;
                        if ([string.key isEqualToString:@"Login.ContinueWithLocalization"]) {
                            continueWithString = value;
                        } else if ([string.key isEqualToString:@"Localization.ChooseLanguage"]) {
                            chooseLanguageString = value;
                        } else if ([string.key isEqualToString:@"Localization.LanguageOther"]) {
                            chooseLanguageOtherString = value;
                        } else if ([string.key isEqualToString:@"Localization.EnglishLanguageName"]) {
                            englishLanguageNameString = value;
                        }
                    }
                }
                
                return [[TGSuggestedLocalization alloc] initWithInfo:info continueWithLanguageString:continueWithString chooseLanguageString:chooseLanguageString chooseLanguageOtherString:chooseLanguageOtherString englishLanguageNameString:englishLanguageNameString];
            }
        }
        return nil;
    }];
}

+ (SSignal *)availableLocalizations {
    TLRPClangpack_getLanguages$langpack_getLanguages *getLanguages = [[TLRPClangpack_getLanguages$langpack_getLanguages alloc] init];
    return [[[TGTelegramNetworking instance] requestSignal:getLanguages] map:^id(NSArray *list) {
        NSMutableArray *result = [[NSMutableArray alloc] init];
        for (TLLangPackLanguage *desc in list) {
            NSString *code = desc.lang_code;
            [result addObject:[[TGAvailableLocalization alloc] initWithTitle:desc.name localizedTitle:desc.native_name code:code]];
        }
        return result;
    }];
}

+ (SSignal *)applyLocalization:(NSString *)code {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        SMetaDisposable *disposable = [[SMetaDisposable alloc] init];
        
        [[[TGTelegramNetworking instance] context] updateApiEnvironment:^MTApiEnvironment *(MTApiEnvironment *apiEnvironment) {
            return [apiEnvironment withUpdatedLangPackCode:code];
        }];
        
        [TGDatabaseInstance() setCustomProperty:@"checkedLocalization" value:[code dataUsingEncoding:NSUTF8StringEncoding]];
        
        [[[TGTelegramNetworking instance] context] performBatchUpdates:^{
            TLRPClangpack_getDifference$langpack_getDifference *getLangPack = [[TLRPClangpack_getDifference$langpack_getDifference alloc] init];
            getLangPack.from_version = 0;
            [disposable setDisposable:[[[TGTelegramNetworking instance] requestSignal:getLangPack] startWithNext:^(TLLangPackDifference *next) {
                NSMutableDictionary<NSString *, NSString *> *dict = [[NSMutableDictionary alloc] init];
                for (TLLangPackString *string in next.strings) {
                    if ([string isKindOfClass:[TLLangPackString$langPackStringPluralized class]]) {
                        TLLangPackString$langPackStringPluralized *pluralized = (TLLangPackString$langPackStringPluralized *)string;
                        NSString *key = string.key;
                        if ([key isEqualToString:@"Contacts.ImportersCount"]) {
                            assert(true);
                        }
                        if (pluralized.zero_value != nil) {
                            dict[[key stringByAppendingString:@"_0"]] = pluralized.zero_value;
                        }
                        if (pluralized.one_value != nil) {
                            dict[[key stringByAppendingString:@"_1"]] = pluralized.one_value;
                        }
                        if (pluralized.two_value != nil) {
                            dict[[key stringByAppendingString:@"_2"]] = pluralized.two_value;
                        }
                        if (pluralized.few_value != nil) {
                            dict[[key stringByAppendingString:@"_3_10"]] = pluralized.few_value;
                        }
                        if (pluralized.many_value != nil) {
                            dict[[key stringByAppendingString:@"_many"]] = pluralized.many_value;
                        }
                        if (pluralized.other_value != nil) {
                            dict[[key stringByAppendingString:@"_other"]] = pluralized.other_value;
                            dict[[key stringByAppendingString:@"_any"]] = pluralized.other_value;
                        }
                    } else if ([string isKindOfClass:[TLLangPackString$langPackString class]]) {
                        dict[string.key] = ((TLLangPackString$langPackString *)string).value;
                    }
                }
                TGDispatchOnMainThread(^{
                    TGLocalization *currentLocalization = [[TGLocalization alloc] initWithVersion:next.version code:next.lang_code dict:dict isActive:true];
                    setCurrentNativeLocalization(currentLocalization, true);
                    [TGAppDelegateInstance resetLocalization];
                    [TGAppDelegateInstance updatePushRegistration];
                    [subscriber putCompletion];
                });
            }]];
        }];
        
        return disposable;
    }];
}

+ (SSignal *)pollLocalization {
    TLRPClangpack_getDifference$langpack_getDifference *getDifference = [[TLRPClangpack_getDifference$langpack_getDifference alloc] init];
    TGLocalization *current = currentNativeLocalization();
    getDifference.from_version = current.version;
    return [[[TGTelegramNetworking instance] requestSignal:getDifference] onNext:^(TLLangPackDifference *next) {
        NSMutableDictionary<NSString *, NSString *> *dict = [[NSMutableDictionary alloc] init];
        for (TLLangPackString *string in next.strings) {
            if ([string isKindOfClass:[TLLangPackString$langPackStringPluralized class]]) {
                TLLangPackString$langPackStringPluralized *pluralized = (TLLangPackString$langPackStringPluralized *)string;
                NSString *key = string.key;
                if (pluralized.zero_value != nil) {
                    dict[[key stringByAppendingString:@"_0"]] = pluralized.zero_value;
                }
                if (pluralized.one_value != nil) {
                    dict[[key stringByAppendingString:@"_1"]] = pluralized.one_value;
                }
                if (pluralized.two_value != nil) {
                    dict[[key stringByAppendingString:@"_2"]] = pluralized.two_value;
                }
                if (pluralized.few_value != nil) {
                    dict[[key stringByAppendingString:@"_3_10"]] = pluralized.few_value;
                }
                if (pluralized.many_value != nil) {
                    dict[[key stringByAppendingString:@"_many"]] = pluralized.many_value;
                }
                if (pluralized.other_value != nil) {
                    dict[[key stringByAppendingString:@"_other"]] = pluralized.other_value;
                    dict[[key stringByAppendingString:@"_any"]] = pluralized.other_value;
                }
            } else if ([string isKindOfClass:[TLLangPackString$langPackString class]]) {
                dict[string.key] = ((TLLangPackString$langPackString *)string).value;
            }
        }
        TGDispatchOnMainThread(^{
            TGLocalization *currentLocalization = [current mergedWith:dict version:next.version];
            setCurrentNativeLocalization(currentLocalization, false);
            [TGAppDelegateInstance resetLocalization];
        });
    }];
}

+ (void)mergeLocalization:(TLLangPackDifference *)next replace:(bool)replace {
    NSMutableDictionary<NSString *, NSString *> *dict = [[NSMutableDictionary alloc] init];
    for (TLLangPackString *string in next.strings) {
        if ([string isKindOfClass:[TLLangPackString$langPackStringPluralized class]]) {
            TLLangPackString$langPackStringPluralized *pluralized = (TLLangPackString$langPackStringPluralized *)string;
            NSString *key = string.key;
            if (pluralized.zero_value != nil) {
                dict[[key stringByAppendingString:@"_0"]] = pluralized.zero_value;
            }
            if (pluralized.one_value != nil) {
                dict[[key stringByAppendingString:@"_1"]] = pluralized.one_value;
            }
            if (pluralized.two_value != nil) {
                dict[[key stringByAppendingString:@"_2"]] = pluralized.two_value;
            }
            if (pluralized.few_value != nil) {
                dict[[key stringByAppendingString:@"_3_10"]] = pluralized.few_value;
            }
            if (pluralized.many_value != nil) {
                dict[[key stringByAppendingString:@"_many"]] = pluralized.many_value;
            }
            if (pluralized.other_value != nil) {
                dict[[key stringByAppendingString:@"_other"]] = pluralized.other_value;
            }
        } else if ([string isKindOfClass:[TLLangPackString$langPackString class]]) {
            dict[string.key] = ((TLLangPackString$langPackString *)string).value;
        }
    }
    TGLocalization *localization = [[TGLocalization alloc] initWithVersion:next.version code:next.lang_code dict:dict isActive:true];
    TGDispatchOnMainThread(^{
        if (replace) {
            setCurrentNativeLocalization(localization, false);
        } else {
            setCurrentNativeLocalization([currentNativeLocalization() mergedWith:dict version:localization.version], false);
        }
        [TGAppDelegateInstance resetLocalization];
    });
}

@end
