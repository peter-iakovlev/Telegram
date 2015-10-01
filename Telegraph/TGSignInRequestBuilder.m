#import "TGSignInRequestBuilder.h"

#import "TGTelegramNetworking.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGTelegraph.h"
#import "TGSchema.h"
#import "TGUser.h"
#import "TGUserDataRequestBuilder.h"

#import "TGTimer.h"

#import "TLUser$modernUser.h"

@interface TGSignInRequestBuilder ()
{
    NSString *_phoneNumber;
    NSString *_phoneHash;
    NSString *_phoneCode;
    
    TGTimer *_timer;
}

@end

@implementation TGSignInRequestBuilder

- (id)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        self.cancelTimeout = 0;
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }
}

+ (NSString *)genericPath
{
    return @"/tg/service/auth/signIn/@";
}

- (void)execute:(NSDictionary *)options
{
    _phoneNumber = [options objectForKey:@"phoneNumber"];
    _phoneHash = [options objectForKey:@"phoneCodeHash"];
    _phoneCode = [options objectForKey:@"phoneCode"];
    if (_phoneNumber == nil || _phoneHash == nil || _phoneCode == nil)
    {
        [self signInFailed:TGSignInResultInvalidToken];
        return;
    }
    
    ASHandle *actionHandle = _actionHandle;
    _timer = [[TGTimer alloc] initWithTimeout:15.0 repeat:false completion:^
    {
        [actionHandle requestAction:@"networkTimeout" options:nil];
    } queue:[ActionStageInstance() globalStageDispatchQueue]];
    [_timer start];
    
    self.cancelToken = [TGTelegraphInstance doSignIn:_phoneNumber phoneHash:_phoneHash phoneCode:_phoneCode requestBuilder:self];
}

- (void)signInSuccess:(TLauth_Authorization *)authorization
{
    [TGUserDataRequestBuilder executeUserDataUpdate:[NSArray arrayWithObject:authorization.user]];
    
    bool activated = true;
    
    [TGTelegraphInstance processAuthorizedWithUserId:((TLUser$modernUser *)authorization.user).n_id clientIsActivated:activated];
    
    [ActionStageInstance() actionCompleted:self.path result:[[SGraphObjectNode alloc] initWithObject:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithBool:activated], @"activated", nil]]];
}

- (void)signInFailed:(TGSignInResult)reason
{
    [ActionStageInstance() actionFailed:self.path reason:reason];
}

- (void)signInRedirect:(NSInteger)datacenterId
{
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }
    
    [[TGTelegramNetworking instance] moveToDatacenterId:datacenterId];
    
    ASHandle *actionHandle = _actionHandle;
    _timer = [[TGTimer alloc] initWithTimeout:15.0 repeat:false completion:^
    {
        [actionHandle requestAction:@"networkTimeout" options:nil];
    } queue:[ActionStageInstance() globalStageDispatchQueue]];
    [_timer start];
    
    self.cancelToken = [TGTelegraphInstance doSignIn:_phoneNumber phoneHash:_phoneHash phoneCode:_phoneCode requestBuilder:self];
}

- (void)cancel
{
    if (self.cancelToken != nil)
    {
        [TGTelegraphInstance cancelRequestByToken:self.cancelToken];
        self.cancelToken = nil;
    }
    
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
        
        [self signInFailed:TGSignInResultNetworkError];
    }
}

@end
