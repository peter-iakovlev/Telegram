#import "TGAccountSignals.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"

#import <MTProtoKit/MTContext.h>
#import <MTProtoKit/MTProtoKit.h>
#import <MTProtoKit/MTEncryption.h>

#import "TGTelegraph.h"

#import "TLaccount_updateProfile$updateProfile.h"

#import "TLRPCaccount_sendConfirmPhoneCode.h"

#import "TLauth_SentCode$auth_sentCode.h"

#import "TGTLSerialization.h"
#import "TLDcOption$modernDcOption.h"

#import "TLRPCmessages_report.h"
#import "TLRPChelp_getTermsOfServiceUpdate.h"
#import "TLRPChelp_acceptTermsOfService.h"

#import "TGTermsOfService.h"

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

+ (SSignal *)deleteAccount:(NSString *)reason
{
    TLRPCaccount_deleteAccount$account_deleteAccount *deleteAccount = [[TLRPCaccount_deleteAccount$account_deleteAccount alloc] init];
    deleteAccount.reason = reason;
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
        case TGReportPeerReasonCopyright:
            reportPeer.reason = [[TLReportReason$inputReportReasonCopyright alloc] init];
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

+ (SSignal *)termsOfServiceUpdate {
    TLRPChelp_getTermsOfServiceUpdate *getTermsOfServiceUpdate = [[TLRPChelp_getTermsOfServiceUpdate alloc] init];
    return [[[TGTelegramNetworking instance] requestSignal:getTermsOfServiceUpdate] mapToSignal:^id(TLhelp_TermsOfServiceUpdate *update)
    {
        SSignal *result = [SSignal single:nil];
        if ([update isKindOfClass:[TLhelp_TermsOfServiceUpdate$help_termsOfServiceUpdate class]])
        {
            TLhelp_TermsOfServiceUpdate$help_termsOfServiceUpdate *termsUpdate = (TLhelp_TermsOfServiceUpdate$help_termsOfServiceUpdate *)update;
            if (termsUpdate.terms_of_service != nil)
                result = [SSignal single:[[TGTermsOfService alloc] initWithTL:termsUpdate.terms_of_service]];
        }
        
        NSTimeInterval timeout = update.expires - [[TGTelegramNetworking instance] approximateRemoteTime];
        if (timeout < 0)
            timeout = 60.0 * 60.0;
        
        return [result then:[[SSignal defer:^SSignal *
        {
            return [self termsOfServiceUpdate];
        }] delay:timeout onQueue:[SQueue concurrentDefaultQueue]]];
    }];
}

+ (SSignal *)acceptTermsOfService:(NSString *)identifier {
    TLRPChelp_acceptTermsOfService *acceptTermsOfService = [[TLRPChelp_acceptTermsOfService alloc] init];
    TLDataJSON$dataJSON *n_id = [[TLDataJSON$dataJSON alloc] init];
    n_id.data = identifier;
    acceptTermsOfService.n_id = n_id;
    return [[[TGTelegramNetworking instance] requestSignal:acceptTermsOfService] mapToSignal:^SSignal *(__unused id next) {
        return [SSignal complete];
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
#ifdef DEBUG
    registerDevice.app_sandbox = true;
#else
    registerDevice.app_sandbox = false;
#endif
    return [[TGTelegramNetworking instance] requestSignal:registerDevice];
}

+ (SSignal *)unregisterDeviceToken:(NSString *)deviceToken voip:(bool)voip {
    TLRPCaccount_unregisterDevice$account_unregisterDevice *unregisterDevice = [[TLRPCaccount_unregisterDevice$account_unregisterDevice alloc] init];
    unregisterDevice.token_type = voip ? 9 : 1;
    unregisterDevice.token = deviceToken;
    return [[TGTelegramNetworking instance] requestSignal:unregisterDevice];
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

+ (SSignal *)currentContactsJoinedNotificationSettings {
    return [[TGDatabaseInstance() modify:^id{
        NSString *key = @"contactsJoinedNotifications";
        NSData *data = [TGDatabaseInstance() customProperty:key];
        int32_t value = 1;
        if (data.length != 0) {
            [data getBytes:&value length:4];
        }
        SSignal *remote = [SSignal complete];
        return [[SSignal single:@(value != 0)] then:remote];
    }] switchToLatest];
}

+ (SSignal *)updateContactsJoinedNotificationSettings:(bool)enabled {
    return [[TGDatabaseInstance() modify:^id{
        NSString *key = @"contactsJoinedNotifications";
        int32_t value = enabled ? 1 : 0;
        [TGDatabaseInstance() setCustomProperty:key value:[NSData dataWithBytes:&value length:4]];
        SSignal *remote = [SSignal complete];
        return remote;
    }] switchToLatest];
}

+ (SSignal *)reportMessages:(int64_t)peerId accessHash:(int64_t)accessHash messageIds:(NSArray *)messageIds reason:(TGReportPeerReason)reason otherText:(NSString *)otherText {
    TLRPCmessages_report *report = [[TLRPCmessages_report alloc] init];
    report.peer = [TGTelegraphInstance createInputPeerForConversation:peerId accessHash:accessHash];
    report.n_id = messageIds;
    switch (reason) {
        case TGReportPeerReasonSpam:
            report.reason = [[TLReportReason$inputReportReasonSpam alloc] init];
            break;
        case TGReportPeerReasonViolence:
            report.reason = [[TLReportReason$inputReportReasonViolence alloc] init];
            break;
        case TGReportPeerReasonPornography:
            report.reason = [[TLReportReason$inputReportReasonPornography alloc] init];
            break;
        case TGReportPeerReasonCopyright:
            report.reason = [[TLReportReason$inputReportReasonCopyright alloc] init];
            break;
        case TGReportPeerReasonOther:
            report.reason = [[TLReportReason$inputReportReasonOther alloc] init];
            ((TLReportReason$inputReportReasonOther *)report.reason).text = otherText;
            break;
    }
    
    return [[[TGTelegramNetworking instance] requestSignal:report] mapToSignal:^SSignal *(__unused id next) {
        return [SSignal complete];
    }];
}

@end
