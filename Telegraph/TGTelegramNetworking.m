/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGTelegramNetworking.h"

#import "TGAppDelegate.h"

#if !TGUseModernNetworking
#import "TGSession.h"
#endif

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGTelegraph.h"
#import "TGPeerIdAdapter.h"

#import <MTProtoKit/MTProtoKit.h>
#import <MTProtoKit/MTLogging.h>
#import <MTProtoKit/MTKeychain.h>
#import <MTProtoKit/MTContext.h>
#import <MTProtoKit/MTApiEnvironment.h>
#import <MTProtoKit/MTDatacenterAddressSet.h>
#import <MTProtoKit/MTDatacenterAddress.h>
#import <MTProtoKit/MTTransportScheme.h>
#import <MTProtoKit/MTProto.h>
#import <MTProtoKit/MTRequestMessageService.h>
#import <MTProtoKit/MTRequest.h>
#import <MTProtoKit/MTRequestErrorContext.h>
#import <MTProtoKit/MTEncryption.h>
#import <MTProtoKit/MTDatacenterAuthInfo.h>
#import "TGUpdateMessageService.h"

#import <MTProtoKit/MTInternalId.h>

#import <CommonCrypto/CommonKeyDerivation.h>
#import <CommonCrypto/CommonCryptoError.h>

#import "TGNetworkWorker.h"

#import "TGTLSerialization.h"
#import "TGKeychainImport.h"

#import "TGNavigationBar.h"
#import "TGLoginPasswordController.h"

#import "TLUpdates+TG.h"

#import "TLRPCmessages_sendMessage_manual.h"
#import "TLRPCmessages_sendMedia_manual.h"
#import "TLRPCmessages_sendInlineBotResult.h"

#import "TGStringUtils.h"

#import "TLRPCauth_sendCode.h"

#import "../../config.h"

#import "TGLocalization.h"

#import "TGAccountSignals.h"

#import "TGInterfaceManager.h"

static const int TGMaxWorkerCount = 4;

MTInternalIdClass(TGDownloadWorker)

@implementation MTRequest (LegacyTL)

- (void)setBody:(TLMetaRpc *)body
{
    [self setPayload:[TGTLSerialization serializeMessage:body] metadata:body responseParser:^id(NSData *data)
    {
        return [TGTLSerialization parseResponse:data request:body];
    }];
}

- (id)body
{
    return self.metadata;
}

@end

@interface TGTelegramNetworking () <ASWatcher, MTProtoDelegate, MTRequestMessageServiceDelegate, TGNetworkWorkerDelegate, MTContextChangeListener>
{
    bool _isTestingEnvironment;
    id<MTKeychain> _settingsKeychain;
    id<MTKeychain> _keychain;
    MTContext *_context;
    MTProto *_mtProto;
    MTRequestMessageService *_requestService;
    TGUpdateMessageService *_updateService;
    NSInteger _masterDatacenterId;
    
    bool _isNetworkAvailable;
    bool _isConnected;
    bool _isUsingProxy;
    bool _isUpdatingConnectionContext;
    bool _isPerformingServiceTasks;
    
    bool _isPerformingGetDifference;
    
    int _dispatchNetworkStateToken;
    
    int _completeWakeUpToken;
    
    NSMutableDictionary *_workersByDatacenterId;
    NSMutableDictionary *_awaitingWorkerTokensByDatacenterId;
    NSMutableDictionary<NSNumber *, TGCdnData *> *_cdnDatas;
    
    NSMutableArray *_currentWakeUpCompletions;
    
    UIWindow *_currentPasswordEntryWindow;
    
    SMetaDisposable *_updateCallsConfig;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGTelegramNetworking

static void TGTelegramLoggingFunction(NSString *format, va_list args)
{
    TGLogv(format, args);
}

+ (TGTelegramNetworking *)instance
{
    static TGTelegramNetworking *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        MTLogSetLoggingFunction(&TGTelegramLoggingFunction);
        
        singleton = [[TGTelegramNetworking alloc] init];
    });
    return singleton;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        [ActionStageInstance() watchForPath:@"/tg/service/synchronizationstate" watcher:self];
        
        _currentWakeUpCompletions = [[NSMutableArray alloc] init];
        
        _settingsKeychain = [MTFileBasedKeychain keychainWithName:@"Telegram-Settings" documentsPath:[TGAppDelegate documentsPath]];
        NSString *environmentId = [_settingsKeychain objectForKey:@"environmentId" group:@"environment"];
        _isTestingEnvironment = environmentId != nil && [environmentId isEqualToString:@"testing"];
        
        NSString *keychainName = _isTestingEnvironment ? @"Telegram-Testing" : @"Telegram";
        _keychain = [MTFileBasedKeychain keychainWithName:keychainName documentsPath:[TGAppDelegate documentsPath]];
        
        _cdnDatas = [[NSMutableDictionary alloc] init];
        
#if TGUseModernNetworking
        if (![[_keychain objectForKey:@"importedLegacyKeychain" group:@"meta"] boolValue])
        {
            [TGKeychainImport importKeychain:_keychain clientUserId:TGTelegraphInstance.clientUserId];
            [_keychain setObject:@(true) forKey:@"importedLegacyKeychain" group:@"meta"];
        }
