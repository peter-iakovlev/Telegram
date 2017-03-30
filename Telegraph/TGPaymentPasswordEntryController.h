#import "TGViewController.h"

@interface TGPaymentPasswordEntryController : TGViewController

@property (nonatomic, copy) SSignal *(^payWithPassword)(NSString *password);

- (instancetype)initWithCardTitle:(NSString *)cardTitle;

- (void)dismissAnimated;

@end
