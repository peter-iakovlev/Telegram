#import "TGAccountSignals.h"

#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"

#import <MTProtoKit/MTContext.h>
#import <MTProtoKit/MTProtoKit.h>
#import <MTProtoKit/MTEncryption.h>

#import "TGTelegraph.h"

#import "TLaccount_updateProfile$updateProfile.h"

#import "TLRPCaccount_sendConfirmPhoneCode.h"

#import "TLauth_SentCode$auth_sentCode.h"

#import "TGPeerIdAdapter.h"

#import "../../config.h"

#import "TGLocalization.h"
#import "TGTLSerialization.h"
#import "TLDcOption$modernDcOption.h"

@interface TGFetchHttpHelper : NSObject <TGRawHttpActor> {
    void (^_completion)(NSData *);
}

@end

@implementation TGFetchHttpHelper

- (instancetype)initWithCompletion:(void (^)(NSData *))completion {
    self = [super init];
    if (self != nil) {
        _completion = [completion copy];
    }
    return self;
}

- (void)httpRequestSuccess:(NSString *)__unused url response:(NSData *)response {
    if (_completion) {
        _completion(response);
    }
}

- (void)httpRequestFailed:(NSString *)__unused url {
    if (_completion) {
        _completion(nil);
    }
}

@end

@implementation TGAccountSignals

+ (SSignal *)deleteAccount
{
    TLRPCaccount_deleteAccount$account_deleteAccount *deleteAccount = [[TLRPCaccount_deleteAccount$account_deleteAccount alloc] init];
    deleteAccount.reason = @"Forgot password";
    return [[[TGTelegramNetworking instance] requestSignal:deleteAccount requestClass:TGRequestClassIgnorePasswordEntryRequired] mapToSignal:^SSignal *(__unused id result)
    {
        [[[TGTelegramNetworking instance] context] updatePasswordInputRequiredForDatacenterWithId:[[TGTelegramNetworking instance] mtProto].datacenterId required:false];
        
        return [SSignal complete];
    }];
}

+ (SSignal *)reportPeer:(int64_t)peerId accessHash:(int64_t)accessHash reason:(TGReportPeerReason)reason otherText:(NSString *)otherText {
    TLRPCaccount_reportPeer$account_reportPeer *reportPeer = [[TLRPCaccount_reportPeer$account_reportPeer alloc] init];
    reportPeer.peer = [TGTelegraphInstance createInputPeerForConversation:peerId accessHash:accessHash];
    switch (reason) {
        case TGReportPeerReasonSpam:
            reportPeer.reason = [[TLReportReason$inputReportReasonSpam alloc] init];
            break;
        case TGReportPeerReasonViolence:
            reportPeer.reason = [[TLReportReason$inputReportReasonViolence alloc] init];
            break;
        case TGReportPeerReasonPornography:
            reportPeer.reason = [[TLReportReason$inputReportReasonPornography alloc] init];
            break;
        case TGReportPeerReasonOther:
            reportPeer.reason = [[TLReportReason$inputReportReasonOther alloc] init];
            ((TLReportReason$inputReportReasonOther *)reportPeer.reason).text = otherText;
            break;
    }
    
    return [[[TGTelegramNetworking instance] requestSignal:reportPeer] mapToSignal:^SSignal *(__unused id next) {
        return [SSignal complete];
    }];
}

