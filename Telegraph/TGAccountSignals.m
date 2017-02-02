#import "TGAccountSignals.h"

#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"

#import <MTProtoKit/MTContext.h>
#import <MTProtoKit/MTProto.h>

#import "TGTelegraph.h"

#import "TLaccount_updateProfile$updateProfile.h"

#import "TLRPCaccount_sendConfirmPhoneCode.h"

#import "TLauth_SentCode$auth_sentCode.h"

#import "TGPeerIdAdapter.h"

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
                    return [[TGCachedUserData alloc] initWithAbout:about groupsInCommonCount:0 groupsInCommon:nil supportsCalls:false];
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

@end
