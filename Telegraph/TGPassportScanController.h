#import <LegacyComponents/LegacyComponents.h>

@class TGPresentation;
@class TGPassportMRZ;

@interface TGPassportScanController : TGViewController

@property (nonatomic, strong) TGPresentation *presentation;

@property (nonatomic, copy) void (^finishedWithMRZ)(TGPassportMRZ *);

@end
