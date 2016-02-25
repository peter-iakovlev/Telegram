#import "TGBridgeService.h"

@interface TGBridgePresetsService : TGBridgeService

+ (NSArray *)presetIdentifiers;

+ (NSDictionary *)currentPresets;
+ (void)storePresets:(NSDictionary *)presets;

@end