+ (SSignal *)updatedShouldReportSpamForPeer:(int64_t)peerId accessHash:(int64_t)accessHash {
    return [[[TGDatabaseInstance() cachedPeerSettings:peerId] take:1] mapToSignal:^SSignal *(TGCachedPeerSettings *settings) {
        if (settings == nil || settings.reportSpamState == TGCachedPeerReportSpamUnknown || settings.reportSpamState == TGCachedPeerReportSpamShow) {
            if (TGPeerIdIsSecretChat(peerId)) {
                return [[TGDatabaseInstance() modify:^id{
                    TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:peerId];
                    int32_t uid = [TGDatabaseInstance() encryptedParticipantIdForConversationId:peerId];
                    TGCachedPeerReportSpamState reportSpamState = TGCachedPeerReportSpamShow;
                    if (conversation.chatParticipants.chatAdminId != TGTelegraphInstance.clientUserId) {
                        if ([TGDatabaseInstance() uidIsRemoteContact:uid]) {
                            reportSpamState = TGCachedPeerReportSpamDismissed;
                        }
                    } else {
                        reportSpamState = TGCachedPeerReportSpamDismissed;
                    }
                    
                    [TGDatabaseInstance() updateCachedPeerSettings:peerId block:^TGCachedPeerSettings *(TGCachedPeerSettings *settings) {
                        if (settings == nil) {
                            return [[TGCachedPeerSettings alloc] initWithReportSpamState:reportSpamState];
                        } else {
                            return [settings updateReportSpamState:reportSpamState];
                        }
                    }];
                    
                    return [SSignal complete];
                }] switchToLatest];
            } else {
                TLRPCmessages_getPeerSettings$messages_getPeerSettings *getPeerSettings = [[TLRPCmessages_getPeerSettings$messages_getPeerSettings alloc] init];
                getPeerSettings.peer = [TGTelegraphInstance createInputPeerForConversation:peerId accessHash:accessHash];
                return [[[TGTelegramNetworking instance] requestSignal:getPeerSettings] mapToSignal:^SSignal *(TLPeerSettings *result) {
                    return [[TGDatabaseInstance() modify:^id{
                        [TGDatabaseInstance() updateCachedPeerSettings:peerId block:^TGCachedPeerSettings *(TGCachedPeerSettings *settings) {
                            TGCachedPeerReportSpamState reportSpamState = result.flags & (1 << 0) ? TGCachedPeerReportSpamShow : TGCachedPeerReportSpamDismissed;
                            if (settings == nil) {
                                return [[TGCachedPeerSettings alloc] initWithReportSpamState:reportSpamState];
                            } else {
                                return [settings updateReportSpamState:reportSpamState];
                            }
                        }];
                        
                        return [SSignal complete];
                    }] switchToLatest];
                }];
            }
        } else {
            return [SSignal complete];
        }
    }];
}

+ (SSignal *)dismissReportSpamForPeer:(int64_t)peerId accessHash:(int64_t)accessHash {
    if (TGPeerIdIsSecretChat(peerId)) {
        return [SSignal complete];
    } else {
        TLRPCmessages_hideReportSpam$messages_hideReportSpam *hideReportSpam = [[TLRPCmessages_hideReportSpam$messages_hideReportSpam alloc] init];
        hideReportSpam.peer = [TGTelegraphInstance createInputPeerForConversation:peerId accessHash:accessHash];
        return [[[TGTelegramNetworking instance] requestSignal:hideReportSpam] mapToSignal:^SSignal *(__unused id next) {
            return [SSignal complete];
        }];
    }
}

+ (SSignal *)termsOfService {
    TLRPChelp_getTermsOfService$help_getTermsOfService *getTermsOfService = [[TLRPChelp_getTermsOfService$help_getTermsOfService alloc] init];
    getTermsOfService.lang_code = [[NSLocale preferredLanguages] objectAtIndex:0];
    return [[[TGTelegramNetworking instance] requestSignal:getTermsOfService] map:^id(TLhelp_TermsOfService *termsOfService) {
        return termsOfService.text;
    }];
}

+ (SSignal *)updateAbout:(NSString *)about {
    TLaccount_updateProfile$updateProfile *updateProfile = [[TLaccount_updateProfile$updateProfile alloc] init];
    updateProfile.flags = (1 << 2);
    updateProfile.about = about;
    return [[[TGTelegramNetworking instance] requestSignal:updateProfile] mapToSignal:^SSignal *(__unused id result) {
        return [[TGDatabaseInstance() modify:^id{
            [TGDatabaseInstance() updateCachedUserData:TGTelegraphInstance.clientUserId block:^TGCachedUserData *(TGCachedUserData *data) {
                if (data == nil) {
                    return [[TGCachedUserData alloc] initWithAbout:about groupsInCommonCount:0 groupsInCommon:nil supportsCalls:false callsPrivate:false];
                } else {
                    return [data updateAbout:about];
                }
            }];
            return [SSignal complete];
        }] switchToLatest];
    }];
}

