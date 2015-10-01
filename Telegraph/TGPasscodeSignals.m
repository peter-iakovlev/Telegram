#import "TGPasscodeSignals.h"

#import "TGDatabase.h"

#import "ActionStage.h"

@implementation TGPasscodeStatus

- (instancetype)initWithEnabled:(bool)enabled encrypted:(bool)encrypted
{
    self = [super init];
    if (self != nil)
    {
        _enabled = enabled;
        _encrypted = encrypted;
    }
    return self;
}

@end

@interface TGPasscodeHelper : NSObject <ASWatcher>
{
    void (^_updated)(TGPasscodeStatus *);
    TGPasscodeStatus *_currentStatus;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGPasscodeHelper

- (instancetype)initWithUpdated:(void (^)(TGPasscodeStatus *))updated
{
    self = [super init];
    if (self != nil)
    {
        _updated = [updated copy];
        
        _currentStatus = [[TGPasscodeStatus alloc] initWithEnabled:[TGDatabaseInstance() isPasswordSet:NULL] encrypted:[TGDatabaseInstance() isEncryptionEnabled]];
        if (_updated)
            _updated(_currentStatus);
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        [ActionStageInstance() watchForPath:@"/databasePasswordChanged" watcher:self];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)__unused resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:@"/databasePasswordChanged"])
    {
        _currentStatus = [[TGPasscodeStatus alloc] initWithEnabled:[TGDatabaseInstance() isPasswordSet:NULL] encrypted:[TGDatabaseInstance() isEncryptionEnabled]];
        if (_updated)
            _updated(_currentStatus);
    }
}

@end

@implementation TGPasscodeSignals

+ (SSignal *)passcodeStatus
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGPasscodeHelper *helper = [[TGPasscodeHelper alloc] initWithUpdated:^(TGPasscodeStatus *status)
        {
            [subscriber putNext:status];
        }];
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [helper description]; //keep reference
        }];
    }];
}

@end
