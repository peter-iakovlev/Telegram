#import "TGCollectionMenuController.h"

@class TGTwoStepConfig;

@interface TGPasswordEntryController : TGCollectionMenuController

@property (nonatomic, copy) void (^completion)(NSString *);

- (instancetype)initWithConfig:(TGTwoStepConfig *)config;

@end
