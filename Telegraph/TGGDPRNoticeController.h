#import <LegacyComponents/LegacyComponents.h>

@class TGPresentation;
@class TGTermsOfService;

@interface TGGDPRNoticeController : TGViewController

@property (nonatomic, strong) TGPresentation *presentation;

- (instancetype)initWithTermsOfService:(TGTermsOfService *)termsOfService;

@end
