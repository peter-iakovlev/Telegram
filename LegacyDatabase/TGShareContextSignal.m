#import "TGShareContextSignal.h"

#import "TGShareMtSerialization.h"

#import <MTProtoKitDynamic/MTProtoKitDynamic.h>

#import <CommonCrypto/CommonKeyDerivation.h>
#import <CommonCrypto/CommonCryptoError.h>

#import "../../config.h"

#import "TGLocalization.h"
#import "TGNetworkSettings.h"

#import "TGICloudEmergencyDataSignals.h"

#import "TGLegacyDatabase.h"
#import "TGLegacyUser.h"

@implementation TGUnauthorizedShareContext

@end

@implementation TGEncryptedShareContext

- (instancetype)initWithSimplePassword:(bool)simplePassword allowTouchId:(bool)allowTouchId verifyPassword:(bool (^)(NSString *))verifyPassword
{
    self = [super init];
    if (self != nil)
    {
        _simplePassword = simplePassword;
        _allowTouchId = allowTouchId;
        _verifyPassword = [verifyPassword copy];
    }
    return self;
}

@end

@implementation TGShareContextSignal

+ (NSURL *)groupUrl
{
    NSArray *suffixes = @[ @".Share", @".SiriIntents", @".Widget" ];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    for (NSString *suffix in suffixes)
    {
        if ([bundleIdentifier hasSuffix:suffix])
        {
            NSString *groupName = [@"group." stringByAppendingString:[[[NSBundle mainBundle] bundleIdentifier] substringToIndex:[[NSBundle mainBundle] bundleIdentifier].length - suffix.length]];
            NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupName];
            return groupURL;
        }
    }
    
    return nil;
}

+ (NSURL *)sharedAuthInfoPath
{
    NSURL *groupURL = [self groupUrl];
    if (groupURL != nil)
    {
        NSURL *sharedAuthInfoPath = [groupURL URLByAppendingPathComponent:@"shared-auth-info" isDirectory:true];
        return sharedAuthInfoPath;
    }

    return nil;
}

static void TGShareLoggingFunction(NSString *format, va_list args)
{
    NSLogv(format, args);
}

+ (NSData *)dataWithHexString:(NSString *)hex
{
    char buf[3];
    buf[2] = '\0';
    NSAssert(0 == [hex length] % 2, @"Hex strings should have an even number of digits (%@)", hex);
    uint8_t *bytes = (uint8_t *)malloc(hex.length / 2);
    uint8_t *bp = bytes;
    for (CFIndex i = 0; i < [hex length]; i += 2) {
        buf[0] = [hex characterAtIndex:i];
        buf[1] = [hex characterAtIndex:i+1];
        char *b2 = NULL;
        *bp++ = strtol(buf, &b2, 16);
        NSAssert(b2 == buf + 2, @"String should be all hex digits: %@ (bad digit around %d)", hex, i);
    }
    
    return [NSData dataWithBytesNoCopy:bytes length:[hex length]/2 freeWhenDone:YES];
}

