#import "TGDatabaseContext.h"

#import "TGGlobalContext.h"
#import "TGDatabaseUpgrade.h"

#import "PSLMDBKeyValueStore.h"

#import "PSKeyValueEncoder.h"
#import "PSKeyValueDecoder.h"
#import "TGUserModel.h"
#import "TGMtFileLocation.h"

@interface TGDatabaseContext ()
{
    __weak TGGlobalContext *_globalContext;
    
    PSLMDBKeyValueStore *_keyValueStore;
    
    TGUserStore *_userStore;
}

@end

@implementation TGDatabaseContext

- (instancetype)initWithGlobalContext:(TGGlobalContext *)globalContext
{
    self = [super init];
    if (self != nil)
    {
        _globalContext = globalContext;
        
        //_keyValueStore = [PSLMDBKeyValueStore storeWithPath:[[globalContext path] stringByAppendingPathComponent:@"data"]];
        
        //[TGDatabaseUpgrade performUpgradeIfNecessaryForStore:_keyValueStore];
        
        //_userStore = [[TGUserStore alloc] initWithKeyValueStore:_keyValueStore];
    }
    return self;
}

- (TGGlobalContext *)globalContext
{
    return _globalContext;
}

- (TGUserStore *)userStore
{
    return _userStore;
}

@end
