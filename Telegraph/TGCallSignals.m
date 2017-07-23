#import "TGCallSignals.h"

#import "TGDatabase.h"
#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"
#import "TGTelegraph.h"

#import "TGRequestEncryptedChatActor.h"

#import <MTProtoKit/MTProtoKit.h>

#import "TGAppDelegate.h"
#import "TGUploadFileSignals.h"
#import "TGSendMessageSignals.h"
#import "TLInputMediaUploadedDocument.h"

#import "TGCallContext.h"

const int32_t TGCallMinLayer = 65;
const int32_t TGCallMaxLayer = 66;

@implementation TGCallSignals

+ (SSignal *)encryptionConfig {
    return [SSignal defer:^SSignal *{
        TLmessages_DhConfig$messages_dhConfig *config = [TGRequestEncryptedChatActor cachedEncryptionConfig];
        if (config != nil) {
            return [SSignal single:config];
        } else {
            TLRPCmessages_getDhConfig$messages_getDhConfig *getDhConfig = [[TLRPCmessages_getDhConfig$messages_getDhConfig alloc] init];
            getDhConfig.version = 0;
            getDhConfig.random_length = 256;
            
            return [[[TGTelegramNetworking instance] requestSignal:getDhConfig] mapToSignal:^SSignal *(TLmessages_DhConfig *config) {
                if ([config isKindOfClass:[TLmessages_DhConfig$messages_dhConfig class]])
                {
                    TLmessages_DhConfig$messages_dhConfig *concreteConfig = (TLmessages_DhConfig$messages_dhConfig *)config;
                    
                    if (!MTCheckIsSafeG(concreteConfig.g)) {
                        return [SSignal fail:nil];
                    }
                    
                    if (!MTCheckMod(concreteConfig.p, concreteConfig.g, [MTFileBasedKeychain keychainWithName:@"legacyPrimes" documentsPath:[TGAppDelegate documentsPath]]))
                    {
                        return [SSignal fail:nil];
                    }
                    
                    if (!MTCheckIsSafePrime(concreteConfig.p, [MTFileBasedKeychain keychainWithName:@"legacyPrimes" documentsPath:[TGAppDelegate documentsPath]]))
                    {
                        return [SSignal fail:nil];
                    }
                    
                    [TGRequestEncryptedChatActor setCachedEncryptionConfig:concreteConfig];
                    return [SSignal single:concreteConfig];
                } else {
                    return [SSignal fail:nil];
                }
            }];
        }
    }];
}

+ (TLPhoneCallProtocol$phoneCallProtocol *)protocol {
    TLPhoneCallProtocol$phoneCallProtocol *phoneCallProtocol = [[TLPhoneCallProtocol$phoneCallProtocol alloc] init];
    phoneCallProtocol.flags = (1 << 0) | (1 << 1);
    phoneCallProtocol.min_layer = TGCallMinLayer;
    phoneCallProtocol.max_layer = TGCallMaxLayer;
    return phoneCallProtocol;
}

