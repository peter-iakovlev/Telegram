#import "TGLogoutRequestBuilder.h"

#import "ActionStage.h"

#import "TGTelegraph.h"

#import "TGTimer.h"

@interface TGLogoutRequestBuilder ()
{
    TGTimer *_timer;
}

@end

@implementation TGLogoutRequestBuilder

@synthesize actionHandle = _actionHandle;

+ (NSString *)genericPath
{
    return @"/tg/auth/logout/@";
}

- (id)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
        _actionHandle.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)execute:(NSDictionary *)options
{
    if (![[options objectForKey:@"force"] boolValue])
    {
        ASHandle *actionHandle = _actionHandle;
        _timer = [[TGTimer alloc] initWithTimeout:15.0 repeat:false completion:^
        {
            [actionHandle requestAction:@"networkTimeout" options:nil];
        } queue:[ActionStageInstance() globalStageDispatchQueue]];
        [_timer start];
        
        self.cancelToken = [TGTelegraphInstance doRequestLogout:self];
    }
    else
    {
        [self logoutSuccess:true];
    }
}

- (void)logoutSuccess
{
    [self logoutSuccess:false];
}

- (void)logoutSuccess:(bool)force
{
    if (self.cancelToken != nil || force)
    {
        self.cancelToken = nil;
        
        [ActionStageInstance() actionCompleted:self.path result:nil];
        
        [TGTelegraphInstance doLogout];
    }
}

- (void)logoutFailed
{
    [self logoutSuccess:false];
}

- (void)cancel
{
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }
    
    [super cancel];
}

#pragma mark -

- (void)actionStageActionRequested:(NSString *)action options:(id)__unused options
{
    if ([action isEqualToString:@"networkTimeout"])
    {
        if (self.cancelToken != nil)
        {
            [TGTelegraphInstance cancelRequestByToken:self.cancelToken];
            self.cancelToken = nil;
        }
        
        [self logoutSuccess:false];
    }
}

@end