+ (SSignal *)requestConfirmationForPhoneWithHash:(NSString *)phoneHash {
    TLRPCaccount_sendConfirmPhoneCode *sendConfirmPhoneCode = [[TLRPCaccount_sendConfirmPhoneCode alloc] init];
    sendConfirmPhoneCode.n_hash = phoneHash;
    return [[[TGTelegramNetworking instance] requestSignal:sendConfirmPhoneCode continueOnServerErrors:false failOnFloodErrors:true failOnServerErrorsImmediately:true] mapToSignal:^SSignal *(TLauth_SentCode *result) {
        if ([result isKindOfClass:[TLauth_SentCode$auth_sentCode class]]) {
            TLauth_SentCode$auth_sentCode *sentCode = (TLauth_SentCode$auth_sentCode *)result;
            return [SSignal single:[[TGConfirmationCodeData alloc] initWithCodeHash:sentCode.phone_code_hash timeout:sentCode.timeout]];
        } else {
            return [SSignal fail:nil];
        }
    }];
}

+ (SSignal *)confirmPhoneWithHash:(NSString *)codeHash code:(NSString *)code {
    TLRPCaccount_confirmPhone$account_confirmPhone *confirmPhone = [[TLRPCaccount_confirmPhone$account_confirmPhone alloc] init];
    confirmPhone.phone_code_hash = codeHash;
    confirmPhone.phone_code = code;
    return [[TGTelegramNetworking instance] requestSignal:confirmPhone continueOnServerErrors:false failOnFloodErrors:true failOnServerErrorsImmediately:true];
}

+ (SSignal *)resendCodeWithHash:(NSString *)codeHash {
    TLRPCauth_resendCode$auth_resendCode *resendCode = [[TLRPCauth_resendCode$auth_resendCode alloc] init];
    resendCode.phone_number = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId].phoneNumber;
    resendCode.phone_code_hash = codeHash;
    return [[TGTelegramNetworking instance] requestSignal:resendCode continueOnServerErrors:false failOnFloodErrors:true failOnServerErrorsImmediately:true];
}

+ (SSignal *)registerDeviceToken:(NSString *)deviceToken voip:(bool)voip {
    TLRPCaccount_registerDevice$account_registerDevice *registerDevice = [[TLRPCaccount_registerDevice$account_registerDevice alloc] init];
    registerDevice.token_type = voip ? 9 : 1;
    registerDevice.token = deviceToken;
    registerDevice.device_model = TGTelegraphInstance.currentDeviceModel;
    registerDevice.system_version = [[UIDevice currentDevice] systemVersion];
    NSString *versionString = [[NSString alloc] initWithFormat:@"%@ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    registerDevice.app_version = versionString;
#ifdef DEBUG
    registerDevice.app_sandbox = true;
#else
    registerDevice.app_sandbox = false;
#endif
    registerDevice.lang_code = TGTelegraphInstance.langCode;
    return [[TGTelegramNetworking instance] requestSignal:registerDevice];
}

+ (SSignal *)unregisterDeviceToken:(NSString *)deviceToken voip:(bool)voip {
    TLRPCaccount_unregisterDevice$account_unregisterDevice *unregisterDevice = [[TLRPCaccount_unregisterDevice$account_unregisterDevice alloc] init];
    unregisterDevice.token_type = voip ? 9 : 1;
    unregisterDevice.token = deviceToken;
    return [[TGTelegramNetworking instance] requestSignal:unregisterDevice];
}

+ (SSignal *)fetchBackupIpsGoogle:(bool)isTesting {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        NSDictionary *headers = @{@"Host": @"dns-telegram.appspot.com"};
        
        TGFetchHttpHelper *helper = [[TGFetchHttpHelper alloc] initWithCompletion:^(NSData *data) {
            NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            text = [text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
            NSData *result = [[NSData alloc] initWithBase64Encoding:text];
            NSMutableData *finalData = [[NSMutableData alloc] initWithData:result];
            [finalData setLength:256];
            MTBackupDatacenterData *datacenterData = MTIPDataDecode(finalData);
            if (datacenterData != nil) {
                [subscriber putNext:datacenterData];
            }
            [subscriber putCompletion];
        }];
        
        id cancelToken = [TGTelegraphInstance doRequestRawHttp:isTesting ? @"https://google.com/test/" : @"https://google.com/" maxRetryCount:0 acceptCodes:@[@400, @403] httpHeaders:headers actor:helper];
        
        return [[SBlockDisposable alloc] initWithBlock:^{
            [helper description];
            [TGTelegraphInstance cancelRequestByToken:cancelToken];
        }];
    }];
}

