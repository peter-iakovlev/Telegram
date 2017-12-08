#import <LegacyComponents/LegacyComponents.h>

#import <SSignalKit/SSignalKit.h>

@interface TGPasswordSetupController : TGViewController

@property (nonatomic, copy) void (^completion)(NSString *);

- (instancetype)initWithSetupNew:(bool)setupNew;

@end
