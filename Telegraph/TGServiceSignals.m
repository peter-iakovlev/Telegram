#import "TGServiceSignals.h"

#import "TL/TLMetaScheme.h"
#import "TGTelegramNetworking.h"
#import "TGPeerIdAdapter.h"
#import "TGTelegraph.h"

@implementation TGServiceSignals

+ (SSignal *)appChangelog {
    TLRPChelp_getAppChangelog$help_getAppChangelog *getAppChangelog = [[TLRPChelp_getAppChangelog$help_getAppChangelog alloc] init];
    getAppChangelog.device_model = [TGTelegraphInstance currentDeviceModel];
    getAppChangelog.system_version = [[UIDevice currentDevice] systemVersion];
    NSString *versionString = [[NSString alloc] initWithFormat:@"%@ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    getAppChangelog.app_version = versionString;
    getAppChangelog.lang_code = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    return [[[TGTelegramNetworking instance] requestSignal:getAppChangelog] map:^id(TLhelp_AppChangelog *result) {
        if ([result isKindOfClass:[TLhelp_AppChangelog$help_appChangelog class]]) {
            return ((TLhelp_AppChangelog$help_appChangelog *)result).text;
        } else {
            return nil;
        }
    }];
}

+ (SSignal *)reportSpam:(int64_t)peerId accessHash:(int64_t)accessHash {
    TLInputPeer *inputPeer = nil;
    
    TLInputPeer$inputPeerUser *inputPeerUser = [[TLInputPeer$inputPeerUser alloc] init];
    inputPeerUser.user_id = (int32_t)peerId;
    inputPeerUser.access_hash = accessHash;
    inputPeer = inputPeerUser;
    
    if (inputPeer == nil) {
        return [SSignal complete];
    }
    
    TLRPCmessages_reportSpam$messages_reportSpam *reportSpam = [[TLRPCmessages_reportSpam$messages_reportSpam alloc] init];
    reportSpam.peer = inputPeer;
    
    TLRPCcontacts_block$contacts_block *block = [[TLRPCcontacts_block$contacts_block alloc] init];
    TLInputUser$inputUser *inputUser = [[TLInputUser$inputUser alloc] init];
    inputUser.user_id = (int32_t)peerId;
    inputUser.access_hash = accessHash;
    block.n_id = inputUser;
    
    return [SSignal mergeSignals:@[[[TGTelegramNetworking instance] requestSignal:reportSpam], [[TGTelegramNetworking instance] requestSignal:block]]];
}

@end