+ (SSignal *)fetchBackupIpsResolveGoogle:(bool)isTesting {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        NSDictionary *headers = @{@"Host": @"dns.google.com"};
        
        TGFetchHttpHelper *helper = [[TGFetchHttpHelper alloc] initWithCompletion:^(NSData *data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([dict respondsToSelector:@selector(objectForKey:)]) {
                NSArray *answer = dict[@"Answer"];
                NSMutableArray *strings = [[NSMutableArray alloc] init];
                if ([answer respondsToSelector:@selector(objectAtIndex:)]) {
                    for (NSDictionary *value in answer) {
                        if ([value respondsToSelector:@selector(objectForKey:)]) {
                            NSString *part = value[@"data"];
                            if ([part respondsToSelector:@selector(characterAtIndex:)]) {
                                [strings addObject:part];
                            }
                        }
                    }
                    [strings sortUsingComparator:^NSComparisonResult(NSString *lhs, NSString *rhs) {
                        if (lhs.length > rhs.length) {
                            return NSOrderedAscending;
                        } else {
                            return NSOrderedDescending;
                        }
                    }];
                    
                    NSString *finalString = @"";
                    for (NSString *string in strings) {
                        finalString = [finalString stringByAppendingString:[string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]]];
                    }
                    
                    NSData *result = [[NSData alloc] initWithBase64Encoding:finalString];
                    NSMutableData *finalData = [[NSMutableData alloc] initWithData:result];
                    [finalData setLength:256];
                    MTBackupDatacenterData *datacenterData = MTIPDataDecode(finalData);
                    if (datacenterData != nil) {
                        
                        [subscriber putNext:datacenterData];
                    }
                }
            }
            [subscriber putCompletion];
        }];
        
        id cancelToken = [TGTelegraphInstance doRequestRawHttp:[NSString stringWithFormat:@"https://google.com/resolve?name=%@&type=16", isTesting ? @"tap.stel.com" : @"ap.stel.com"] maxRetryCount:0 acceptCodes:@[@400, @403] httpHeaders:headers actor:helper];
        
        return [[SBlockDisposable alloc] initWithBlock:^{
            [helper description];
            [TGTelegraphInstance cancelRequestByToken:cancelToken];
        }];
    }];
}

