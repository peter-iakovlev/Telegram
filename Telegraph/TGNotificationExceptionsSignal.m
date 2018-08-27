#import "TGNotificationExceptionsSignal.h"
#import "TGDatabase.h"
#import "TGDialogListRemoteOffset.h"

@interface TGDialogFetcher : NSObject <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;
@property (nonatomic, copy) void (^completion)(NSNumber *);

- (void)performWithCompletion:(void (^)(NSNumber *))completion;

@end

@implementation TGNotificationExceptionsSignal

+ (SSignal *)fetchAllDialogsSignal
{
    SSignal *fetchSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGDialogFetcher *fetcher = [[TGDialogFetcher alloc] init];
        [fetcher performWithCompletion:^(NSNumber *result)
        {
            [subscriber putNext:result];
            if (result != nil)
                [subscriber putCompletion];
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [fetcher description];
        }];
    }];
    
    return [[fetchSignal startOn:[SQueue concurrentDefaultQueue]] mapToSignal:^SSignal *(NSNumber *result)
    {
        if (result != nil)
        {
            if (result.boolValue)
                return [SSignal single:@(true)];
            else
                return [[SSignal single:@(false)] then:fetchSignal];
        }
        else
        {
            return [SSignal single:nil];
        }
    }];
}

+ (SSignal *)notificationExceptionsSignal
{
    SSignal *exceptionsSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        [TGDatabaseInstance() loadPeerNotificationExceptions:^(NSArray *privateExceptions, NSArray *groupExceptions)
        {
            [subscriber putNext:@{ @"private": privateExceptions, @"group": groupExceptions }];
            [subscriber putCompletion];
        }];
        
        return nil;
    }];
    
    return [[self fetchAllDialogsSignal] mapToSignal:^SSignal *(__unused id value)
    {
        return exceptionsSignal;
    }];
}

@end


@implementation TGDialogFetcher

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)performWithCompletion:(void (^)(NSNumber *allLoaded))completion
{
    bool dialogListLoaded = [TGDatabaseInstance() customProperty:@"dialogListLoaded"].length != 0;
    if (dialogListLoaded)
    {
        completion(@(dialogListLoaded));
        return;
    }
    else
    {
        completion(nil);
    }
    
    self.completion = completion;
    
    NSData *data = [TGDatabaseInstance() customProperty:@"dialogListRemoteOffset"];
    TGDialogListRemoteOffset *remoteOffset = nil;
    if (data.length != 0) {
        remoteOffset = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    if (remoteOffset == nil) {
        remoteOffset = [[TGDialogListRemoteOffset alloc] initWithDate:[TGDatabaseInstance() loadConversationListRemoteOffsetDate] peerId:0 accessHash:0 messageId:0];
    }
    
    [ActionStageInstance() watchForGenericPath:@"/tg/dialoglist/@" watcher:self];
    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/dialoglist/(%d)", remoteOffset.date] options:@{@"date": @(remoteOffset.date), @"limit":@80, @"force":@true} watcher:self];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path hasPrefix:@"/tg/dialoglist"])
    {
        [self actorCompleted:ASStatusSuccess path:path result:resource];
    }
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)__unused result
{
    if ([path hasPrefix:@"/tg/dialoglist"])
    {
        if (status == 0)
        {
            bool dialogListLoaded = [TGDatabaseInstance() customProperty:@"dialogListLoaded"].length != 0;
            self.completion(@(dialogListLoaded));
        }
        else
        {
            self.completion(nil);
        }
    }
}

@end
