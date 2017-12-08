#import "TGCollectionMenuController.h"

@class SSignal;
@class TGTwoStepConfig;

@interface TGFastTwoStepVerificationSetupController : TGCollectionMenuController

@property (nonatomic, copy) void (^twoStepConfigUpdated)(TGTwoStepConfig *);

- (instancetype)initWithTwoStepConfig:(SSignal *)twoStepConfig completion:(void (^)(bool))completion;

@end