+ (SSignal *)fetchBackupIps:(bool)isTestingEnvironment {
    NSArray *signals = @[[self fetchBackupIpsGoogle:isTestingEnvironment], [self fetchBackupIpsResolveGoogle:isTestingEnvironment]];
    
    return [[[SSignal mergeSignals:signals] take:1] mapToSignal:^SSignal *(MTBackupDatacenterData *data) {
        if (data != nil && data.addressList.count != 0) {
            MTApiEnvironment *apiEnvironment = [[MTApiEnvironment alloc] init];
            
            NSMutableDictionary *datacenterAddressOverrides = [[NSMutableDictionary alloc] init];
            
            MTBackupDatacenterAddress *address = data.addressList[0];
            datacenterAddressOverrides[@(data.datacenterId)] = [[MTDatacenterAddress alloc] initWithIp:address.ip port:(uint16_t)address.port preferForMedia:false restrictToTcp:false cdn:false preferForProxy:false];
            apiEnvironment.datacenterAddressOverrides = datacenterAddressOverrides;
            
            int32_t apiId = 0;
            NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
            SETUP_API_ID(apiId)
            
            apiEnvironment.apiId = apiId;
            
            apiEnvironment.layer = @([[[TGTLSerialization alloc] init] currentLayer]);
            
            apiEnvironment = [apiEnvironment withUpdatedLangPackCode:currentNativeLocalization().code];

            MTContext *context = [[MTContext alloc] initWithSerialization:[[TGTLSerialization alloc] init] apiEnvironment:apiEnvironment];
            
            if (data.datacenterId != 0) {
                context.keychain = [TGTelegramNetworking instance].context.keychain;
            }
            
            MTProto *mtProto = [[MTProto alloc] initWithContext:context datacenterId:data.datacenterId usageCalculationInfo:nil];
            MTRequestMessageService *requestService = [[MTRequestMessageService alloc] initWithContext:context];
            [mtProto addMessageService:requestService];
            
            [mtProto resume];
            return [[[[self requestSignal:[[TLRPChelp_getConfig$help_getConfig alloc] init] requestService:requestService] onNext:^(TLConfig *config) {
                NSMutableDictionary *addressListByDatacenterId = [[NSMutableDictionary alloc] init];
                
                for (TLDcOption$modernDcOption *dcOption in config.dc_options)
                {
                    MTDatacenterAddress *configAddress = [[MTDatacenterAddress alloc] initWithIp:dcOption.ip_address port:(uint16_t)dcOption.port preferForMedia:dcOption.flags & (1 << 1) restrictToTcp:dcOption.flags & (1 << 2) cdn:dcOption.flags & (1 << 3) preferForProxy:dcOption.flags & (1 << 4)];
                    
                    NSMutableArray *array = addressListByDatacenterId[@(dcOption.n_id)];
                    if (array == nil)
                    {
                        array = [[NSMutableArray alloc] init];
                        addressListByDatacenterId[@(dcOption.n_id)] = array;
                    }
                    
                    if (![array containsObject:configAddress])
                        [array addObject:configAddress];
                }
                
                [addressListByDatacenterId enumerateKeysAndObjectsUsingBlock:^(NSNumber *nDatacenterId, NSArray *addressList, __unused BOOL *stop) {
                     MTDatacenterAddressSet *addressSet = [[MTDatacenterAddressSet alloc] initWithAddressList:addressList];
                     
                     MTDatacenterAddressSet *currentAddressSet = [context addressSetForDatacenterWithId:[nDatacenterId integerValue]];
                     
                     if (currentAddressSet == nil || ![addressSet isEqual:currentAddressSet])
                     {
                         TGLog(@"[Backup address fetch (%@): updating datacenter %d address set to %@]", isTestingEnvironment ? @"testing" : @"production", [nDatacenterId intValue], addressSet);
                         [[TGTelegramNetworking instance].context updateAddressSetForDatacenterWithId:[nDatacenterId integerValue] addressSet:addressSet forceUpdateSchemes:true];
                     }
                 }];
            }] onDispose:^{
                [mtProto stop];
            }] delay:2.0 onQueue:[SQueue concurrentDefaultQueue]];
        }
        return [SSignal complete];
    }];
}

+ (SSignal *)requestSignal:(TLMetaRpc *)rpc requestService:(MTRequestMessageService *)requestService
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
        
        [requestService addRequest:request];
        id requestToken = request.internalId;
        
        return [[SBlockDisposable alloc] initWithBlock:^ {
            [requestService removeRequestByInternalId:requestToken];
        }];
    }];
}

@end
