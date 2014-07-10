#import <Foundation/Foundation.h>

#import "PSKeyValueStore.h"

@interface TGDatabaseUpgrade_Users_LegacyToV1 : NSObject

+ (void)performUpgradeWithKeyValueStore:(id<PSKeyValueStore>)keyValueStore;

@end
