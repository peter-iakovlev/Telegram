#import <LegacyComponents/LegacyComponents.h>

@class TGPresentation;

@interface TGWebPageController : TGViewController

@property (nonatomic, strong) TGPresentation *presentation;

- (instancetype)initWithTitle:(NSString *)title url:(NSURL *)url;

@end
