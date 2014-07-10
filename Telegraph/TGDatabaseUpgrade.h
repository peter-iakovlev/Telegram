#import <Foundation/Foundation.h>

#import "PSKeyValueStore.h"

@interface TGDatabaseUpgrade : NSObject

+ (void)performUpgradeIfNecessaryForStore:(id<PSKeyValueStore>)store;

@end