+ (SSignal *)shareContext
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MTLogSetLoggingFunction(&TGShareLoggingFunction);
    });
    
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        NSData *sharedAuthInfoData = [NSData dataWithContentsOfURL:[self sharedAuthInfoPath]];
        if (sharedAuthInfoData == nil)
            [subscriber putError:nil];
        else
        {
            void (^proceedWithAuthInfo)(NSDictionary *) = ^(NSDictionary *authInfo)
            {
                if (authInfo == nil)
                    [subscriber putError:nil];
                else
                {
                    NSNumber *nDatacenterId = authInfo[@"datacenterId"];
                    MTDatacenterAuthInfo *datacenterAuthInfo = authInfo[@"authInfo"];
                    NSDictionary *datacenterAddressSets = authInfo[@"addressSets"];
                    int32_t clientUserId = (int32_t)[authInfo[@"clientUserId"] integerValue];
                    bool isTestingEnvironment = [authInfo[@"isTesting"] boolValue];
                    
                    if (nDatacenterId != nil && datacenterAuthInfo != nil)
                    {
                        NSString *documentsPath = [[[self groupUrl] path] stringByAppendingPathComponent:@"Documents"];
                        NSString *databaseName = @"tgdata";
                        
                        NSString *baseDatabasePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", (databaseName == nil ? @"tgdata" : databaseName)]];
                        
                        NSString *encryptedDatabasePath = [baseDatabasePath stringByAppendingString:@".y"];
                        
                        NSString *databasePath = nil;
                        
                        if ([[NSFileManager defaultManager] fileExistsAtPath:encryptedDatabasePath]) {
                            databasePath = encryptedDatabasePath;
                        } else {
                            databasePath = baseDatabasePath;
                        }
                        
                        TGLegacyDatabase *database = [[TGLegacyDatabase alloc] initWithPath:databasePath];
                        
                        MTApiEnvironment *apiEnvironment = [[MTApiEnvironment alloc] init];
                        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
                        
                        NSString *localizationPath = [[[self groupUrl] path] stringByAppendingPathComponent:@"Documents/localization"];
                        TGLocalization *localization = nil;
                        NSData *data = [NSData dataWithContentsOfFile:localizationPath];
                        if (data != nil) {
                            localization = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                        }
                        if (localization == nil) {
                            localization = [[TGLocalization alloc] initWithVersion:0 code:@"en" dict:@{} isActive:true];
                        }
                        [apiEnvironment setLangPack:@""];
                        apiEnvironment = [apiEnvironment withUpdatedLangPackCode:@""];
                        
                        NSData *socksProxyData = [database customPropertySync:@"socksProxyData"];
                        if (socksProxyData != nil) {
                            NSDictionary *socksProxyDict = [NSKeyedUnarchiver unarchiveObjectWithData:socksProxyData];
                            if (socksProxyDict[@"ip"] != nil && socksProxyDict[@"port"] != nil && ![socksProxyDict[@"inactive"] boolValue]) {
                                NSData *secret = [socksProxyDict[@"secret"] length] > 0 && [socksProxyDict[@"secret"] length] % 2 == 0 ? [TGShareContextSignal dataWithHexString:socksProxyDict[@"secret"]] : nil;
                                apiEnvironment = [apiEnvironment withUpdatedSocksProxySettings:[[MTSocksProxySettings alloc] initWithIp:socksProxyDict[@"ip"] port:(uint16_t)[socksProxyDict[@"port"] intValue] username:socksProxyDict[@"username"] password:socksProxyDict[@"password"] secret:secret]];
                            }
                        }
                        
                        NSData *networkSettingsData = [database customPropertySync:@"networkSettingsData"];
                        TGNetworkSettings *networkSettings = nil;
                        if (networkSettingsData != nil) {
                            networkSettings = [NSKeyedUnarchiver unarchiveObjectWithData:networkSettingsData];
                        }
                        if (networkSettings == nil) {
                            TGLegacyUser *user = [database userWithIdSync:clientUserId];
                            NSString *phoneNumber = @"";
                            if (user != nil) {
                                phoneNumber = [TGLegacyDatabase cleanPhone:user.phoneNumber clip:false];
                            }
                            if ([phoneNumber hasPrefix:@"7"]) {
                                networkSettings = [[TGNetworkSettings alloc] initWithReducedBackupDiscoveryTimeout:true];
                            }
                        }
                        if (networkSettings != nil) {
                            apiEnvironment = [apiEnvironment withUpdatedNetworkSettings:[[MTNetworkSettings alloc] initWithReducedBackupDiscoveryTimeout:networkSettings.reducedBackupDiscoveryTimeout]];
                        }
                        
                        int32_t apiId = 0;
                        SETUP_API_ID(apiId)
                        
                        if ([bundleIdentifier hasPrefix:@"org.telegram.TelegramEnterprise"])
                            apiEnvironment.apiId = 16352;
                        else if ([bundleIdentifier hasPrefix:@"co.one.Teleapp"]) {
                            apiEnvironment.apiId = 200440;
                        }
                        else
                            apiEnvironment.apiId = 1;
                        
                        apiEnvironment.apiId = apiId;
                        
                        id<MTSerialization> serialization = [[TGShareMtSerialization alloc] init];
                        
                        apiEnvironment.layer = @([serialization currentLayer]);
                        
                        apiEnvironment.disableUpdates = true;
                        
                        if (authInfo[@"version"] != nil)
                            apiEnvironment.appVersion = authInfo[@"version"];
                        
                        MTContext *mtContext = [[MTContext alloc] initWithSerialization:serialization apiEnvironment:apiEnvironment isTestingEnvironment:isTestingEnvironment useTempAuthKeys:false];
                        
                        MTFileBasedKeychain *keychain = [MTFileBasedKeychain keychainWithName:@"Share" documentsPath:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0]];
                        
                        [mtContext performBatchUpdates:^
                        {
                            if (isTestingEnvironment)
                            {
                                [mtContext updateAddressSetForDatacenterWithId:1 addressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                                                                                                                                                 [[MTDatacenterAddress alloc] initWithIp:@"149.154.175.10" port:443 preferForMedia:false restrictToTcp:false cdn:false preferForProxy:false secret:nil]
                                                                                                                                                 ]] forceUpdateSchemes:true];
                                [mtContext updateAddressSetForDatacenterWithId:2 addressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                                                                                                                                                 [[MTDatacenterAddress alloc] initWithIp:@"149.154.167.40" port:443 preferForMedia:false restrictToTcp:false cdn:false preferForProxy:false secret:nil]
                                                                                                                                                 ]] forceUpdateSchemes:true];
                            }
                            else
                            {
                                [mtContext setSeedAddressSetForDatacenterWithId:1 seedAddressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                                                                                                                                                       [[MTDatacenterAddress alloc] initWithIp:@"149.154.175.50" port:443 preferForMedia:false restrictToTcp:false cdn:false preferForProxy:false secret:nil]
                                ]]];

                                [mtContext setSeedAddressSetForDatacenterWithId:2 seedAddressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                                    [[MTDatacenterAddress alloc] initWithIp:@"149.154.167.51" port:443 preferForMedia:false restrictToTcp:false cdn:false preferForProxy:false secret:nil]
                                ]]];

                                [mtContext setSeedAddressSetForDatacenterWithId:3 seedAddressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                                    [[MTDatacenterAddress alloc] initWithIp:@"149.154.175.100" port:443 preferForMedia:false restrictToTcp:false cdn:false preferForProxy:false secret:nil]
                                ]]];

                                [mtContext setSeedAddressSetForDatacenterWithId:4 seedAddressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                                    [[MTDatacenterAddress alloc] initWithIp:@"149.154.167.91" port:443 preferForMedia:false restrictToTcp:false cdn:false preferForProxy:false secret:nil]
                                ]]];

                                [mtContext setSeedAddressSetForDatacenterWithId:5 seedAddressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                                    [[MTDatacenterAddress alloc] initWithIp:@"149.154.171.5" port:443 preferForMedia:false restrictToTcp:false cdn:false preferForProxy:false secret:nil]
                                ]]];
                            }
                        }];
                        
                        NSDictionary *currentAddressSetById = [keychain objectForKey:@"datacenterAddressSetById" group:@"persistent"];
                        NSDictionary *currentAuthInfoById = [keychain objectForKey:@"datacenterAuthInfoById" group:@"persistent"];
                        
                        MTDatacenterAddressSet *currentAddressSet = currentAddressSetById[nDatacenterId];
                        MTDatacenterAuthInfo *currentAuthInfo = currentAuthInfoById[nDatacenterId];
                        if (currentAuthInfo.authKey == nil || ![currentAuthInfo.authKey isEqualToData:datacenterAuthInfo.authKey] || currentAddressSet == nil || (datacenterAddressSets[nDatacenterId] != nil && ![currentAddressSet isEqual:datacenterAddressSets[nDatacenterId]]))
                        {
                            [keychain dropGroup:@"persistent"];
                            [keychain dropGroup:@"temp"];
                        }
                        
                        mtContext.keychain = keychain;
                        
                        [mtContext performBatchUpdates:^
                        {
                            if ([mtContext authInfoForDatacenterWithId:[nDatacenterId integerValue]] == nil)
                                [mtContext updateAuthInfoForDatacenterWithId:[nDatacenterId integerValue] authInfo:datacenterAuthInfo];
                            
                            [datacenterAddressSets enumerateKeysAndObjectsUsingBlock:^(NSNumber *nDatacenterId, MTDatacenterAddressSet *addressSet, BOOL * _Nonnull stop)
                            {
                                [mtContext updateAddressSetForDatacenterWithId:[nDatacenterId integerValue] addressSet:addressSet forceUpdateSchemes:true];
                            }];
                        }];
                        
                        MTSignal *discoverBackupAddressList = [[MTSignal alloc] initWithGenerator:^id<MTDisposable>(MTSubscriber *subscriber) {
                            TGLegacyUser *user = [database userWithIdSync:clientUserId];
                            NSString *phoneNumber = @"";
                            if (user != nil) {
                                phoneNumber = [TGLegacyDatabase cleanPhone:user.phoneNumber clip:false];
                            }
                            id<MTDisposable> disposable = [[MTBackupAddressSignals fetchBackupIps:isTestingEnvironment currentContext:mtContext additionalSource:nil
//                            [[MTSignal alloc] initWithGenerator:^id<MTDisposable>(MTSubscriber *internalSubscriber) {
//                                TGLegacyUser *user = [database userWithIdSync:clientUserId];
//                                NSString *prefix = @"0";
//                                if (user != nil) {
//                                    NSString *phone = [TGLegacyDatabase cleanPhone:user.phoneNumber clip:false];
//                                    if (phone.length > 0) {
//                                        prefix = [phone substringToIndex:1];
//                                    }
//                                }
//                                id<SDisposable> disposable = [[TGICloudEmergencyDataSignals fetchBackupAddressInfo:prefix phoneNumber:phoneNumber] startWithNext:^(MTBackupDatacenterData *result) {
//                                    [internalSubscriber putNext:result];
//                                    [internalSubscriber putCompletion];
//                                }];
//                                return [[MTBlockDisposable alloc] initWithBlock:^{
//                                    [disposable dispose];
//                                }];
//                            }]
                            phoneNumber:phoneNumber] startWithNext:nil error:^(__unused id error) {
                                [subscriber putCompletion];
                            } completed:^{
                                [subscriber putCompletion];
                            }];
                            return [[MTBlockDisposable alloc] initWithBlock:^{
                                [disposable dispose];
                            }];
                        }];
                        [mtContext setDiscoverBackupAddressListSignal:discoverBackupAddressList];
                        
                        MTProto *mtProto = [[MTProto alloc] initWithContext:mtContext datacenterId:[nDatacenterId integerValue] usageCalculationInfo:nil];
                        
                        MTRequestMessageService *mtRequestService = [[MTRequestMessageService alloc] initWithContext:mtContext];
                        [mtProto addMessageService:mtRequestService];
                        
                        [subscriber putNext:[[TGShareContext alloc] initWithContainerUrl:[self groupUrl] mtContext:mtContext mtProto:mtProto mtRequestService:mtRequestService clientUserId:clientUserId legacyDatabase:database]];
                        [subscriber putCompletion];
                    }
                    else
                        [subscriber putError:nil];
                }
            };
            
            NSDictionary *containerDict = [NSKeyedUnarchiver unarchiveObjectWithData:sharedAuthInfoData];
            if (containerDict == nil || containerDict[@"data"] == nil)
                [subscriber putError:nil];
            else
            {
                if ([containerDict[@"protected"] boolValue])
                {
                    NSString *password = containerDict[@"password"];
                    bool allowTouchId = [containerDict[@"touchId"] boolValue];
                    if (password == nil)
                    {
                        NSData *iv = containerDict[@"iv"];
                        if (iv.length != 32)
                            [subscriber putError:nil];
                        else
                        {
                            [subscriber putNext:[[TGEncryptedShareContext alloc] initWithSimplePassword:false allowTouchId:allowTouchId verifyPassword:^bool(NSString *passwordCandidate)
                            {
                                NSData *passwordData = [passwordCandidate dataUsingEncoding:NSUTF8StringEncoding];
                                NSData *salt = containerDict[@"salt"];
                                
                                NSMutableData *key = [[NSMutableData alloc] initWithBytesNoCopy:malloc(32) length:32 freeWhenDone:true];
                                
                                int result = CCKeyDerivationPBKDF(kCCPBKDF2, passwordData.bytes, passwordData.length, salt.bytes, salt.length, kCCPRFHmacAlgSHA256, 1000, key.mutableBytes, 32);
                                if (result != kCCSuccess)
                                    return false;
                                
                                NSData *data = MTAesDecrypt(containerDict[@"data"], key, iv);
                                if (data.length < 8)
                                    return false;
                                int32_t length = 0;
                                [data getBytes:&length length:4];
                                if (length < 0 || length > data.length - 4)
                                    return false;
                                
                                NSData *plaintextData = [data subdataWithRange:NSMakeRange(4, length)];
                                NSData *checksum = MTSha1(plaintextData);
                                if (![checksum isEqualToData:containerDict[@"checksum"]])
                                    return false;
                                
                                proceedWithAuthInfo([NSKeyedUnarchiver unarchiveObjectWithData:plaintextData]);
                                
                                return true;
                            }]];
                        }
                    }
                    else
                    {
                        [subscriber putNext:[[TGEncryptedShareContext alloc] initWithSimplePassword:true allowTouchId:allowTouchId verifyPassword:^bool(NSString *passwordCandidate)
                        {
                            if ([password isEqualToString:passwordCandidate])
                            {
                                proceedWithAuthInfo([NSKeyedUnarchiver unarchiveObjectWithData:containerDict[@"data"]]);
                                return true;
                            }
                            
                            return false;
                        }]];
                    }
                }
                else
                    proceedWithAuthInfo([NSKeyedUnarchiver unarchiveObjectWithData:containerDict[@"data"]]);
            }
        }
        return nil;
    }];
}

@end