+ (SSignal *)requestedOutgoingCallWithPeerId:(int64_t)peerId {
    return [[TGDatabaseInstance() modify:^id{
        return [TGTelegraphInstance createInputUserForUid:(int32_t)peerId];
    }] mapToSignal:^SSignal *(TLInputUser *inputUser) {
        if (inputUser == nil) {
            return [SSignal fail:nil];
        }
        
        return [[self encryptionConfig] mapToSignal:^SSignal *(TLmessages_DhConfig$messages_dhConfig *config) {
            TLRPCphone_requestCall$phone_requestCall *requestCall = [[TLRPCphone_requestCall$phone_requestCall alloc] init];
            requestCall.user_id = inputUser;
            requestCall.random_id = (int32_t)arc4random();
            
            uint8_t rawABytes[256];
            __unused int result = SecRandomCopyBytes(kSecRandomDefault, 256, rawABytes);
            
            for (int i = 0; i < 256 && i < (int)config.random.length; i++)
            {
                uint8_t currentByte = ((uint8_t *)config.random.bytes)[i];
                rawABytes[i] ^= currentByte;
            }
            
            NSData *aBytes = [[NSData alloc] initWithBytes:rawABytes length:256];
            
            int32_t tmpG = config.g;
            tmpG = NSSwapInt(tmpG);
            NSData *g = [[NSData alloc] initWithBytes:&tmpG length:4];
            
            NSData *gA = MTExp(g, aBytes, config.p);
            if (!MTCheckIsSafeGAOrB(gA, config.p)) {
                return [SSignal fail:nil];
            }
            
            NSData *gAHash = MTSha256(gA);
            requestCall.g_a_hash = gAHash;
            requestCall.protocol = [self protocol];
            
            return [[[TGTelegramNetworking instance] requestSignal:requestCall continueOnServerErrors:false failOnFloodErrors:true] mapToSignal:^SSignal *(TLphone_PhoneCall *result) {
                if ([result.phone_call isKindOfClass:[TLPhoneCall$phoneCallWaitingMeta class]]) {
                    TLPhoneCall$phoneCallWaitingMeta *concreteCall = (TLPhoneCall$phoneCallWaitingMeta *)result.phone_call;
                    return [SSignal single:[[TGCallWaitingContext alloc] initWithCallId:concreteCall.n_id accessHash:concreteCall.access_hash date:concreteCall.date adminId:concreteCall.admin_id participantId:concreteCall.participant_id a:aBytes gA:gA dhConfig:config receiveDate:concreteCall.receive_date]];
                } else if ([result.phone_call isKindOfClass:[TLPhoneCall$phoneCallDiscardedMeta class]]) {
                    TLPhoneCall$phoneCallDiscardedMeta *concreteCall = (TLPhoneCall$phoneCallDiscardedMeta *)result.phone_call;
                    bool needsRating = concreteCall.flags & (1 << 2);
                    bool needsDebug = concreteCall.flags & (1 << 3);
                    TGCallDiscardedContext *callContext = [[TGCallDiscardedContext alloc] initWithCallId:concreteCall.n_id reason:[TGCallDiscardReasonAdapter reasonForTLObject:concreteCall.reason] outside:true needsRating:needsRating needsDebug:needsDebug error:nil];
                    return [SSignal single:callContext];
                } else {
                    return [SSignal fail:nil];
                }
            }];
        }];
        
    }];
}

+ (SSignal *)discardedCallWithCallId:(int64_t)callId accessHash:(int64_t)accessHash reason:(TGCallDiscardReason)reason duration:(int32_t)duration {
    TLRPCphone_discardCall$phone_discardCall *discardCall = [[TLRPCphone_discardCall$phone_discardCall alloc] init];
    TLInputPhoneCall$inputPhoneCall *inputPhoneCall = [[TLInputPhoneCall$inputPhoneCall alloc] init];
    inputPhoneCall.n_id = callId;
    inputPhoneCall.access_hash = accessHash;
    discardCall.peer = inputPhoneCall;
    discardCall.reason = [TGCallDiscardReasonAdapter TLObjectForReason:reason];
    discardCall.duration = duration;
    return [[[TGTelegramNetworking instance] requestSignal:discardCall] mapToSignal:^SSignal *(TLUpdates$updates *updates) {
        TLPhoneCall$phoneCallDiscardedMeta *concreteCall = nil;
        NSMutableArray *otherUpdates = [[NSMutableArray alloc] init];
        
        for (TLUpdate *update in updates.updates)
        {
            if ([update isKindOfClass:[TLUpdate$updatePhoneCall class]])
            {
                TLUpdate$updatePhoneCall *callUpdate = (TLUpdate$updatePhoneCall *)update;
                if ([callUpdate.phone_call isKindOfClass:[TLPhoneCall$phoneCallDiscardedMeta class]])
                    concreteCall = (TLPhoneCall$phoneCallDiscardedMeta *)callUpdate.phone_call;
            }
            else
            {
                [otherUpdates addObject:update];
            }
        }
        updates.updates = otherUpdates;
        [[TGTelegramNetworking instance] addUpdates:updates];
        
        bool needsRating = concreteCall.flags & (1 << 2);
        bool needsDebug = concreteCall.flags & (1 << 3);
        TGCallDiscardedContext *callContext = [[TGCallDiscardedContext alloc] initWithCallId:callId reason:reason outside:false needsRating:needsRating needsDebug:needsDebug error:nil];
        return [SSignal single:callContext];
    }];
}

