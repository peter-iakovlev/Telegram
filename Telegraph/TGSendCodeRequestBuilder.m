#import "TGSendCodeRequestBuilder.h"

#import "TGTelegraph.h"

#import "TGSchema.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGTelegramNetworking.h"

#import "TGTimer.h"

@interface TGSendCodeRequestBuilder ()
{
    NSString *_phone;
    NSString *_phoneHash;
}

@property (nonatomic, strong) TGTimer *timer;
@property (nonatomic) bool sendingCall;

@end

@implementation TGSendCodeRequestBuilder

@synthesize actionHandle = _actionHandle;

@synthesize timer = _timer;
@synthesize sendingCall = _sendingCall;

+ (NSString *)genericPath
{
    return @"/tg/service/auth/sendCode/@";
}

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
    
    [_actionHandle reset];
}

- (void)execute:(NSDictionary *)options
{
    _phone = [options objectForKey:@"phoneNumber"];
    _phoneHash = [options objectForKey:@"phoneHash"];
    
    if ([[options objectForKey:@"requestCall"] boolValue])
    {
        _sendingCall = true;
        self.cancelToken = [TGTelegraphInstance doSendPhoneCall:_phone phoneHash:[options objectForKey:@"phoneHash"] requestBuilder:self];
    }
    else
    {
        if ([[TGTelegramNetworking instance] isConnecting] && ![[TGTelegramNetworking instance] isNetworkAvailable])
        {
            [ActionStageInstance() actionFailed:self.path reason:TGSendCodeErrorNetwork];
        }
        else
        {
            ASHandle *actionHandle = _actionHandle;
            _timer = [[TGTimer alloc] initWithTimeout:15.0 repeat:false completion:^
            {
                [actionHandle requestAction:@"networkTimeout" options:nil];
            } queue:[ActionStageInstance() globalStageDispatchQueue]];
            [_timer start];
            
            if ([options[@"requestSms"] boolValue])
            {
                self.cancelToken = [TGTelegraphInstance doSendConfirmationSms:_phone phoneHash:_phoneHash requestBuilder:self];
            }
            else
                self.cancelToken = [TGTelegraphInstance doSendConfirmationCode:_phone requestBuilder:self];
        }
    }
}

- (void)sendCodeRequestSuccess:(TLauth_SentCode *)sendCode
{
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if ([sendCode isKindOfClass:[TLauth_SentCode$auth_sentAppCode class]])
    {
        TLauth_SentCode$auth_sentAppCode *concreteCode = (TLauth_SentCode$auth_sentAppCode *)sendCode;
        
        [dict setObject:concreteCode.phone_code_hash forKey:@"phoneCodeHash"];
        [dict setObject:[NSNumber numberWithBool:concreteCode.phone_registered] forKey:@"phoneRegistered"];
        dict[@"callTimeout"] = @(concreteCode.send_call_timeout);
        dict[@"messageSentToTelegram"] = @true;
    }
    else
    {
        TLauth_SentCode$auth_sentCode *concreteCode = (TLauth_SentCode$auth_sentCode *)sendCode;
        
        [dict setObject:concreteCode.phone_code_hash forKey:@"phoneCodeHash"];
        [dict setObject:[NSNumber numberWithBool:concreteCode.phone_registered] forKey:@"phoneRegistered"];
        dict[@"callTimeout"] = @(concreteCode.send_call_timeout);
    }
    
    [ActionStageInstance() actionCompleted:self.path result:[[SGraphObjectNode alloc] initWithObject:dict]];
}

- (void)sendCodeRequestFailed:(TGSendCodeError)errorCode
{
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }
    
    [ActionStageInstance() actionFailed:self.path reason:errorCode];
}

- (void)sendCodeRedirect:(NSInteger)datacenterId
{
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }
    
    ASHandle *actionHandle = _actionHandle;
    _timer = [[TGTimer alloc] initWithTimeout:15.0 repeat:false completion:^
    {
        [actionHandle requestAction:@"networkTimeout" options:nil];
    } queue:[ActionStageInstance() globalStageDispatchQueue]];
    [_timer start];
    
    [[TGTelegramNetworking instance] moveToDatacenterId:datacenterId];
    
    self.cancelToken = [TGTelegraphInstance doSendConfirmationCode:_phone requestBuilder:self];
}

- (void)sendSmsRequestSuccess:(bool)success
{
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if (success)
        [ActionStageInstance() actionCompleted:self.path result:[[SGraphObjectNode alloc] initWithObject:dict]];
    else
        [ActionStageInstance() actionFailed:self.path reason:TGSendCodeErrorUnknown];
}

- (void)sendSmsRequestFailed:(TGSendCodeError)errorCode
{
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }
    
    [ActionStageInstance() actionFailed:self.path reason:errorCode];
}

- (void)sendSmsRedirect:(NSInteger)datacenterId
{
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }
    
    ASHandle *actionHandle = _actionHandle;
    _timer = [[TGTimer alloc] initWithTimeout:15.0 repeat:false completion:^
    {
        [actionHandle requestAction:@"networkTimeout" options:nil];
    } queue:[ActionStageInstance() globalStageDispatchQueue]];
    [_timer start];
    
    [[TGTelegramNetworking instance] moveToDatacenterId:datacenterId];
    
    self.cancelToken = [TGTelegraphInstance doSendConfirmationSms:_phone phoneHash:_phoneHash requestBuilder:self];
}

- (void)sendCallRequestSuccess
{
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)sendCallRequestFailed
{
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }
    
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

- (void)sendCallRedirect:(NSInteger)datacenterId
{
    [self sendCodeRedirect:datacenterId];
}

- (void)cancel
{
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }
    
    if (self.cancelToken != nil)
    {
        [TGTelegraphInstance cancelRequestByToken:self.cancelToken];
        self.cancelToken = nil;
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
        
        if (_sendingCall)
            [self sendCallRequestFailed];
        else
            [self sendCodeRequestFailed:TGSendCodeErrorNetwork];
    }
}

@end
