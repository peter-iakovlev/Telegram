#import "TGCollectionMenuController.h"

@class SSignal;
@class TGTwoStepConfig;

@interface TGFastTwoStepVerificationSetupController : TGCollectionMenuController

@property (nonatomic, copy) void (^twoStepConfigUpdated)(TGTwoStepConfig *);

- (instancetype)initWithTwoStepConfig:(SSignal *)twoStepConfig passport:(bool)passport completion:(void (^)(bool, TGTwoStepConfig *, NSString *))completion;

@end