#endif
        
        MTApiEnvironment *apiEnvironment = [[MTApiEnvironment alloc] init];
        
        apiEnvironment.tcpPayloadPrefix = [[[NSUserDefaults standardUserDefaults] objectForKey:@"network_tcpPayloadPrefix"] dataByDecodingHexString];
        NSMutableDictionary *datacenterAddressOverrides = [[NSMutableDictionary alloc] init];
        for (int i = 0; i < 5; i++) {
            NSString *text = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"network_datacenterAddress_%d", i + 1]];
            if (text.length != 0) {
                NSRange portRange = [text rangeOfString:@":"];
                NSString *ip = nil;
                uint16_t port = 443;
                if (portRange.location != NSNotFound) {
                    ip = [text substringToIndex:portRange.location];
                    port = (uint16_t)[[text substringFromIndex:portRange.location + 1] intValue];
                } else {
                    ip = text;
                }
                datacenterAddressOverrides[@(i + 1)] = [[MTDatacenterAddress alloc] initWithIp:ip port:port preferForMedia:false restrictToTcp:false cdn:false preferForProxy:false];
            }
        }
        apiEnvironment.datacenterAddressOverrides = datacenterAddressOverrides;
        
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        
        int32_t apiId = 0;
        SETUP_API_ID(apiId)
        
        apiEnvironment.apiId = apiId;
        
        apiEnvironment.layer = @([[[TGTLSerialization alloc] init] currentLayer]);
        
        apiEnvironment = [apiEnvironment withUpdatedLangPackCode:currentNativeLocalization().code];
        TGLog(@"starting with langpack %@", currentNativeLocalization().code);
        
        NSData *socksProxyData = [TGDatabaseInstance() customProperty:@"socksProxyData"];
        if (socksProxyData != nil) {
            NSDictionary *socksProxyDict = [NSKeyedUnarchiver unarchiveObjectWithData:socksProxyData];
            if (socksProxyDict[@"ip"] != nil && socksProxyDict[@"port"] != nil && ![socksProxyDict[@"inactive"] boolValue]) {
                apiEnvironment = [apiEnvironment withUpdatedSocksProxySettings:[[MTSocksProxySettings alloc] initWithIp:socksProxyDict[@"ip"] port:(uint16_t)[socksProxyDict[@"port"] intValue] username:socksProxyDict[@"username"] password:socksProxyDict[@"password"]]];
            }
        }
        
        _context = [[MTContext alloc] initWithSerialization:[[TGTLSerialization alloc] init] apiEnvironment:apiEnvironment];
        [_context addChangeListener:self];
        
        _workersByDatacenterId = [[NSMutableDictionary alloc] init];
        _awaitingWorkerTokensByDatacenterId = [[NSMutableDictionary alloc] init];
        
        if (_isTestingEnvironment)
        {
            [_context updateAddressSetForDatacenterWithId:1 addressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                [[MTDatacenterAddress alloc] initWithIp:@"149.154.175.10" port:443 preferForMedia:false restrictToTcp:false cdn:false preferForProxy:false]
            ]] forceUpdateSchemes:true];
            [_context updateAddressSetForDatacenterWithId:2 addressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                [[MTDatacenterAddress alloc] initWithIp:@"149.154.167.40" port:443 preferForMedia:false restrictToTcp:false cdn:false preferForProxy:false]
            ]] forceUpdateSchemes:true];
        }
        else
        {
            [_context performBatchUpdates:^
            {
                [_context setSeedAddressSetForDatacenterWithId:1 seedAddressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                    [[MTDatacenterAddress alloc] initWithIp:@"149.154.175.50" port:443 preferForMedia:false restrictToTcp:false cdn:false preferForProxy:false],
                    [[MTDatacenterAddress alloc] initWithIp:@"2001:b28:f23d:f001::a" port:443 preferForMedia:false restrictToTcp:false cdn:false preferForProxy:false]
                ]]];
                
                [_context setSeedAddressSetForDatacenterWithId:2 seedAddressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                    [[MTDatacenterAddress alloc] initWithIp:@"149.154.167.51" port:443 preferForMedia:false restrictToTcp:false cdn:false preferForProxy:false],
                    [[MTDatacenterAddress alloc] initWithIp:@"2001:67c:4e8:f002::a" port:443 preferForMedia:false restrictToTcp:false cdn:false preferForProxy:false]
                ]]];
                
                [_context setSeedAddressSetForDatacenterWithId:3 seedAddressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                    [[MTDatacenterAddress alloc] initWithIp:@"149.154.175.100" port:443 preferForMedia:false restrictToTcp:false cdn:false preferForProxy:false],
                    [[MTDatacenterAddress alloc] initWithIp:@"2001:b28:f23d:f003::a" port:443 preferForMedia:false restrictToTcp:false cdn:false preferForProxy:false]
                ]]];

                [_context setSeedAddressSetForDatacenterWithId:4 seedAddressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                    [[MTDatacenterAddress alloc] initWithIp:@"149.154.167.91" port:443 preferForMedia:false restrictToTcp:false cdn:false preferForProxy:false],
                    [[MTDatacenterAddress alloc] initWithIp:@"2001:67c:4e8:f004::a" port:443 preferForMedia:false restrictToTcp:false cdn:false preferForProxy:false]
                ]]];

                [_context setSeedAddressSetForDatacenterWithId:5 seedAddressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                    [[MTDatacenterAddress alloc] initWithIp:@"149.154.171.5" port:443 preferForMedia:false restrictToTcp:false cdn:false preferForProxy:false],
                    [[MTDatacenterAddress alloc] initWithIp:@"2001:b28:f23f:f005::a" port:443 preferForMedia:false restrictToTcp:false cdn:false preferForProxy:false]
                ]]];
            }];
        }
        
        _context.keychain = _keychain;
        
        if (_isTestingEnvironment)
        {
            [_context updateAddressSetForDatacenterWithId:1 addressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                [[MTDatacenterAddress alloc] initWithIp:@"149.154.175.10" port:443 preferForMedia:false restrictToTcp:false cdn:false preferForProxy:false]
            ]] forceUpdateSchemes:true];
            [_context updateAddressSetForDatacenterWithId:2 addressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                [[MTDatacenterAddress alloc] initWithIp:@"149.154.167.40" port:443 preferForMedia:false restrictToTcp:false cdn:false preferForProxy:false]
            ]] forceUpdateSchemes:true];
        }
        
        [_context setDiscoverBackupAddressListSignal:[[MTSignal alloc] initWithGenerator:^id<MTDisposable>(MTSubscriber *subscriber) {
            id<SDisposable> disposable = [[TGAccountSignals fetchBackupIps:_isTestingEnvironment] startWithNext:nil error:^(__unused id error) {
                [subscriber putCompletion];
            } completed:^{
                [subscriber putCompletion];
            }];
            return [[MTBlockDisposable alloc] initWithBlock:^{
                [disposable dispose];
            }];
        }]];
        
        bool foundAuthorizations = false;
        for (NSInteger i = 0; i < 5; i++)
        {
            if ([_context authInfoForDatacenterWithId:i] != nil)
            {
                foundAuthorizations = true;
                break;
            }
        }
        
        NSNumber *nDefaultDatacenterId = [_keychain objectForKey:@"defaultDatacenterId" group:@"persistent"];
        if (nDefaultDatacenterId == nil)
        {
            if (foundAuthorizations)
                nDefaultDatacenterId = @(1);
            else
                nDefaultDatacenterId = @(2);
        }
        [self moveToDatacenterId:[nDefaultDatacenterId integerValue]];
        
#ifdef DEBUG
        TGLog(@"auth key id: %llx", [_context authInfoForDatacenterWithId:[nDefaultDatacenterId integerValue]].authKeyId);
#endif
        
        [ActionStageInstance() requestActor:@"/tg/datacenterWatchdog" options:nil flags:0 watcher:self];
        
        [[TGInterfaceManager instance] resetStartupTime:[self globalTime]];
    }
    return self;
}

- (SMulticastSignalManager *)genericTasksSignalManager
{
    return TGTelegraphInstance.genericTasksSignalManager;
}

- (NSURL *)sharedAuthInfoPath
{
    NSString *groupName = [@"group." stringByAppendingString:[[NSBundle mainBundle] bundleIdentifier]];
    NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupName];
    if (groupURL != nil)
    {
        NSURL *sharedAuthInfoPath = [groupURL URLByAppendingPathComponent:@"shared-auth-info" isDirectory:true];
        return sharedAuthInfoPath;
    }
    
    return nil;
}

- (void)removeCredentialsForExtensions
{
    if (iosMajorVersion() < 8)
        return;
    
    if ([self sharedAuthInfoPath] != nil)
        [[NSFileManager defaultManager] removeItemAtURL:[self sharedAuthInfoPath] error:nil];
}

- (NSData*)generateSalt256
{
    unsigned char salt[32];
    for (int i = 0; i < 32; i++)
    {
        salt[i] = (unsigned char)arc4random();
    }
    return [NSData dataWithBytes:salt length:32];
}

