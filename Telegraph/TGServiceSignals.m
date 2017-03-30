#import "TGServiceSignals.h"

#import "TL/TLMetaScheme.h"
#import "TGTelegramNetworking.h"
#import "TGPeerIdAdapter.h"
#import "TGTelegraph.h"

#import "TGMessage+Telegraph.h"

@implementation TGServiceSignals

+ (SSignal *)appChangelogMessages:(NSString *)previousVersion {
    TLRPChelp_getAppChangelog$help_getAppChangelog *getAppChangelog = [[TLRPChelp_getAppChangelog$help_getAppChangelog alloc] init];
    /*NSString *versionString = [[NSString alloc] initWithFormat:@"%@ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    getAppChangelog.app_version = versionString;
    getAppChangelog.lang_code = [[NSLocale preferredLanguages] objectAtIndex:0];*/
    getAppChangelog.prev_app_version = previousVersion;
    
    return [[[TGTelegramNetworking instance] requestSignal:getAppChangelog] map:^id(TLUpdates *result) {
        if ([result isKindOfClass:[TLUpdates$updates class]]) {
            return ((TLUpdates$updates *)result).updates;
        } else if ([result isKindOfClass:[TLUpdates$updateShort class]]) {
            return @[((TLUpdates$updateShort *)result).update];
        } else {
            return nil;
        }
    }];
}

+ (SSignal *)reportSpam:(int64_t)peerId accessHash:(int64_t)accessHash {
    if (TGPeerIdIsSecretChat(peerId)) {
        return [[TGDatabaseInstance() modify:^id{
            TLRPCmessages_reportEncryptedSpam$messages_reportEncryptedSpam *reportEncryptedSpam = [[TLRPCmessages_reportEncryptedSpam$messages_reportEncryptedSpam alloc] init];
            TLInputEncryptedChat$inputEncryptedChat *inputChat = [[TLInputEncryptedChat$inputEncryptedChat alloc] init];
            TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:peerId];
            inputChat.chat_id = (int32_t)conversation.encryptedData.encryptedConversationId;
            inputChat.access_hash = conversation.encryptedData.accessHash;
            reportEncryptedSpam.peer = inputChat;
            
            TLRPCcontacts_block$contacts_block *block = [[TLRPCcontacts_block$contacts_block alloc] init];
            TGUser *user = [TGDatabaseInstance() loadUser:[TGDatabaseInstance() encryptedParticipantIdForConversationId:peerId]];
            TLInputUser$inputUser *inputUser = [[TLInputUser$inputUser alloc] init];
            inputUser.user_id = user.uid;
            inputUser.access_hash = user.phoneNumberHash;
            block.n_id = inputUser;
            
            return [SSignal mergeSignals:@[[[TGTelegramNetworking instance] requestSignal:reportEncryptedSpam], [[TGTelegramNetworking instance] requestSignal:block]]];
        }] switchToLatest];
    } else {
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
}

@end
