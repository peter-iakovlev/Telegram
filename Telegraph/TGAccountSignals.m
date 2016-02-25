#import "TGAccountSignals.h"

#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"

#import <MTProtoKit/MTContext.h>
#import <MTProtoKit/MTProto.h>

#import "TGTelegraph.h"

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

+ (SSignal *)termsOfService {
    TLRPChelp_getTermsOfService$help_getTermsOfService *getTermsOfService = [[TLRPChelp_getTermsOfService$help_getTermsOfService alloc] init];
    getTermsOfService.lang_code = [[NSLocale preferredLanguages] objectAtIndex:0];
    return [[[TGTelegramNetworking instance] requestSignal:getTermsOfService] map:^id(TLhelp_TermsOfService *termsOfService) {
        return termsOfService.text;
    }];
}

@end