- (void)exportCredentialsForExtensions
{
    if (iosMajorVersion() < 8)
        return;
    
    [_context performBatchUpdates:^
    {
        bool isStrong = false;
        NSString *password = nil;
        if ([TGDatabaseInstance() isPasswordSet:&isStrong])
        {
            password = [TGDatabaseInstance() currentPassword];
            if (password == nil)
            {
                [self removeCredentialsForExtensions];
                return;
            }
        }
        
        MTDatacenterAuthInfo *authInfo = [_context authInfoForDatacenterWithId:_mtProto.datacenterId];
        if (authInfo != nil)
        {
            MTDatacenterAuthInfo *sharedAuthInfo = [[MTDatacenterAuthInfo alloc] initWithAuthKey:authInfo.authKey authKeyId:authInfo.authKeyId saltSet:@[] authKeyAttributes:@{}];
            NSString *versionString = [[NSString alloc] initWithFormat:@"%@ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:@{@"datacenterId":@(_mtProto.datacenterId), @"authInfo": sharedAuthInfo, @"version": versionString, @"clientUserId": @(TGTelegraphInstance.clientUserId) }];
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            dict[@"protected"] = @(password != nil);
            if (password != nil)
            {
                bool touchId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Passcode_useTouchId"] boolValue];
                if (isStrong)
                {
                    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
                    NSData *salt = [self generateSalt256];
                    
                    NSMutableData *key = [[NSMutableData alloc] initWithBytesNoCopy:malloc(32) length:32 freeWhenDone:true];
                    
                    int result = CCKeyDerivationPBKDF(kCCPBKDF2, passwordData.bytes, passwordData.length, salt.bytes, salt.length, kCCPRFHmacAlgSHA256, 1000, key.mutableBytes, 32);
                    if (result != kCCSuccess)
                    {
                        TGLog(@"Failed to derive keychain password");
                        [self removeCredentialsForExtensions];
                        
                        return;
                    }
                    
                    NSMutableData *iv = [[NSMutableData alloc] initWithBytesNoCopy:malloc(32) length:32 freeWhenDone:true];
                    arc4random_buf(iv.mutableBytes, 32);
                    
                    NSMutableData *encryptedData = [[NSMutableData alloc] init];
                    int32_t plainLength = (int32_t)data.length;
                    [encryptedData appendBytes:&plainLength length:4];
                    [encryptedData appendData:data];
                    while (encryptedData.length % 16 != 0)
                    {
                        uint8_t random = 0;
                        arc4random_buf(&random, 1);
                        [encryptedData appendBytes:&random length:1];
                    }
                    MTAesEncryptInplace(encryptedData, key, iv);
                    NSData *plainChecksum = MTSha1(data);
                    
                    dict[@"data"] = encryptedData;
                    dict[@"iv"] = iv;
                    dict[@"checksum"] = plainChecksum;
                    dict[@"salt"] = salt;
                    dict[@"touchId"] = @(touchId);
                }
                else
                {
                    dict[@"data"] = data;
                    dict[@"password"] = password;
                    dict[@"touchId"] = @(touchId);
                }
            }
            else
                dict[@"data"] = data;
            
            NSData *storedData = [NSKeyedArchiver archivedDataWithRootObject:dict];
            if ([self sharedAuthInfoPath] != nil)
                [storedData writeToURL:[self sharedAuthInfoPath] atomically:true];
        }
    }];
}

- (MTContext *)context
{
    return _context;
}

- (MTProto *)mtProto
{
    return _mtProto;
}

- (void)resetMainMtProto:(NSInteger)datacenterId
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        if (self->_requestService != nil)
        {
            _requestService.delegate = nil;
            [_mtProto removeMessageService:_requestService];
            _requestService = nil;
        }
        
        if (_updateService != nil)
        {
            [_mtProto removeMessageService:_updateService];
            _updateService = nil;
        }
        
        if (_mtProto != nil)
        {
            _mtProto.delegate = nil;
            [_mtProto stop];
        }
        
        _masterDatacenterId = datacenterId;
        
        _mtProto = [[MTProto alloc] initWithContext:_context datacenterId:datacenterId usageCalculationInfo:[self dataUsageInfo]];
        _mtProto.delegate = self;
        _isNetworkAvailable = true;
        _isConnected = true;
        [self dispatchNetworkState];
        
        _requestService = [[MTRequestMessageService alloc] initWithContext:_context];
        _requestService.delegate = self;
        [_mtProto addMessageService:_requestService];
        
        _updateService = [[TGUpdateMessageService alloc] init];
        [_mtProto addMessageService:_updateService];
        
        [_context authInfoForDatacenterWithIdRequired:_mtProto.datacenterId isCdn:false];
        
        if (TGTelegraphInstance.clientUserId == 0) {
            [_context transportSchemeForDatacenterWithIdRequired:datacenterId media:false];
        }
        
#if TARGET_IPHONE_SIMULATOR && true
        MTRequest *getSchemeRequest = [[MTRequest alloc] init];
        getSchemeRequest.body = [[TLRPChelp_getScheme$help_getScheme alloc] init];
        [getSchemeRequest setCompleted:^(TLScheme$scheme *result, __unused NSTimeInterval timestamp, __unused id error)
         {
             TGLog(@"%@", result.scheme_raw);
         }];
        [_requestService addRequest:getSchemeRequest];
        
        //[_context transportSchemeForDatacenterWithIdRequired:1];
#endif
    }];
}

- (NSTimeInterval)globalTime
{
#if TGUseModernNetworking
    return [_context globalTime];
#else
    return (int)(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970) + [[TGSession instance] timeDifference];
#endif
}

- (NSTimeInterval)timeOffset
{
#if TGUseModernNetworking
    return [_context globalTimeOffsetFromUTC];
#else
    return [[TGSession instance] timeOffsetFromUTC];
#endif
}

- (NSTimeInterval)approximateRemoteTime
{
#if TGUseModernNetworking
    return [_context globalTime];
#else
    return [[NSDate date] timeIntervalSince1970] + [[TGSession instance] timeOffsetFromUTC] - [[NSTimeZone localTimeZone] secondsFromGMT];
#endif
}

- (void)loadCredentials
{
#if TGUseModernNetworking
#else
    [[TGSession instance] loadSession];
#endif
}

- (void)start
{
#if TGUseModernNetworking
#else
    [[TGSession instance] takeOff];
#endif
}

- (void)pause
{
#if TGUseModernNetworking
    [_mtProto pause];
#else
    [[TGSession instance] suspendNetwork];
#endif
}

- (void)resume
{
#if TGUseModernNetworking
    [_mtProto resume];
#else
    [[TGSession instance] resumeNetwork];
#endif
}

- (void)moveToDatacenterId:(NSInteger)datacenterId
{
#if TGUseModernNetworking
    if (_mtProto == nil || datacenterId != _mtProto.datacenterId)
    {
        _masterDatacenterId = datacenterId;
        [_keychain setObject:@(_masterDatacenterId) forKey:@"defaultDatacenterId" group:@"persistent"];
        [self resetMainMtProto:datacenterId];
    }
#endif
}

- (void)restartWithCleanCredentials
{
#if TGUseModernNetworking
    if (_requestService != nil)
    {
        _requestService.delegate = nil;
        [_mtProto removeMessageService:_requestService];
    }
    
    _requestService = [[MTRequestMessageService alloc] initWithContext:_context];
    _requestService.delegate = self;
    [_mtProto addMessageService:_requestService];
    
    TGTelegraphInstance.clientUserId = 0;
    TGTelegraphInstance.clientIsActivated = false;
    [TGAppDelegateInstance saveSettings];
    
    [_context removeAllAuthTokens];
    
    [TGKeychainImport clearLegacyKeychain];
#else
    [[TGSession instance] clearSessionAndTakeOff];
#endif
}

- (void)clearExportedTokens
{
    NSInteger masterDatacenterId = _mtProto.datacenterId;
    [_context performBatchUpdates:^
    {
        for (NSNumber *nDatacenterId in [_context knownDatacenterIds])
        {
            if ([nDatacenterId integerValue] != masterDatacenterId)
                [_context updateAuthTokenForDatacenterWithId:[nDatacenterId integerValue] authToken:nil];
        }
    }];
}

- (void)mergeDatacenterAddress:(NSInteger)datacenterId address:(MTDatacenterAddress *)address
{
#if TGUseModernNetworking
    [_context performBatchUpdates:^
    {
        [_context addAddressForDatacenterWithId:datacenterId address:address];
        
        MTTransportScheme *scheme = [_context transportSchemeForDatacenterWithId:datacenterId media:false isProxy:false];
        if (![scheme.address isEqualToAddress:address])
        {
            scheme = [[MTTransportScheme alloc] initWithTransportClass:scheme.transportClass address:address media:false];
            [_context updateTransportSchemeForDatacenterWithId:datacenterId transportScheme:scheme media:false isProxy:false];
        }
    }];
#else
    TGDatacenterContext *datacenter = datacenter = [[TGDatacenterContext alloc] init];
    datacenter.datacenterId = datacenterId;
    
    int64_t authSessionId = [[TGSession instance] generateSessionId];
    int64_t authUploadSessionId = [[TGSession instance] generateSessionId];
    int64_t authDownloadSessionId = [[TGSession instance] generateSessionId];
    
    datacenter.authSessionId = authSessionId;
    datacenter.authDownloadSessionId = authDownloadSessionId;
    datacenter.authUploadSessionId = authUploadSessionId;
    
    NSMutableArray *addressSet = datacenter.addressSet == nil ? [[NSMutableArray alloc] init] : [[NSMutableArray alloc] initWithArray:datacenter.addressSet];
    [addressSet addObject:[[NSDictionary alloc] initWithObjectsAndKeys:address.ip, @"address", [[NSNumber alloc] initWithInt:address.port], @"port", nil]];
    datacenter.addressSet = addressSet;
    
    [[TGSession instance] mergeDatacenterData:@[datacenter]];
#endif
}

- (void)performDeferredServiceTasks
{    
#if TGUseModernNetworking
#else
    [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/network/requestFutureSalts/(%d)", [[TGSession instance] datacenterWithId:TG_DEFAULT_DATACENTER_ID].datacenterId] options:nil flags:0 watcher:[TGSession instance]];
#endif
}

- (NSInteger)masterDatacenterId
{
    return _masterDatacenterId;
}

- (id)requestDownloadWorkerForDatacenterId:(NSInteger)datacenterId type:(TGNetworkMediaTypeTag)type completion:(void (^)(TGNetworkWorkerGuard *))completion {
    return [self requestDownloadWorkerForDatacenterId:datacenterId type:type isCdn:false completion:completion];
}
    
- (id)requestDownloadWorkerForDatacenterId:(NSInteger)datacenterId type:(TGNetworkMediaTypeTag)type isCdn:(bool)isCdn completion:(void (^)(TGNetworkWorkerGuard *))completion
{
    id token = [[MTInternalId(TGDownloadWorker) alloc] init];
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        NSMutableArray *awaitingWorkerTokenList = _awaitingWorkerTokensByDatacenterId[@(datacenterId)];
        if (awaitingWorkerTokenList == nil)
        {
            awaitingWorkerTokenList = [[NSMutableArray alloc] init];
            _awaitingWorkerTokensByDatacenterId[@(datacenterId)] = awaitingWorkerTokenList;
        }
        
        [awaitingWorkerTokenList addObject:@[token, [completion copy], @(type), @(isCdn)]];
        
        [self _processWorkerQueue];
    }];
    return token;
}

