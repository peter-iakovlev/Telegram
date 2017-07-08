#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

@class TLLangPackDifference;

@interface TGAvailableLocalization : NSObject
    
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *localizedTitle;
@property (nonatomic, strong, readonly) NSString *code;
    
- (instancetype)initWithTitle:(NSString *)title localizedTitle:(NSString *)localizedTitle code:(NSString *)code;
    
@end

@interface TGSuggestedLocalization : NSObject

@property (nonatomic, strong, readonly) TGAvailableLocalization *info;
@property (nonatomic, strong, readonly) NSString *continueWithLanguageString;
@property (nonatomic, strong, readonly) NSString *chooseLanguageString;
@property (nonatomic, strong, readonly) NSString *chooseLanguageOtherString;
@property (nonatomic, strong, readonly) NSString *englishLanguageNameString;

- (instancetype)initWithInfo:(TGAvailableLocalization *)info continueWithLanguageString:(NSString *)continueWithLanguageString chooseLanguageString:(NSString *)chooseLanguageString chooseLanguageOtherString:(NSString *)chooseLanguageOtherString englishLanguageNameString:(NSString *)englishLanguageNameString;

@end

@interface TGLocalizationSignals : NSObject

+ (SSignal *)suggestedLocalization;
+ (SSignal *)suggestedLocalizationData:(NSString *)code;
+ (SSignal *)availableLocalizations;
+ (SSignal *)applyLocalization:(NSString *)code;
+ (SSignal *)pollLocalization;
+ (void)mergeLocalization:(TLLangPackDifference *)next replace:(bool)replace;

@end
