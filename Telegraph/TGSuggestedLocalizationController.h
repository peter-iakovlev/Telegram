#import "TGViewController.h"

@class TGSuggestedLocalization;

@interface TGSuggestedLocalizationController : TGViewController

@property (nonatomic, copy) void (^appliedLanguage)();
@property (nonatomic, copy) void (^other)();

- (instancetype)initWithSuggestedLocalization:(TGSuggestedLocalization *)suggestedLocalization;

@end