- (void)_processWorkerQueue
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [_awaitingWorkerTokensByDatacenterId enumerateKeysAndObjectsUsingBlock:^(__unused NSNumber *nDatacenterId, NSMutableArray *list, __unused BOOL *stop)
        {
            if (list.count != 0)
            {
                NSArray *desc = list[0];
                bool isCdn = [desc[3] boolValue];
                
                NSMutableArray *workerList = _workersByDatacenterId[nDatacenterId];
                if (workerList == nil)
                {
                    workerList = [[NSMutableArray alloc] init];
                    _workersByDatacenterId[nDatacenterId] = workerList;
                }
                
                TGNetworkWorker *selectedWorker = nil;
                for (TGNetworkWorker *worker in workerList)
                {
                    if (!worker.isBusy)
                    {
                        selectedWorker = worker;
                        break;
                    }
                }
                
                if (selectedWorker == nil && workerList.count < TGMaxWorkerCount)
                {
                    if ([nDatacenterId intValue] > 10) {
                        if (!isCdn) {
                            TGLog(@"missing cdn mark");
                            isCdn = true;
                        }
                    }
                    TGNetworkWorker *worker = [[TGNetworkWorker alloc] initWithContext:_context datacenterId:[nDatacenterId integerValue] masterDatacenterId:_masterDatacenterId isCdn:isCdn];
                    worker.delegate = self;
                    [workerList addObject:worker];
                    
                    selectedWorker = worker;
                }
                
                if (selectedWorker != nil)
                {
                    [list removeObjectAtIndex:0];
                    
                    [selectedWorker setIsBusy:true];
                    [selectedWorker setUsageCalculationInfo:[self mediaUsageInfoForType:(TGNetworkMediaTypeTag)[desc[2] intValue]]];
                    TGNetworkWorkerGuard *guard = [[TGNetworkWorkerGuard alloc] initWithWorker:selectedWorker];
                    ((void (^)(TGNetworkWorkerGuard *))desc[1])(guard);
                }
            }
        }];
    }];
}

- (void)cancelDownloadWorkerRequestByToken:(id)token
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [_awaitingWorkerTokensByDatacenterId enumerateKeysAndObjectsUsingBlock:^(__unused NSNumber *nDatacenterId, NSMutableArray *list, __unused BOOL *stop)
        {
            NSInteger index = -1;
            for (NSArray *desc in list)
            {
                index++;
                if ([desc[0] isEqual:token])
                {
                    [list removeObjectAtIndex:(NSUInteger)index];
                    
                    break;
                }
            }
        }];
    }];
}

- (void)networkWorkerDidBecomeAvailable:(TGNetworkWorker *)__unused networkWorker
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [self _processWorkerQueue];
    }];
}

- (void)networkWorkerReadyToBeRemoved:(TGNetworkWorker *)networkWorker
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [_workersByDatacenterId enumerateKeysAndObjectsUsingBlock:^(__unused NSNumber *nDatacenterId, NSMutableArray *workers, __unused BOOL *stop)
        {
            NSInteger index = -1;
            for (TGNetworkWorker *worker in workers)
            {
                index++;
                
                if (worker == networkWorker)
                {
                    [workers removeObjectAtIndex:(NSUInteger)index];
                    
                    break;
                }
            }
        }];
    }];
}

- (void)updatePts:(int)pts ptsCount:(int)ptsCount seq:(int)seq
{
#if TGUseModernNetworking
    [_updateService updatePts:pts ptsCount:ptsCount seq:seq];
#else
    [[TGSession instance] _updatePts:pts date:date seq:seq];
#endif
}

- (void)addUpdates:(id)updates
{
    [_updateService addUpdates:updates];
}

- (void)switchBackends
{
#if TGUseModernNetworking
    if (_isTestingEnvironment)
        [_settingsKeychain setObject:@"production" forKey:@"environmentId" group:@"environment"];
    else
        [_settingsKeychain setObject:@"testing" forKey:@"environmentId" group:@"environment"];
    
    [TGTelegraphInstance willSwitchBackends];
    exit(0);
#else
    [[TGSession instance] switchBackends];
#endif
}

- (void)addRequest:(MTRequest *)request
{
    [_requestService addRequest:request];
}

- (NSObject *)performRpc:(TLMetaRpc *)rpc completionBlock:(void (^)(id<TLObject> response, int64_t responseTime, MTRpcError *error))completionBlock progressBlock:(void (^)(int length, float progress))progressBlock requiresCompletion:(bool)requiresCompletion requestClass:(int)requestClass
{
    return [self performRpc:rpc completionBlock:completionBlock progressBlock:progressBlock requiresCompletion:requiresCompletion requestClass:requestClass datacenterId:INT_MAX];
}

- (NSObject *)performRpc:(TLMetaRpc *)rpc completionBlock:(void (^)(id<TLObject> response, int64_t responseTime, MTRpcError *error))completionBlock progressBlock:(void (^)(int length, float progress))progressBlock requiresCompletion:(bool)requiresCompletion requestClass:(int)requestClass datacenterId:(int)datacenterId
{
    return [self performRpc:rpc completionBlock:completionBlock progressBlock:progressBlock quickAckBlock:nil requiresCompletion:requiresCompletion requestClass:requestClass datacenterId:datacenterId];
}

- (int64_t)peerIdFromInputPeer:(TLInputPeer *)peer {
    if ([peer isKindOfClass:[TLInputPeer$inputPeerChannel class]]) {
        return TGPeerIdFromChannelId(((TLInputPeer$inputPeerChannel *)peer).channel_id);
    } else if ([peer isKindOfClass:[TLInputPeer$inputPeerChat class]]) {
        return TGPeerIdFromGroupId(((TLInputPeer$inputPeerChat *)peer).chat_id);
    } else if ([peer isKindOfClass:[TLInputPeer$inputPeerUser class]]) {
        return ((TLInputPeer$inputPeerUser *)peer).user_id;
    } else if ([peer isKindOfClass:[TLInputPeer$inputPeerSelf class]]) {
        return TGTelegraphInstance.clientUserId;
    }
    
    return 0;
}

