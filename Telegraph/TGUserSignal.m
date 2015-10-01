#import "TGUserSignal.h"

#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"
#import "TGDatabase.h"

#import "ActionStage.h"

@interface TGUserUpdatesAdapter : NSObject <ASWatcher>
{
    int32_t _userId;
    void (^_userUpdated)(TGUser *);
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGUserUpdatesAdapter

- (instancetype)initWithUserId:(int32_t)userId userUpdated:(void (^)(TGUser *))userUpdated
{
    self = [super init];
    if (self != nil)
    {
        _userId = userId;
        _userUpdated = [userUpdated copy];
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        [ActionStageInstance() watchForPaths:@[
            @"/tg/userdatachanges",
            @"/tg/userpresencechanges"
        ] watcher:self];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:@"/tg/userdatachanges"] || [path isEqualToString:@"/tg/userpresencechanges"])
    {
        NSArray *users = ((SGraphObjectNode *)resource).object;
        
        for (TGUser *user in users)
        {
            if (user.uid == _userId)
            {
                if (_userUpdated)
                    _userUpdated(user);
            }
        }
    }
}

@end

@implementation TGUserSignal

+ (SSignal *)userWithUserId:(int32_t)userId
{
    SSignal *localSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGUser *user = [TGDatabaseInstance() loadUser:userId];
        if (user == nil)
            [subscriber putError:nil];
        else
        {
            [subscriber putNext:user];
            [subscriber putCompletion];
        }
        return nil;
    }];
    
    SSignal *updatesSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGUserUpdatesAdapter *adapter = [[TGUserUpdatesAdapter alloc] initWithUserId:userId userUpdated:^(TGUser *user)
        {
            [subscriber putNext:user];
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [adapter description]; //keep reference
        }];
    }];
    
    return [localSignal then:updatesSignal];
}

@end
