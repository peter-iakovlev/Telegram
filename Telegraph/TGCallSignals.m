#import "TGCallSignals.h"

#import "TGDatabase.h"
#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"
#import "TGTelegraph.h"

#import "TGRequestEncryptedChatActor.h"

#import <MTProtoKit/MTProtoKit.h>

#import "TGAppDelegate.h"

#import "TGCallContext.h"

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
            
            NSData *g_a = MTExp(g, aBytes, config.p);
            
            if (!MTCheckIsSafeGAOrB(g_a, config.p)) {
                return [SSignal fail:nil];
            }
            
            requestCall.g_a = g_a;
            
            TLPhoneCallProtocol$phoneCallProtocol *phoneCallProtocol = [[TLPhoneCallProtocol$phoneCallProtocol alloc] init];
            phoneCallProtocol.flags = (1 << 0) | (1 << 1);
            phoneCallProtocol.min_layer = 60;
            phoneCallProtocol.max_layer = 60;
            requestCall.protocol = phoneCallProtocol;
            
            return [[[TGTelegramNetworking instance] requestSignal:requestCall] mapToSignal:^SSignal *(TLphone_PhoneCall *result) {
                if ([result.phone_call isKindOfClass:[TLPhoneCall$phoneCallWaitingMeta class]]) {
                    TLPhoneCall$phoneCallWaitingMeta *concreteCall = (TLPhoneCall$phoneCallWaitingMeta *)result.phone_call;
                    return [SSignal single:[[TGCallWaitingContext alloc] initWithCallId:concreteCall.n_id accessHash:concreteCall.access_hash date:concreteCall.date adminId:concreteCall.admin_id participantId:concreteCall.participant_id a:aBytes dhConfig:config receiveDate:concreteCall.receive_date]];
                } else if ([result.phone_call isKindOfClass:[TLPhoneCall$phoneCall class]]) {
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
                    
                    TGCallWaitingContext *waitingContext = [[TGCallWaitingContext alloc] initWithCallId:concreteCall.n_id accessHash:concreteCall.access_hash date:concreteCall.date adminId:concreteCall.admin_id participantId:concreteCall.participant_id a:aBytes dhConfig:config receiveDate:0];
                    TGCallAcceptedContext *callContext = [[TGCallAcceptedContext alloc] initWithCallId:concreteCall.n_id accessHash:concreteCall.access_hash date:concreteCall.date adminId:concreteCall.admin_id participantId:concreteCall.participant_id gAOrB:concreteCall.g_a_or_b keyFingerprint:concreteCall.key_fingerprint defaultConnection:defaultConnection alternativeConnections:alternativeConnections];
                    return [[SSignal single:waitingContext] then:[SSignal single:callContext]];
                } else if ([result.phone_call isKindOfClass:[TLPhoneCall$phoneCallDiscardedMeta class]]) {
                    TLPhoneCall$phoneCallDiscardedMeta *concreteCall = (TLPhoneCall$phoneCallDiscardedMeta *)result.phone_call;
                    TGCallDiscardedContext *callContext = [[TGCallDiscardedContext alloc] initWithCallId:concreteCall.n_id reason:[TGCallDiscardReasonAdapter reasonForTLObject:concreteCall.reason]];
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
    return [[[TGTelegramNetworking instance] requestSignal:discardCall] mapToSignal:^SSignal *(__unused id next) {
        TGCallDiscardedContext *callContext = [[TGCallDiscardedContext alloc] initWithCallId:callId reason:reason];
        return [SSignal single:callContext];
    }];
}

+ (SSignal *)receivedIncomingCallWithCallId:(int64_t)callId accessHash:(int64_t)accessHash date:(int32_t)date adminId:(int32_t)adminId participantId:(int32_t)participantId gA:(NSData *)gA {
    return [[self encryptionConfig] mapToSignal:^SSignal *(TLmessages_DhConfig$messages_dhConfig *config) {
        if (!MTCheckIsSafeGAOrB(gA, config.p)) {
            return [SSignal fail:nil];
        }
        
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
        
        NSData *gBBytes = MTExp(g, b, config.p);
        
        NSMutableData *key = [MTExp(gA, b, config.p) mutableCopy];
        
        if (key.length > 256) {
            [key replaceBytesInRange:NSMakeRange(0, 1) withBytes:NULL length:1];
        } while (key.length < 256) {
            uint8_t zero = 0;
            [key replaceBytesInRange:NSMakeRange(0, 0) withBytes:&zero length:1];
        }
        
        NSData *keyHash = MTSha1(key);
        NSData *nKeyId = [[NSData alloc] initWithBytes:(((uint8_t *)keyHash.bytes) + keyHash.length - 8) length:8];
        int64_t keyId = 0;
        [nKeyId getBytes:&keyId length:8];
        
        TLRPCphone_receivedCall$phone_receivedCall *receivedCall = [[TLRPCphone_receivedCall$phone_receivedCall alloc] init];
        TLInputPhoneCall$inputPhoneCall *inputPhoneCall = [[TLInputPhoneCall$inputPhoneCall alloc] init];
        inputPhoneCall.n_id = callId;
        inputPhoneCall.access_hash = accessHash;
        receivedCall.peer = inputPhoneCall;

        return [[[TGTelegramNetworking instance] requestSignal:receivedCall] mapToSignal:^SSignal *(__unused id next) {
            return [SSignal single:[[TGCallReceivedContext alloc] initWithCallId:callId accessHash:accessHash date:date adminId:adminId participantId:participantId gAOrB:gBBytes key:key keyFingerprint:keyId]];
        }];
    }];
}

+ (SSignal *)acceptedIncomingCallWithCallId:(int64_t)callId accessHash:(int64_t)accessHash key:(NSData *)key gBBytes:(NSData *)gBBytes keyId:(int64_t)keyId {
    TLRPCphone_acceptCall$phone_acceptCall *acceptCall = [[TLRPCphone_acceptCall$phone_acceptCall alloc] init];
    TLInputPhoneCall$inputPhoneCall *inputPhoneCall = [[TLInputPhoneCall$inputPhoneCall alloc] init];
    inputPhoneCall.n_id = callId;
    inputPhoneCall.access_hash = accessHash;
    acceptCall.peer = inputPhoneCall;
    acceptCall.g_b = gBBytes;
    acceptCall.key_fingerprint = keyId;
    
    TLPhoneCallProtocol$phoneCallProtocol *phoneCallProtocol = [[TLPhoneCallProtocol$phoneCallProtocol alloc] init];
    phoneCallProtocol.flags = (1 << 0) | (1 << 1);
    phoneCallProtocol.min_layer = 60;
    phoneCallProtocol.max_layer = 60;
    acceptCall.protocol = phoneCallProtocol;
    
    return [[[TGTelegramNetworking instance] requestSignal:acceptCall] mapToSignal:^SSignal *(TLphone_PhoneCall *result) {
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
        } else {
            return [SSignal fail:nil];
        }
    }];
}

@end