- (NSObject *)performRpc:(TLMetaRpc *)rpc completionBlock:(void (^)(id<TLObject> response, int64_t responseTime, MTRpcError *error))completionBlock progressBlock:(void (^)(int length, float progress))__unused progressBlock quickAckBlock:(void (^)())quickAckBlock requiresCompletion:(bool)__unused requiresCompletion requestClass:(int)requestClass datacenterId:(int)datacenterId
{
#if TGUseModernNetworking
    if (datacenterId != INT_MAX && datacenterId != 1)
        return nil;
    
    static bool collectingForwardMessages = false;
    static NSMutableDictionary *collectedForwardMessagesByPeerIdsString = nil;
    static SDisposableSet *currentCollectedForwardMessagesDisposable = nil;
    
    if ([rpc isKindOfClass:[TLRPCmessages_forwardMessages class]])
    {
        TLRPCmessages_forwardMessages *concreteRpc = (TLRPCmessages_forwardMessages *)rpc;
        int64_t fromPeerId = [self peerIdFromInputPeer:concreteRpc.from_peer];
        int64_t toPeerId = [self peerIdFromInputPeer:concreteRpc.to_peer];
        NSString *key = [[NSString alloc] initWithFormat:@"%lld:%lld:%d", fromPeerId, toPeerId, concreteRpc.flags];
        
        NSDictionary *forwardMessages = @{@"rpc": rpc, @"completion": [completionBlock copy]};
        
        if (collectingForwardMessages)
        {
            NSMutableArray *collectedForwardMessages = collectedForwardMessagesByPeerIdsString[key];
            if (collectedForwardMessages == nil) {
                collectedForwardMessages = [[NSMutableArray alloc] init];
                collectedForwardMessagesByPeerIdsString[key] = collectedForwardMessages;
            }
            
            [collectedForwardMessages addObject:forwardMessages];
        }
        else
        {
            collectingForwardMessages = true;
            
            collectedForwardMessagesByPeerIdsString = [[NSMutableDictionary alloc] init];
            
            collectedForwardMessagesByPeerIdsString[key] = [[NSMutableArray alloc] initWithArray:@[forwardMessages]];
            
            currentCollectedForwardMessagesDisposable = [[SDisposableSet alloc] init];
            
            dispatch_async([ActionStageInstance() globalStageDispatchQueue], ^
            {
                collectingForwardMessages = false;
                [collectedForwardMessagesByPeerIdsString enumerateKeysAndObjectsUsingBlock:^(id key, NSArray *records, __unused BOOL *stop) {
                    if (records.count == 0) {
                        return;
                    }
                    
                    id fromPeer = nil;
                    id toPeer = nil;
                    int32_t flags = 0;
                    
                    NSMutableDictionary *messageDescsByKey = [[NSMutableDictionary alloc] init];
                    for (NSDictionary *desc in records)
                    {
                        TLRPCmessages_forwardMessages *rpc = desc[@"rpc"];

                        if (fromPeer == nil) {
                            fromPeer = rpc.from_peer;
                            toPeer = rpc.to_peer;
                            flags = rpc.flags;
                        }
                        
                        NSMutableDictionary *messageDescs = messageDescsByKey[key];
                        if (messageDescs == nil)
                        {
                            messageDescs = [[NSMutableDictionary alloc] init];
                            messageDescsByKey[key] = messageDescs;
                            messageDescs[@"to_peer"] = rpc.to_peer;
                            messageDescs[@"from_peer"] = rpc.from_peer;
                        }
                        
                        NSMutableArray *messageIds = messageDescs[@"messageIds"];
                        if (messageIds == nil)
                        {
                            messageIds = [[NSMutableArray alloc] init];
                            messageDescs[@"messageIds"] = messageIds;
                        }
                        NSMutableArray *messageRandomIds = messageDescs[@"messageRandomIds"];
                        if (messageRandomIds == nil)
                        {
                            messageRandomIds = [[NSMutableArray alloc] init];
                            messageDescs[@"messageRandomIds"] = messageRandomIds;
                        }
                        NSMutableArray *completions = messageDescs[@"completions"];
                        if (completions == nil)
                        {
                            completions = [[NSMutableArray alloc] init];
                            messageDescs[@"completions"] = completions;
                        }
                        [messageIds addObjectsFromArray:rpc.n_id];
                        [messageRandomIds addObjectsFromArray:rpc.random_id];
                        [completions addObject:desc[@"completion"]];
                    }
                    
                    for (id key in messageDescsByKey.allKeys)
                    {
                        NSDictionary *messageDescs = messageDescsByKey[key];
                        NSArray *messageIds = messageDescs[@"messageIds"];
                        NSArray *messageRandomIds = messageDescs[@"messageRandomIds"];
                        
                        TLRPCmessages_forwardMessages$messages_forwardMessages *forwardMessages = [[TLRPCmessages_forwardMessages$messages_forwardMessages alloc] init];
                        forwardMessages.n_id = messageIds;
                        forwardMessages.from_peer = fromPeer;
                        forwardMessages.to_peer = toPeer;
                        forwardMessages.random_id = messageRandomIds;
                        forwardMessages.flags = flags;
                        
                        MTRequest *request = [[MTRequest alloc] init];
                        request.body = forwardMessages;
                        [request setCompleted:^(TLUpdates *updates, NSTimeInterval timestamp, id error)
                         {
                             [ActionStageInstance() dispatchOnStageQueue:^
                              {
                                  NSUInteger index = 0;
                                  for (void (^messageCompletionBlock)(id, int64_t, id) in messageDescs[@"completions"])
                                  {
                                      TLUpdates$updates *syntheticUpdates = nil;
                                      
                                      if ([updates isKindOfClass:[TLUpdates$updates class]])
                                      {
                                          TLUpdates$updates *concreteUpdates = (TLUpdates$updates *)updates;
                                          
                                          int32_t pts = 0;
                                          int32_t pts_count = 0;
                                          TLMessage *message = [concreteUpdates messageAtIndex:index pts:&pts pts_count:&pts_count];
                                          
                                          syntheticUpdates = [[TLUpdates$updates alloc] init];
                                          if (message != nil)
                                          {
                                              syntheticUpdates.chats = concreteUpdates.chats;
                                              syntheticUpdates.users = concreteUpdates.users;
                                              
                                              if ([toPeer isKindOfClass:[TLPeer$peerChannel class]]) {
                                                  TLUpdate$updateNewChannelMessage *updateNewChannelMessage = [[TLUpdate$updateNewChannelMessage alloc] init];
                                                  updateNewChannelMessage.message = message;
                                                  updateNewChannelMessage.pts = pts;
                                                  updateNewChannelMessage.pts_count = pts_count;
                                                  syntheticUpdates.updates = @[updateNewChannelMessage];
                                              } else {
                                                  TLUpdate$updateNewMessage *updateNewMessage = [[TLUpdate$updateNewMessage alloc] init];
                                                  updateNewMessage.message = message;
                                                  updateNewMessage.pts = pts;
                                                  updateNewMessage.pts_count = pts_count;
                                                  syntheticUpdates.updates = @[updateNewMessage];
                                              }
                                          }
                                      }
                                      
                                      messageCompletionBlock(error == nil ? syntheticUpdates : nil, (int64_t)(timestamp * 4294967296.0), error);
                                      
                                      index++;
                                  }
                              }];
                         }];
                        
                        [_requestService addRequest:request];
                        
                        id internalId = request.internalId;
                        [currentCollectedForwardMessagesDisposable add:[[SBlockDisposable alloc] initWithBlock:^
                        {
                            [_requestService removeRequestByInternalId:internalId];
                            
                            for (void (^messageCompletionBlock)(id, int64_t, id) in messageDescs[@"completions"])
                            {
                                messageCompletionBlock(nil, 0, [[TLRpcError$rpc_error alloc] init]);
                            }
                        }]];
                        
                        currentCollectedForwardMessagesDisposable = nil;
                    }
                }];
                [collectedForwardMessagesByPeerIdsString removeAllObjects];
            });
        }
        
        return currentCollectedForwardMessagesDisposable;
    }
    else
    {
        MTRequest *request = [[MTRequest alloc] init];
        request.passthroughPasswordEntryError = requestClass & TGRequestClassPassthroughPasswordNeeded;
        request.body = rpc;
        [request setCompleted:^(id result, NSTimeInterval timestamp, id error)
        {
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                if (completionBlock != nil)
                    completionBlock(result, (int64_t)(timestamp * 4294967296.0), error);
            }];
        }];
        
        if (quickAckBlock != nil)
            [request setAcknowledgementReceived:quickAckBlock];
        
        static NSArray *sequentialMessageClasses = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            sequentialMessageClasses = @[
                [TLRPCmessages_sendMessage_manual class],
                [TLRPCmessages_sendMedia_manual class],
                [TLRPCmessages_forwardMessages class],
                [TLRPCmessages_sendEncrypted class],
                [TLRPCmessages_sendEncryptedFile class],
                [TLRPCmessages_sendInlineBotResult class]
            ];
        });
        
        for (Class sequentialClass in sequentialMessageClasses)
        {
            if ([rpc isKindOfClass:sequentialClass])
            {
                [request setShouldDependOnRequest:^bool (MTRequest *anotherRequest)
                {
                    for (Class sequentialClass in sequentialMessageClasses)
                    {
                        if ([anotherRequest.body isKindOfClass:sequentialClass])
                            return true;
                    }
                    
                    return false;
                }];
                
                break;
            }
        }
        
        if ([request.body isKindOfClass:[TLRPCmessages_sendMessage_manual class]] || [request.body isKindOfClass:[TLRPCmessages_forwardMessages class]] || [request.body isKindOfClass:[TLRPCmessages_sendEncrypted class]] || [request.body isKindOfClass:[TLRPCmessages_sendInlineBotResult class]]) {
            request.hasHighPriority = true;
        }
        
        bool continueOnFloodWait = true;
        if ([request.body isKindOfClass:[TLRPCauth_sendCode class]] || [request.body isKindOfClass:[TLRPCauth_resendCode$auth_resendCode class]]) {
            continueOnFloodWait = false;
        }
        
        [request setShouldContinueExecutionWithErrorContext:^bool(MTRequestErrorContext *errorContext)
        {
            if (!continueOnFloodWait && errorContext.floodWaitSeconds > 0) {
                return false;
            }
            if (requestClass & 256/*TGRequestClassFailOnServerErrors*/)
                return errorContext.internalServerErrorCount < 5;
            if (requestClass & 512)
                return false;
            return true;
        }];
        
        [_requestService addRequest:request];
        return request.internalId;
    }
