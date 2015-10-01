#import "TGSignUpRequestBuilder.h"

#import "TGTelegramNetworking.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGTelegraph.h"
#import "TGSchema.h"
#import "TGUser.h"
#import "TGUserDataRequestBuilder.h"

#import "TGTimer.h"

#import "TLUser$modernUser.h"

@interface TGSignUpRequestBuilder ()
{
    NSString *_phoneNumber;
    NSString *_phoneHash;
    NSString *_phoneCode;
    NSString *_firstName;
    NSString *_lastName;
    
    TGTimer *_timer;
}

@end

@implementation TGSignUpRequestBuilder

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
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }
}

+ (NSString *)genericPath
{
    return @"/tg/service/auth/signUp/@";
}

- (void)execute:(NSDictionary *)options
{
    _phoneNumber = [options objectForKey:@"phoneNumber"];
    _phoneHash = [options objectForKey:@"phoneCodeHash"];
    _phoneCode = [options objectForKey:@"phoneCode"];
    _firstName = [options objectForKey:@"firstName"];
    _lastName = [options objectForKey:@"lastName"];
    if (_phoneNumber == nil || _phoneHash == nil || _phoneCode == nil || _firstName == nil || _lastName == nil)
    {
        [self signUpFailed:TGSignUpResultInternalError];
        return;
    }
    
    ASHandle *actionHandle = _actionHandle;
    _timer = [[TGTimer alloc] initWithTimeout:15.0 repeat:false completion:^
    {
        [actionHandle requestAction:@"networkTimeout" options:nil];
    } queue:[ActionStageInstance() globalStageDispatchQueue]];
    [_timer start];
    
    self.cancelToken = [TGTelegraphInstance doSignUp:_phoneNumber phoneHash:_phoneHash phoneCode:_phoneCode firstName:_firstName lastName:_lastName requestBuilder:self];
}

- (void)signUpSuccess:(TLauth_Authorization *)authorization
{
    int userId = ((TLUser$modernUser *)authorization.user).n_id;
    
    [TGUserDataRequestBuilder executeUserDataUpdate:[NSArray arrayWithObject:authorization.user]];
    
    bool activated = true;
    
    [TGTelegraphInstance processAuthorizedWithUserId:userId clientIsActivated:activated];
    
    [ActionStageInstance() actionCompleted:self.path result:[[SGraphObjectNode alloc] initWithObject:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithBool:activated], @"activated", nil]]];
}

- (void)signUpFailed:(TGSignUpResult)reason
{
    [ActionStageInstance() actionFailed:self.path reason:reason];
}

- (void)signUpRedirect:(NSInteger)datacenterId
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
    
    self.cancelToken = [TGTelegraphInstance doSignUp:_phoneNumber phoneHash:_phoneHash phoneCode:_phoneCode firstName:_firstName lastName:_lastName requestBuilder:self];
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
        
        [self signUpFailed:TGSignUpResultNetworkError];
    }
}

@end