+ (SSignal *)receivedIncomingCallWithCallId:(int64_t)callId accessHash:(int64_t)accessHash date:(int32_t)date adminId:(int32_t)adminId participantId:(int32_t)participantId gAHash:(NSData *)gAHash {
    return [[self encryptionConfig] mapToSignal:^SSignal *(TLmessages_DhConfig$messages_dhConfig *config) {
        uint8_t bBytes[256];
        __unused int result = SecRandomCopyBytes(kSecRandomDefault, 256, bBytes);
        
        for (int i = 0; i < 256 && i < (int)config.random.length; i++) {
            uint8_t currentByte = ((uint8_t *)config.random.bytes)[i];
            bBytes[i] ^= currentByte;
        }
        NSData *b = [[NSData alloc] initWithBytes:bBytes length:256];
        
        int32_t tmpG = config.g;
        tmpG = NSSwapInt(tmpG);
        NSData *g = [[NSData alloc] initWithBytes:&tmpG length:4];
        
        NSData *gB = MTExp(g, b, config.p);
        if (!MTCheckIsSafeGAOrB(gB, config.p)) {
            return [SSignal fail:nil];
        }

        TLRPCphone_receivedCall$phone_receivedCall *receivedCall = [[TLRPCphone_receivedCall$phone_receivedCall alloc] init];
        TLInputPhoneCall$inputPhoneCall *inputPhoneCall = [[TLInputPhoneCall$inputPhoneCall alloc] init];
        inputPhoneCall.n_id = callId;
        inputPhoneCall.access_hash = accessHash;
        receivedCall.peer = inputPhoneCall;

        return [[[TGTelegramNetworking instance] requestSignal:receivedCall] mapToSignal:^SSignal *(__unused id next) {
            return [SSignal single:[[TGCallReceivedContext alloc] initWithCallId:callId accessHash:accessHash date:date adminId:adminId participantId:participantId dhConfig:config b:b gB:gB gAHash:gAHash]];
        }];
    }];
}

+ (SSignal *)acceptedIncomingCallWithCallId:(int64_t)callId accessHash:(int64_t)accessHash dhConfig:(id)dhConfig bBytes:(NSData *)bBytes gBBytes:(NSData *)gBBytes gAHash:(NSData *)gAHash {
    TLRPCphone_acceptCall$phone_acceptCall *acceptCall = [[TLRPCphone_acceptCall$phone_acceptCall alloc] init];
    TLInputPhoneCall$inputPhoneCall *inputPhoneCall = [[TLInputPhoneCall$inputPhoneCall alloc] init];
    inputPhoneCall.n_id = callId;
    inputPhoneCall.access_hash = accessHash;
    acceptCall.peer = inputPhoneCall;
    acceptCall.g_b = gBBytes;
    acceptCall.protocol = [self protocol];
    
    return [[[TGTelegramNetworking instance] requestSignal:acceptCall] mapToSignal:^SSignal *(TLphone_PhoneCall *result) {
        if ([result.phone_call isKindOfClass:[TLPhoneCall$phoneCallWaitingMeta class]]) {
            TLPhoneCall$phoneCallWaitingMeta *concreteCall = (TLPhoneCall$phoneCallWaitingMeta *)result.phone_call;
            TGCallWaitingConfirmContext *callContext = [[TGCallWaitingConfirmContext alloc] initWithCallId:callId accessHash:accessHash date:concreteCall.date adminId:concreteCall.admin_id participantId:concreteCall.participant_id b:bBytes gAHash:gAHash dhConfig:dhConfig receiveDate:concreteCall.receive_date];
            return [SSignal single:callContext];
        } else if ([result.phone_call isKindOfClass:[TLPhoneCall$phoneCallDiscardedMeta class]]) {
            TLPhoneCall$phoneCallDiscardedMeta *concreteCall = (TLPhoneCall$phoneCallDiscardedMeta *)result.phone_call;
            bool needsRating = concreteCall.flags & (1 << 2);
            bool needsDebug = concreteCall.flags & (1 << 3);
            TGCallDiscardedContext *callContext = [[TGCallDiscardedContext alloc] initWithCallId:concreteCall.n_id reason:[TGCallDiscardReasonAdapter reasonForTLObject:concreteCall.reason] outside:true needsRating:needsRating needsDebug:needsDebug error:nil];
            return [SSignal single:callContext];
        } else {
            return [SSignal fail:nil];
        }
    }];
}

