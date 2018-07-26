#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/ASWatcher.h>

@class TGPresentation;

@interface TGLoginCountriesController : TGViewController

@property (nonatomic, strong) ASHandle *watcherHandle;
@property (nonatomic, copy) void (^countrySelected)(int code, NSString *name, NSString *countryId);
@property (nonatomic, strong) TGPresentation *presentation;

- (id)initWithCodes:(bool)displayCodes;

+ (NSString *)countryCodeByMRZCode:(NSString *)code;
+ (NSString *)countryNameByCode:(int)code;
+ (NSString *)countryIdByCode:(int)code;
+ (NSString *)countryNameByCountryId:(NSString *)countryId code:(int *)code;

@end
