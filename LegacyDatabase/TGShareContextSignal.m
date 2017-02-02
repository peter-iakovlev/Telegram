#import "TGShareContextSignal.h"

#import "TGShareMtSerialization.h"

#import <MTProtoKitDynamic/MTProtoKitDynamic.h>

#import <CommonCrypto/CommonKeyDerivation.h>
#import <CommonCrypto/CommonCryptoError.h>

#import "../../config.h"

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
                    int32_t clientUserId = (int32_t)[authInfo[@"clientUserId"] integerValue];
                    
                    if (nDatacenterId != nil && datacenterAuthInfo != nil)
                    {
                        MTApiEnvironment *apiEnvironment = [[MTApiEnvironment alloc] init];
                        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
                        
                        int32_t apiId = 0;
                        SETUP_API_ID(apiId)
                        
                        if ([bundleIdentifier isEqualToString:@"org.telegram.TelegramEnterprise"])
                            apiEnvironment.apiId = 16352;
                        else
                            apiEnvironment.apiId = 1;
                        
                        apiEnvironment.apiId = apiId;
                        
                        id<MTSerialization> serialization = [[TGShareMtSerialization alloc] init];
                        
                        apiEnvironment.layer = @([serialization currentLayer]);
                        
                        apiEnvironment.disableUpdates = true;
                        
                        if (authInfo[@"version"] != nil)
                            apiEnvironment.appVersion = authInfo[@"version"];
                        
                        MTContext *mtContext = [[MTContext alloc] initWithSerialization:serialization apiEnvironment:apiEnvironment];
                        
                        MTFileBasedKeychain *keychain = [MTFileBasedKeychain keychainWithName:@"Share" documentsPath:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0]];
                        
                        [mtContext performBatchUpdates:^
                        {
                            [mtContext setSeedAddressSetForDatacenterWithId:1 seedAddressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                                [[MTDatacenterAddress alloc] initWithIp:@"149.154.175.50" port:443 preferForMedia:false restrictToTcp:false]
                            ]]];

                            [mtContext setSeedAddressSetForDatacenterWithId:2 seedAddressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                                [[MTDatacenterAddress alloc] initWithIp:@"149.154.167.51" port:443 preferForMedia:false restrictToTcp:false]
                            ]]];

                            [mtContext setSeedAddressSetForDatacenterWithId:3 seedAddressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                                [[MTDatacenterAddress alloc] initWithIp:@"149.154.175.100" port:443 preferForMedia:false restrictToTcp:false]
                            ]]];

                            [mtContext setSeedAddressSetForDatacenterWithId:4 seedAddressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                                [[MTDatacenterAddress alloc] initWithIp:@"149.154.167.91" port:443 preferForMedia:false restrictToTcp:false]
                            ]]];

                            [mtContext setSeedAddressSetForDatacenterWithId:5 seedAddressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                                [[MTDatacenterAddress alloc] initWithIp:@"149.154.171.5" port:443 preferForMedia:false restrictToTcp:false]
                            ]]];
                        }];
                        
                        NSDictionary *currentAuthInfoById = [keychain objectForKey:@"datacenterAuthInfoById" group:@"persistent"];
                        MTDatacenterAuthInfo *currentAuthInfo = currentAuthInfoById[nDatacenterId];
                        if (currentAuthInfo.authKey == nil || ![currentAuthInfo.authKey isEqualToData:datacenterAuthInfo.authKey])
                        {
                            [keychain dropGroup:@"persistent"];
                            [keychain dropGroup:@"temp"];
                        }
                        
                        mtContext.keychain = keychain;
                        
                        [mtContext performBatchUpdates:^
                        {
                            if ([mtContext authInfoForDatacenterWithId:[nDatacenterId integerValue]] == nil)
                            {
                                [mtContext updateAuthInfoForDatacenterWithId:[nDatacenterId integerValue] authInfo:datacenterAuthInfo];
                            }
                        }];
                        
                        MTProto *mtProto = [[MTProto alloc] initWithContext:mtContext datacenterId:[nDatacenterId integerValue] usageCalculationInfo:nil];
                        
                        MTRequestMessageService *mtRequestService = [[MTRequestMessageService alloc] initWithContext:mtContext];
                        [mtProto addMessageService:mtRequestService];
                        
                        [subscriber putNext:[[TGShareContext alloc] initWithContainerUrl:[self groupUrl] mtContext:mtContext mtProto:mtProto mtRequestService:mtRequestService clientUserId:clientUserId]];
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
