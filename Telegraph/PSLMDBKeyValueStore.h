#import "PSKeyValueStore.h"

@interface PSLMDBKeyValueStore : NSObject <PSKeyValueStore>

+ (instancetype)storeWithPath:(NSString *)path;

- (void)close;

@end