#else
    return [[TGSession instance] performRpc:rpc completionBlock:completionBlock progressBlock:progressBlock quickAckBlock:quickAckBlock requiresCompletion:requiresCompletion requestClass:requestClass datacenterId:datacenterId];
#endif
}

- (void)cancelRpc:(id)token
{
#if TGUseModernNetworking
    if ([token conformsToProtocol:@protocol(SDisposable)])
        [(id<SDisposable>)token dispose];
    else
        [_requestService removeRequestByInternalId:token];
#else
    [[TGSession instance] cancelRpc:token notifyServer:true];
#endif
}

- (bool)isNetworkAvailable
{
#if TGUseModernNetworking
    return _isNetworkAvailable;
#else
    return ![[TGSession instance] isOffline];
#endif
}

- (bool)isConnecting
{
#if TGUseModernNetworking
    return !_isConnected;
#else
    return [[TGSession instance] isConnecting];
#endif
}

- (bool)isUpdating
{
#if TGUseModernNetworking
    return _isUpdatingConnectionContext || _isPerformingServiceTasks;
#else
    return [[TGSession instance] isWaitingForFirstData];
#endif
}

- (void)wakeUpWithCompletion:(void (^)())completion
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        TGLog(@"[TGTelegramNetworking waking up]");
        
        /*if (_currentWakeUpCompletion != nil)
        {
            TGLog(@"[TGTelegramNetworking waking up]");
            _currentWakeUpCompletion();
            _currentWakeUpCompletion = nil;
        }*/
        
        [_currentWakeUpCompletions addObject:[completion copy]];
        
        _completeWakeUpToken++;
        int token = _completeWakeUpToken;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
        {
            if (token == _completeWakeUpToken)
            {
                if ([self _isReadyToBeSuspended])
                    [self completeWakeUpIfAny:@"2s match"];
            }
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
        {
            if (token == _completeWakeUpToken)
            {
                [self completeWakeUpIfAny:@"10s timeout"];
            }
        });
    }];
}

- (void)completeWakeUpIfAny:(NSString *)reason
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        if (_currentWakeUpCompletions.count != 0)
        {
            _completeWakeUpToken++;
            
            TGLog(@"[TGTelegramNetworking completed wake up: %@ (%d)]", reason, _currentWakeUpCompletions.count);
            
            for (dispatch_block_t block in _currentWakeUpCompletions)
            {
                block();
            }
            
            [_currentWakeUpCompletions removeAllObjects];
        }
    }];
}

- (void)requestMessageServiceAuthorizationRequired:(MTRequestMessageService *)__unused requestMessageService
{
    [_mtProto resetSessionInfo];
    
    [_context removeAllAuthTokens];
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/auth/logout/(%d)", TGTelegraphInstance.clientUserId] options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:true] forKey:@"force"] watcher:TGTelegraphInstance];
    }];
}

- (void)mtProtoNetworkAvailabilityChanged:(MTProto *)__unused mtProto isNetworkAvailable:(bool)isNetworkAvailable
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        _isNetworkAvailable = isNetworkAvailable;
        [self dispatchNetworkState];
    }];
}
- (void)mtProtoConnectionStateChanged:(MTProto *)__unused mtProto state:(MTProtoConnectionState *)state
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        _isConnected = state.isConnected;
        _isUsingProxy = state.isUsingProxy;
        [self dispatchNetworkState];
    }];
}

- (void)mtProtoConnectionContextUpdateStateChanged:(MTProto *)__unused mtProto isUpdatingConnectionContext:(bool)isUpdatingConnectionContext
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        _isUpdatingConnectionContext = isUpdatingConnectionContext;
        [self dispatchNetworkState];
    }];
}

- (void)mtProtoServiceTasksStateChanged:(MTProto *)__unused mtProto isPerformingServiceTasks:(bool)isPerformingServiceTasks
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        _isPerformingServiceTasks = isPerformingServiceTasks;
        [self dispatchNetworkState];
    }];
}

- (bool)_isReadyToBeSuspended
{
    int state = [ActionStageInstance() requestActorStateNow:@"/tg/service/updatestate"] ? 1 : 0;
    if (_isUpdatingConnectionContext || _isPerformingServiceTasks)
        state |= 1;
    if (!_isConnected)
        state |= 2;
    if (!_isNetworkAvailable)
        state |= 4;
    
    return state == 0;
}

- (void)dispatchNetworkState
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        _dispatchNetworkStateToken++;
        int token = _dispatchNetworkStateToken;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.08 * NSEC_PER_SEC)), [ActionStageInstance() globalStageDispatchQueue], ^
        {
            if (token != _dispatchNetworkStateToken)
                return;
            
            TGLog(@"[TGTelegramNetworking state: %d %d %d %d %d]", (int)_isUpdatingConnectionContext, (int)_isPerformingServiceTasks, (int)_isConnected, (int)_isNetworkAvailable, (int)_isUsingProxy);
            
            int state = [ActionStageInstance() requestActorStateNow:@"/tg/service/updatestate"] ? 1 : 0;
            if (_isUpdatingConnectionContext || _isPerformingServiceTasks)
                state |= 1;
            if (!_isConnected)
                state |= 2;
            if (!_isNetworkAvailable)
                state |= 4;
            if (_isUsingProxy)
                state |= 8;
            
            [ActionStageInstance() dispatchResource:@"/tg/service/synchronizationstate" resource:[[SGraphObjectNode alloc] initWithObject:[NSNumber numberWithInt:state]]];
        });
        
        int wakeupToken = _completeWakeUpToken;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
        {
            if (wakeupToken == _completeWakeUpToken)
            {
                if ([self _isReadyToBeSuspended])
                    [self completeWakeUpIfAny:@"state 1 match"];
            }
        });
    }];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:@"/tg/service/synchronizationstate"])
    {
        int state = [((SGraphObjectNode *)resource).object intValue];
        if (state == 0 && _isConnected && !_isUpdatingConnectionContext && !_isPerformingServiceTasks && _isNetworkAvailable)
            [self completeWakeUpIfAny:@"state 2 match"];
    }
}

- (SSignal *)downloadWorkerForDatacenterId:(NSInteger)datacenterId type:(TGNetworkMediaTypeTag)type {
    return [self downloadWorkerForDatacenterId:datacenterId type:type isCdn:false];
}

- (SSignal *)downloadWorkerForDatacenterId:(NSInteger)datacenterId type:(TGNetworkMediaTypeTag)type isCdn:(bool)isCdn {
    return [[SSignal alloc] initWithGenerator:^(SSubscriber *subscriber)
    {   
        id token = [self requestDownloadWorkerForDatacenterId:datacenterId type:type isCdn:isCdn completion:^(TGNetworkWorkerGuard *worker)
        {
            [subscriber putNext:worker];
            [subscriber putCompletion];
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [self cancelDownloadWorkerRequestByToken:token];
        }];
    }];
}

- (SSignal *)requestSignal:(TLMetaRpc *)rpc
{
    return [self requestSignal:rpc continueOnServerErrors:false];
}

- (SSignal *)requestSignal:(TLMetaRpc *)rpc continueOnServerErrors:(bool)continueOnServerErrors
{
    return [self requestSignal:rpc continueOnServerErrors:continueOnServerErrors failOnFloodErrors:false];
}

- (SSignal *)requestSignal:(TLMetaRpc *)rpc continueOnServerErrors:(bool)continueOnServerErrors failOnFloodErrors:(bool)failOnFloodErrors {
    return [self requestSignal:rpc continueOnServerErrors:continueOnServerErrors failOnFloodErrors:failOnFloodErrors failOnServerErrorsImmediately:false];
}