+ (SSignal *)confirmedCallWithCallId:(int64_t)callId accessHash:(int64_t)accessHash key:(NSData *)key gABytes:(NSData *)gABytes keyId:(int64_t)keyId {
    TLRPCphone_confirmCall$phone_confirmCall *confirmCall = [[TLRPCphone_confirmCall$phone_confirmCall alloc] init];
    TLInputPhoneCall$inputPhoneCall *inputPhoneCall = [[TLInputPhoneCall$inputPhoneCall alloc] init];
    inputPhoneCall.n_id = callId;
    inputPhoneCall.access_hash = accessHash;
    confirmCall.peer = inputPhoneCall;
    confirmCall.g_a = gABytes;
    confirmCall.key_fingerprint = keyId;
    confirmCall.protocol = [self protocol];
    
    return [[[TGTelegramNetworking instance] requestSignal:confirmCall] mapToSignal:^SSignal *(TLphone_PhoneCall *result) {
        if ([result.phone_call isKindOfClass:[TLPhoneCall$phoneCall class]]) {
            TLPhoneCall$phoneCall *concreteCall = (TLPhoneCall$phoneCall *)result.phone_call;
            
            TGCallConnectionDescription *(^deserializeConnection)(id) = ^TGCallConnectionDescription *(id connection) {
                if ([connection isKindOfClass:[TLPhoneConnection$phoneConnection class]]) {
                    TLPhoneConnection$phoneConnection *concreteConnection = (TLPhoneConnection$phoneConnection *)connection;
                    return [[TGCallConnectionDescription alloc] initWithIdentifier:concreteConnection.n_id ipv4:concreteConnection.ip ipv6:concreteConnection.ipv6 port:concreteConnection.port peerTag:concreteConnection.peer_tag];
                }
                return nil;
            };
            
            TGCallConnectionDescription *defaultConnection = deserializeConnection(concreteCall.connection);
            NSMutableArray<TGCallConnectionDescription *> *alternativeConnections = [[NSMutableArray alloc] init];
            for (id connection in concreteCall.alternative_connections) {
                TGCallConnectionDescription *callConnection = deserializeConnection(connection);
                if (callConnection != nil)
                    [alternativeConnections addObject:callConnection];
            }
            
            return [SSignal single:[[TGCallOngoingContext alloc] initWithCallId:callId accessHash:accessHash date:concreteCall.date adminId:concreteCall.admin_id participantId:concreteCall.participant_id key:key keyFingerprint:keyId defaultConnection:defaultConnection alternativeConnections:alternativeConnections]];
        }
        else if ([result.phone_call isKindOfClass:[TLPhoneCall$phoneCallDiscardedMeta class]]) {
            TLPhoneCall$phoneCallDiscardedMeta *concreteCall = (TLPhoneCall$phoneCallDiscardedMeta *)result.phone_call;
            bool needsRating = concreteCall.flags & (1 << 2);
            bool needsDebug = concreteCall.flags & (1 << 3);
            TGCallDiscardedContext *callContext = [[TGCallDiscardedContext alloc] initWithCallId:concreteCall.n_id reason:[TGCallDiscardReasonAdapter reasonForTLObject:concreteCall.reason] outside:true needsRating:needsRating needsDebug:needsDebug error:nil];
            return [SSignal single:callContext];
        } else {
            return [SSignal fail:nil];
        }
    }];
}

