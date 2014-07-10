#import <Foundation/Foundation.h>

#import "TGUserStore.h"

@class TGGlobalContext;

@interface TGDatabaseContext : NSObject

- (instancetype)initWithGlobalContext:(TGGlobalContext *)globalContext;

- (TGUserStore *)userStore;

@end