- (SSignal *)requestSignal:(TLMetaRpc *)rpc continueOnServerErrors:(bool)continueOnServerErrors failOnFloodErrors:(bool)failOnFloodErrors failOnServerErrorsImmediately:(bool)failOnServerErrorsImmediately {
    return [self requestSignal:rpc requestClass:(continueOnServerErrors ? 0 : TGRequestClassFailOnServerErrors) | (failOnFloodErrors ? TGRequestClassFailOnFloodErrors : 0) | (failOnServerErrorsImmediately ? TGRequestClassFailOnServerErrorsImmediately : 0)];
}

- (SSignal *)requestSignal:(TLMetaRpc *)rpc requestClass:(int)requestClass
{
    return [[SSignal alloc] initWithGenerator:^(SSubscriber *subscriber)
    {
        MTRequest *request = [[MTRequest alloc] init];
        request.body = rpc;
        [request setCompleted:^(id result, __unused NSTimeInterval timestamp, id error)
        {
            if (error == nil)
            {
                [subscriber putNext:result];
                [subscriber putCompletion];
            }
            else
                [subscriber putError:error];
        }];
        
        request.dependsOnPasswordEntry = (requestClass & TGRequestClassIgnorePasswordEntryRequired) == 0;
        
        static NSArray *sequentialMessageClasses = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            sequentialMessageClasses = @[
                [TLRPCmessages_sendMessage_manual class],
                [TLRPCmessages_sendMedia_manual class],
                [TLRPCmessages_forwardMessages class],
                [TLRPCmessages_sendEncrypted class],
                [TLRPCmessages_sendEncryptedFile class],
                [TLRPCmessages_sendInlineBotResult class]
            ];
        });
        
        for (Class sequentialClass in sequentialMessageClasses)
        {
            if ([rpc isKindOfClass:sequentialClass])
            {
                [request setShouldDependOnRequest:^bool (MTRequest *anotherRequest)
                {
                    for (Class sequentialClass in sequentialMessageClasses)
                    {
                        if ([anotherRequest.body isKindOfClass:sequentialClass])
                            return true;
                    }
                    
                    return false;
                }];
                
                break;
            }
        }
        
        if ([request.body isKindOfClass:[TLRPCmessages_sendMessage_manual class]] || [request.body isKindOfClass:[TLRPCmessages_forwardMessages class]] || [request.body isKindOfClass:[TLRPCmessages_sendEncrypted class]] || [request.body isKindOfClass:[TLRPCmessages_sendInlineBotResult class]]) {
            request.hasHighPriority = true;
        }
            
        [request setShouldContinueExecutionWithErrorContext:^bool(__unused MTRequestErrorContext *errorContext)
        {
            if (errorContext.floodWaitSeconds > 0)
            {
                if (requestClass & TGRequestClassFailOnFloodErrors)
                    return false;
            }
            
            if (requestClass & TGRequestClassFailOnServerErrorsImmediately) {
                return false;
            }
            
            if (!(requestClass & TGRequestClassFailOnServerErrors))
                return errorContext.internalServerErrorCount < 5;
            return true;
        }];
        
        [_requestService addRequest:request];
        id requestToken = request.internalId;
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [_requestService removeRequestByInternalId:requestToken];
        }];
    }];
}

- (SSignal *)requestSignalWithResponseTimestamp:(TLMetaRpc *)rpc {
    return [[SSignal alloc] initWithGenerator:^(SSubscriber *subscriber)
    {
        MTRequest *request = [[MTRequest alloc] init];
        request.body = rpc;
        [request setCompleted:^(id result, NSTimeInterval timestamp, id error)
        {
            if (error == nil && result != nil)
            {
                [subscriber putNext:@{@"result": result, @"timestamp": @(timestamp)}];
                [subscriber putCompletion];
            }
            else
                [subscriber putError:error];
        }];
        
        int requestClass = 0;
        
        request.dependsOnPasswordEntry = (requestClass & TGRequestClassIgnorePasswordEntryRequired) == 0;
        
        static NSArray *sequentialMessageClasses = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            sequentialMessageClasses = @[
                                         [TLRPCmessages_sendMessage_manual class],
                                         [TLRPCmessages_sendMedia_manual class],
                                         [TLRPCmessages_forwardMessages class],
                                         [TLRPCmessages_sendEncrypted class],
                                         [TLRPCmessages_sendEncryptedFile class],
                                         [TLRPCmessages_sendInlineBotResult class]
                                         ];
        });
        
        for (Class sequentialClass in sequentialMessageClasses)
        {
            if ([rpc isKindOfClass:sequentialClass])
            {
                [request setShouldDependOnRequest:^bool (MTRequest *anotherRequest)
                {
                    for (Class sequentialClass in sequentialMessageClasses)
                    {
                        if ([anotherRequest.body isKindOfClass:sequentialClass])
                            return true;
                    }
                    
                    return false;
                }];
                
                break;
            }
        }
        
        if ([request.body isKindOfClass:[TLRPCmessages_sendMessage_manual class]] || [request.body isKindOfClass:[TLRPCmessages_forwardMessages class]] || [request.body isKindOfClass:[TLRPCmessages_sendEncrypted class]] || [request.body isKindOfClass:[TLRPCmessages_sendInlineBotResult class]]) {
            request.hasHighPriority = true;
        }
        
        [request setShouldContinueExecutionWithErrorContext:^bool(__unused MTRequestErrorContext *errorContext)
        {
            if (errorContext.floodWaitSeconds > 0)
            {
                if (requestClass & TGRequestClassFailOnFloodErrors)
                    return false;
            }
            
            if (!(requestClass & TGRequestClassFailOnServerErrors))
                return errorContext.internalServerErrorCount < 5;
            return true;
        }];
        
        [_requestService addRequest:request];
        id requestToken = request.internalId;
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [_requestService removeRequestByInternalId:requestToken];
        }];
    }];
}

- (SSignal *)requestSignal:(TLMetaRpc *)rpc worker:(TGNetworkWorkerGuard *)worker
{
    return [[SSignal alloc] initWithGenerator:^(SSubscriber *subscriber)
    {
        MTRequest *request = [[MTRequest alloc] init];
        request.body = rpc;
        [request setCompleted:^(id result, __unused NSTimeInterval timestamp, id error)
        {
            if (error == nil)
            {
                [subscriber putNext:result];
                [subscriber putCompletion];
            }
            else
            {
                [subscriber putError:error];
            }
        }];
        
        [request setProgressUpdated:^(float value, __unused NSUInteger completeSize)
        {
            [subscriber putNext:@(value)];
        }];
        
        [request setShouldContinueExecutionWithErrorContext:^bool(__unused MTRequestErrorContext *errorContext)
        {
            return true;
        }];
        
        [(TGNetworkWorker *)worker.worker addRequest:request];
        id requestToken = request.internalId;
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [(TGNetworkWorker *)worker.worker cancelRequestById:requestToken];
        }];
    }];
}

- (NSString *)extractNetworkErrorType:(id)error
{
    if ([error isKindOfClass:[TLError$richError class]])
    {
        if (((TLError$richError *)error).type.length != 0)
            return ((TLError$richError *)error).type;
        
        NSString *errorDescription = nil;
        if ([error isKindOfClass:[TLError$error class]])
            errorDescription = ((TLError$error *)error).text;
        else if ([error isKindOfClass:[TLError$richError class]])
            errorDescription = ((TLError$richError *)error).n_description;
        
        NSMutableString *errorString = [[NSMutableString alloc] init];
        for (int i = 0; i < (int)errorDescription.length; i++)
        {
            unichar c = [errorDescription characterAtIndex:i];
            if (c == ':')
                break;
            
            [errorString appendString:[[NSString alloc] initWithCharacters:&c length:1]];
        }
        
        if (errorString.length != 0)
            return errorString;
    }
    else if ([error isKindOfClass:[MTRpcError class]])
        return ((MTRpcError *)error).errorDescription;
    
    return nil;
}
    
