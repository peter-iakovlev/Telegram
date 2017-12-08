#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/ASWatcher.h>

@interface TGLoginCountriesController : TGViewController

@property (nonatomic, strong) ASHandle *watcherHandle;
@property (nonatomic, copy) void (^countrySelected)(int code, NSString *name, NSString *countryId);

- (id)initWithCodes:(bool)displayCodes;

+ (NSString *)countryNameByCode:(int)code;
+ (NSString *)countryIdByCode:(int)code;
+ (NSString *)countryNameByCountryId:(NSString *)countryId code:(int *)code;

@end