+ (SSignal *)_reportCallRatingWithCallId:(int64_t)callId accessHash:(int64_t)accessHash rating:(int32_t)rating comment:(NSString *)comment {
    TLRPCphone_setCallRating$phone_setCallRating *setCallRating = [[TLRPCphone_setCallRating$phone_setCallRating alloc] init];
    TLInputPhoneCall$inputPhoneCall *inputCall = [[TLInputPhoneCall$inputPhoneCall alloc] init];
    inputCall.n_id = callId;
    inputCall.access_hash = accessHash;
    setCallRating.peer = inputCall;
    setCallRating.rating = rating;
    setCallRating.comment = comment;
    return [[TGTelegramNetworking instance] requestSignal:setCallRating];
}

+ (SSignal *)reportCallRatingWithCallId:(int64_t)callId accessHash:(int64_t)accessHash rating:(int32_t)rating comment:(NSString *)comment includeLogs:(bool)includeLogs
{
    int32_t voipUid = [TGTelegraphInstance createVoipSupportUserIfNeeded];
    
    SSignal *signal = [self _reportCallRatingWithCallId:callId accessHash:accessHash rating:rating comment:nil];
    if (comment.length > 0)
        signal = [signal then:[TGSendMessageSignals sendTextMessageWithPeerId:voipUid text:comment replyToMid:0]];
    
    if (includeLogs)
    {
        NSString *logsPath = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"calls"];
        NSString *logPath = [logsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%lld-%lld.log", callId, accessHash]];
        
        SSignal *logSignal = [SSignal complete];
        
        if (logPath.length > 0)
        {
            NSData *logData = [NSData dataWithContentsOfFile:logPath];
            if (logData != nil)
            {
                SSignal *uploadSignal = [[TGUploadFileSignals uploadedFileWithData:logData mediaTypeTag:TGNetworkMediaTypeTagDocument] map:^id(TLInputFile *file)
                {
                    return @{ @"file": file };
                }];
                
                TGDocumentMediaAttachment *documentAttachment = [[TGDocumentMediaAttachment alloc] init];
                TGDocumentAttributeFilename *filename = [[TGDocumentAttributeFilename alloc] initWithFilename:[NSString stringWithFormat:@"call-%lld.log", callId]];
                documentAttachment.attributes = @[ filename ];
                documentAttachment.mimeType = @"text/plain";
                
                uploadSignal = [uploadSignal then:[TGSendMessageSignals sendMediaWithPeerId:voipUid replyToMid:0 attachment:documentAttachment uploadSignal:uploadSignal mediaProducer:^TLInputMedia *(NSDictionary *uploadInfo)
                {
                    TLInputMediaUploadedDocument *uploadedDocument = [[TLInputMediaUploadedDocument alloc] init];
                    uploadedDocument.file = uploadInfo[@"file"];
                    uploadedDocument.mime_type = @"text/plain";
                    
                    TLDocumentAttribute$documentAttributeFilename *filenameAttribute = [[TLDocumentAttribute$documentAttributeFilename alloc] init];
                    filenameAttribute.file_name = documentAttachment.fileName;
                    uploadedDocument.attributes = @[ filenameAttribute ];
                    
                    return uploadedDocument;
                }]];
                
                logSignal = uploadSignal;
            }
        }
        
        signal = [signal then:logSignal];
    }
    
    return signal;
}

+ (SSignal *)serverCallsConfig {
    return [[[TGTelegramNetworking instance] requestSignal:[[TLRPCphone_getCallConfig$phone_getCallConfig alloc] init]] map:^id(TLDataJSON *result) {
        return result.data;
    }];
}

+ (SSignal *)saveCallDebug:(int64_t)callId accessHash:(int64_t)accessHash data:(NSString *)data {
    TLRPCphone_saveCallDebug$phone_saveCallDebug *saveCallDebug = [[TLRPCphone_saveCallDebug$phone_saveCallDebug alloc] init];
    TLInputPhoneCall$inputPhoneCall *inputCall = [[TLInputPhoneCall$inputPhoneCall alloc] init];
    inputCall.n_id = callId;
    inputCall.access_hash = accessHash;
    saveCallDebug.peer = inputCall;
    TLDataJSON$dataJSON *dataJson = [[TLDataJSON$dataJSON alloc] init];
    dataJson.data = data;
    saveCallDebug.debug = dataJson;
    return [[TGTelegramNetworking instance] requestSignal:saveCallDebug];
}

@end