- (MTSignal *)fetchContextDatacenterPublicKeys:(MTContext *)__unused context datacenterId:(NSInteger)datacenterId {
    return [[MTSignal alloc] initWithGenerator:^id<MTDisposable>(MTSubscriber *subscriber) {
        TLRPChelp_getCdnConfig$help_getCdnConfig *getCdnConfig = [[TLRPChelp_getCdnConfig$help_getCdnConfig alloc] init];
        
        id<SDisposable> disposable = [[self requestSignal:getCdnConfig] startWithNext:^(TLCdnConfig *result) {
            NSMutableArray *publicKeys = [[NSMutableArray alloc] init];
            for (TLCdnPublicKey *publicKey in result.public_keys) {
                if (publicKey.dc_id == datacenterId) {
                    [publicKeys addObject:@{@"key": publicKey.public_key, @"fingerprint": @(MTRsaFingerprint(publicKey.public_key))}];
                }
            }
            [subscriber putNext:publicKeys];
            [subscriber putCompletion];
        }];
        
        return [[MTBlockDisposable alloc] initWithBlock:^{
            [disposable dispose];
        }];
    }];
}

- (void)contextIsPasswordRequiredUpdated:(MTContext *)context datacenterId:(NSInteger)datacenterId
{
    if (context == _context && datacenterId == _mtProto.datacenterId)
    {
        bool passwordRequired = [context isPasswordInputRequiredForDatacenterWithId:datacenterId];
        TGDispatchOnMainThread(^
        {
            if (passwordRequired)
            {
                bool alreadyPresentedEntryController = false;
                
                if ([TGAppDelegateInstance.loginNavigationController.topViewController isKindOfClass:[TGLoginPasswordController class]])
                {
                    alreadyPresentedEntryController = true;
                }
                if (_currentPasswordEntryWindow != nil)
                    alreadyPresentedEntryController = true;
                
                if (!alreadyPresentedEntryController)
                {
                    if (TGAppDelegateInstance.loginNavigationController.presentingViewController != nil)
                    {
                        NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:TGAppDelegateInstance.loginNavigationController.viewControllers];
                        [viewControllers removeLastObject];
                        [viewControllers addObject:[[TGLoginPasswordController alloc] init]];
                        [TGAppDelegateInstance.loginNavigationController setViewControllers:viewControllers animated:true];
                    }
                    else if (_currentPasswordEntryWindow == nil)
                    {
                        _currentPasswordEntryWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                        
                        TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[[[TGLoginPasswordController alloc] init]] navigationBarClass:[TGTransparentNavigationBar class]];
                        
                        _currentPasswordEntryWindow.rootViewController = navigationController;
                        _currentPasswordEntryWindow.hidden = false;
                        
                        CGRect defaultFrame = _currentPasswordEntryWindow.rootViewController.view.frame;
                        CGRect frame = defaultFrame;
                        frame.origin.y = defaultFrame.size.height;
                        _currentPasswordEntryWindow.rootViewController.view.frame = frame;
                        [UIView animateWithDuration:0.3 delay:0.0 options:[TGViewController preferredAnimationCurve] << 16 animations:^
                        {
                            _currentPasswordEntryWindow.rootViewController.view.frame = defaultFrame;
                        } completion:nil];
                    }
                }
            }
            else if (_currentPasswordEntryWindow != nil)
            {
                CGRect defaultFrame = _currentPasswordEntryWindow.rootViewController.view.frame;
                CGRect frame = defaultFrame;
                frame.origin.y = defaultFrame.size.height;
                UIWindow *window = _currentPasswordEntryWindow;
                _currentPasswordEntryWindow = nil;
                [UIView animateWithDuration:0.3 delay:0.0 options:[TGViewController preferredAnimationCurve] << 16 animations:^
                {
                    window.rootViewController.view.frame = frame;
                } completion:^(__unused BOOL finished)
                {
                    window.hidden = true;
                }];
            }
        });
    }
}

- (NSString *)baseUsagePath {
    return [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"network-usage"];
}

- (MTNetworkUsageCalculationInfo *)dataUsageInfo {
    return [[MTNetworkUsageCalculationInfo alloc] initWithFilePath:[self baseUsagePath] incomingWWANKey:TGTelegramNetworkUsageKeyDataIncomingWWAN outgoingWWANKey:TGTelegramNetworkUsageKeyDataOutgoingWWAN incomingOtherKey:TGTelegramNetworkUsageKeyDataIncomingOther outgoingOtherKey:TGTelegramNetworkUsageKeyDataOutgoingOther];
}

- (MTNetworkUsageCalculationInfo *)mediaUsageInfoForType:(TGNetworkMediaTypeTag)type {
    switch (type) {
        case TGNetworkMediaTypeTagGeneric:
            return [[MTNetworkUsageCalculationInfo alloc] initWithFilePath:[self baseUsagePath] incomingWWANKey:TGTelegramNetworkUsageKeyMediaGenericIncomingWWAN outgoingWWANKey:TGTelegramNetworkUsageKeyMediaGenericOutgoingWWAN incomingOtherKey:TGTelegramNetworkUsageKeyMediaGenericIncomingOther outgoingOtherKey:TGTelegramNetworkUsageKeyMediaGenericOutgoingOther];
        case TGNetworkMediaTypeTagImage:
            return [[MTNetworkUsageCalculationInfo alloc] initWithFilePath:[self baseUsagePath] incomingWWANKey:TGTelegramNetworkUsageKeyMediaImageIncomingWWAN outgoingWWANKey:TGTelegramNetworkUsageKeyMediaImageOutgoingWWAN incomingOtherKey:TGTelegramNetworkUsageKeyMediaImageIncomingOther outgoingOtherKey:TGTelegramNetworkUsageKeyMediaImageOutgoingOther];
        case TGNetworkMediaTypeTagVideo:
            return [[MTNetworkUsageCalculationInfo alloc] initWithFilePath:[self baseUsagePath] incomingWWANKey:TGTelegramNetworkUsageKeyMediaVideoIncomingWWAN outgoingWWANKey:TGTelegramNetworkUsageKeyMediaVideoOutgoingWWAN incomingOtherKey:TGTelegramNetworkUsageKeyMediaVideoIncomingOther outgoingOtherKey:TGTelegramNetworkUsageKeyMediaVideoOutgoingOther];
        case TGNetworkMediaTypeTagAudio:
            return [[MTNetworkUsageCalculationInfo alloc] initWithFilePath:[self baseUsagePath] incomingWWANKey:TGTelegramNetworkUsageKeyMediaAudioIncomingWWAN outgoingWWANKey:TGTelegramNetworkUsageKeyMediaAudioOutgoingWWAN incomingOtherKey:TGTelegramNetworkUsageKeyMediaAudioIncomingOther outgoingOtherKey:TGTelegramNetworkUsageKeyMediaAudioOutgoingOther];
        case TGNetworkMediaTypeTagDocument:
            return [[MTNetworkUsageCalculationInfo alloc] initWithFilePath:[self baseUsagePath] incomingWWANKey:TGTelegramNetworkUsageKeyMediaDocumentIncomingWWAN outgoingWWANKey:TGTelegramNetworkUsageKeyMediaDocumentOutgoingWWAN incomingOtherKey:TGTelegramNetworkUsageKeyMediaDocumentIncomingOther outgoingOtherKey:TGTelegramNetworkUsageKeyMediaDocumentOutgoingOther];
        case TGNetworkMediaTypeTagCall:
            return [[MTNetworkUsageCalculationInfo alloc] initWithFilePath:[self baseUsagePath] incomingWWANKey:TGTelegramNetworkUsageKeyCallIncomingWWAN outgoingWWANKey:TGTelegramNetworkUsageKeyCallOutgoingWWAN incomingOtherKey:TGTelegramNetworkUsageKeyCallIncomingOther outgoingOtherKey:TGTelegramNetworkUsageKeyCallOutgoingOther];
        default:
            return [[MTNetworkUsageCalculationInfo alloc] initWithFilePath:[self baseUsagePath] incomingWWANKey:TGTelegramNetworkUsageKeyMediaGenericIncomingWWAN outgoingWWANKey:TGTelegramNetworkUsageKeyMediaGenericOutgoingWWAN incomingOtherKey:TGTelegramNetworkUsageKeyMediaGenericIncomingOther outgoingOtherKey:TGTelegramNetworkUsageKeyMediaGenericOutgoingOther];
    }
}

- (NSString *)cellularUsageResetPath {
    return [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"cellular-usage-reset"];
}

- (NSString *)wifiUsageResetPath {
    return [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"wifi-usage-reset"];
}

@end
