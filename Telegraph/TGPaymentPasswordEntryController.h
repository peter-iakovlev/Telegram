#import <LegacyComponents/LegacyComponents.h>

@class TGPresentation;

@interface TGPaymentPasswordEntryController : TGViewController

@property (nonatomic, strong) TGPresentation *presentation;
@property (nonatomic, copy) SSignal *(^payWithPassword)(NSString *password);

- (instancetype)initWithCardTitle:(NSString *)cardTitle;

- (void)dismissAnimated;

@end
