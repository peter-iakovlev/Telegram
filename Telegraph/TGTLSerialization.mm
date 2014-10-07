/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGTLSerialization.h"

#import "TL/TLMetaScheme.h"
#import "TLMetaClassStore.h"
#import "TLMetaSchemeData.h"

#import "TLMessageContainer.h"
#import "TLFutureSalts.h"
#import "TLRpcResult.h"

#import "NSInputStream+TL.h"

#import <MTProtoKit/MTDatacenterAddress.h>
#import <MTProtoKit/MTDatacenterSaltInfo.h>

#import "TLMsgsAck$msgs_ack_manual.h"

@interface TGTLSerializationEnvironment : NSObject <TLSerializationEnvironment>

@property (nonatomic, copy) int32_t (^responseParsingBlock)(int64_t, bool *);

@end

@implementation TGTLSerializationEnvironment

- (instancetype)initWithResponseParsingBlock:(int32_t (^)(int64_t, bool *))responseParsingBlock
{
    self = [super init];
    if (self != nil)
    {
        self.responseParsingBlock = responseParsingBlock;
    }
    return self;
}

- (TLSerializationContext *)serializationContextForRpcResult:(int64_t)requestMessageId
{
    if (_responseParsingBlock != nil)
    {
        bool found = false;
        int32_t signature = _responseParsingBlock(requestMessageId, &found);
        if (found)
        {
            TLSerializationContext *context = [[TLSerializationContext alloc] init];
            context.impliedSignature = signature;
            return context;
        }
    }
    
    return nil;
}

@end

@interface TGTLSerialization ()

@end

@implementation TGTLSerialization

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            TLRegisterClasses();
            
            TLMetaClassStore::registerObjectClass([[TLMessageContainer$msg_container alloc] init]);
            TLMetaClassStore::registerObjectClass([[TLFutureSalts$future_salts alloc] init]);
            
            TLMetaClassStore::mergeScheme(TLgetMetaScheme());
        });
    }
    return self;
}

- (NSData *)serializeMessage:(id)message
{
    NSOutputStream *os = [[NSOutputStream alloc] initToMemory];
    [os open];
    TLMetaClassStore::serializeObject(os, message, true);
    NSData *data = [os currentBytes];
    [os close];
    
    return data;
}

- (id)parseMessage:(NSInputStream *)is responseParsingBlock:(int32_t (^)(int64_t, bool *))responseParsingBlock
{
    bool readError = false;
    int32_t topSignature = [is readInt32:&readError];
    if (readError)
    {
        [is close];
        return nil;
    }
    
    __autoreleasing NSError *error = nil;
    id topObject = TLMetaClassStore::constructObject(is, topSignature, [[TGTLSerializationEnvironment alloc] initWithResponseParsingBlock:responseParsingBlock], nil, &error);
    
    return topObject;
}

- (NSString *)messageDescription:(id)messageBody messageId:(int64_t)messageId messageSeqNo:(int32_t)messageSeqNo
{
    if ([messageBody isKindOfClass:[TLMsgsAck class]])
    {
        NSMutableString *idsString = [[NSMutableString alloc] init];
        for (NSNumber *nMessageId in ((TLMsgsAck *)messageBody).msg_ids)
        {
            if (idsString.length != 0)
                [idsString appendString:@","];
            [idsString appendFormat:@"%lld", [nMessageId longLongValue]];
        }
        
        return [[NSString alloc] initWithFormat:@"%@ (%" PRId64 "/%" PRId32 ") for (%@)", NSStringFromClass([messageBody class]), messageId, messageSeqNo, idsString];
    }
    else if ([messageBody isKindOfClass:[TLInvokeWithLayer17 class]])
    {
        id subBody = ((TLInvokeWithLayer17 *)messageBody).query;
        if ([subBody isKindOfClass:[TLInitConnection class]])
            return [[NSString alloc] initWithFormat:@"%@ (I, L, %" PRId64 "/%" PRId32 ")", NSStringFromClass([((TLInitConnection *)subBody).query class]), messageId, messageSeqNo];
        else
            return [[NSString alloc] initWithFormat:@"%@ (L, %" PRId64 "/%" PRId32 ")", NSStringFromClass([subBody class]), messageId, messageSeqNo];
    }
    else
        return [[NSString alloc] initWithFormat:@"%@ (%" PRId64 "/%" PRId32 ")", NSStringFromClass([messageBody class]), messageId, messageSeqNo];
}

- (id)reqPq:(NSData *)nonce
{
    TLRPCreq_pq$req_pq *reqPq = [[TLRPCreq_pq$req_pq alloc] init];
    reqPq.nonce = nonce;
    
    return reqPq;
}

- (id)reqDhParams:(NSData *)nonce serverNonce:(NSData *)serverNonce p:(NSData *)p q:(NSData *)q publicKeyFingerprint:(int64_t)publicKeyFingerprint encryptedData:(NSData *)encryptedData
{
    TLRPCreq_DH_params$req_DH_params *reqDH = [[TLRPCreq_DH_params$req_DH_params alloc] init];
    reqDH.nonce = nonce;
    reqDH.server_nonce = serverNonce;
    reqDH.p = p;
    reqDH.q = q;
    reqDH.public_key_fingerprint = publicKeyFingerprint;
    reqDH.encrypted_data = encryptedData;
    
    return reqDH;
}

- (id)setDhParams:(NSData *)nonce serverNonce:(NSData *)serverNonce encryptedData:(NSData *)encryptedData
{
    TLRPCset_client_DH_params$set_client_DH_params *setClientDhParams = [[TLRPCset_client_DH_params$set_client_DH_params alloc] init];
    setClientDhParams.nonce = nonce;
    setClientDhParams.server_nonce = serverNonce;
    setClientDhParams.encrypted_data = encryptedData;
    
    return setClientDhParams;
}

- (id)pqInnerData:(NSData *)nonce serverNonce:(NSData *)serverNonce pq:(NSData *)pq p:(NSData *)p q:(NSData *)q newNonce:(NSData *)newNonce
{
    TLP_Q_inner_data$p_q_inner_data *innerData = [[TLP_Q_inner_data$p_q_inner_data alloc] init];
    innerData.nonce = nonce;
    innerData.server_nonce = serverNonce;
    innerData.pq = pq;
    innerData.p = p;
    innerData.q = q;
    innerData.n_new_nonce = newNonce;
    
    return innerData;
}

- (id)clientDhInnerData:(NSData *)nonce serverNonce:(NSData *)serverNonce g_b:(NSData *)g_b retryId:(int32_t)retryId
{
    TLClient_DH_Inner_Data$client_DH_inner_data *clientInnerData = [[TLClient_DH_Inner_Data$client_DH_inner_data alloc] init];
    clientInnerData.nonce = nonce;
    clientInnerData.server_nonce = serverNonce;
    clientInnerData.g_b = g_b;
    clientInnerData.retry_id = retryId;
    
    return clientInnerData;
}

- (bool)isMessageResPq:(id)message
{
    return [message isKindOfClass:[TLResPQ class]];
}

- (NSData *)resPqNonce:(id)message
{
    return ((TLResPQ *)message).nonce;
}

- (NSData *)resPqServerNonce:(id)message
{
    return ((TLResPQ *)message).server_nonce;
}

- (NSData *)resPqPq:(id)message
{
    return ((TLResPQ *)message).pq;
}

- (NSArray *)resPqServerPublicKeyFingerprints:(id)message
{
    return ((TLResPQ *)message).server_public_key_fingerprints;
}

- (bool)isMessageServerDhParams:(id)message
{
    return [message isKindOfClass:[TLServer_DH_Params class]];
}

- (NSData *)serverDhParamsNonce:(id)message
{
    return ((TLServer_DH_Params *)message).nonce;
}

- (NSData *)serverDhParamsServerNonce:(id)message
{
    return ((TLServer_DH_Params *)message).server_nonce;
}

- (bool)isMessageServerDhParamsOk:(id)message
{
    return [message isKindOfClass:[TLServer_DH_Params$server_DH_params_ok class]];
}

- (NSData *)serverDhParamsOkEncryptedAnswer:(id)message
{
    return ((TLServer_DH_Params$server_DH_params_ok *)message).encrypted_answer;
}

- (bool)isMessageServerDhInnerData:(id)message
{
    return [message isKindOfClass:[TLServer_DH_inner_data class]];
}

- (NSData *)serverDhInnerDataNonce:(id)message
{
    return ((TLServer_DH_inner_data *)message).nonce;
}

- (NSData *)serverDhInnerDataServerNonce:(id)message
{
    return ((TLServer_DH_inner_data *)message).server_nonce;
}

- (int32_t)serverDhInnerDataG:(id)message
{
    return ((TLServer_DH_inner_data *)message).g;
}

- (NSData *)serverDhInnerDataDhPrime:(id)message
{
    return ((TLServer_DH_inner_data *)message).dh_prime;
}

- (NSData *)serverDhInnerDataGA:(id)message
{
    return ((TLServer_DH_inner_data *)message).g_a;
}

- (bool)isMessageSetClientDhParamsAnswer:(id)message
{
    return [message isKindOfClass:[TLSet_client_DH_params_answer class]];
}

- (bool)isMessageSetClientDhParamsAnswerOk:(id)message
{
    return [message isKindOfClass:[TLSet_client_DH_params_answer$dh_gen_ok class]];
}

- (bool)isMessageSetClientDhParamsAnswerRetry:(id)message
{
    return [message isKindOfClass:[TLSet_client_DH_params_answer$dh_gen_retry class]];
}

- (bool)isMessageSetClientDhParamsAnswerFail:(id)message
{
    return [message isKindOfClass:[TLSet_client_DH_params_answer$dh_gen_fail class]];
}

- (NSData *)setClientDhParamsNonce:(id)message
{
    return ((TLSet_client_DH_params_answer *)message).nonce;
}

- (NSData *)setClientDhParamsServerNonce:(id)message
{
    return ((TLSet_client_DH_params_answer *)message).server_nonce;
}

- (NSData *)setClientDhParamsNewNonceHash1:(id)message
{
    return ((TLSet_client_DH_params_answer$dh_gen_ok *)message).n_new_nonce_hash1;
}

- (NSData *)setClientDhParamsNewNonceHash2:(id)message
{
    return ((TLSet_client_DH_params_answer$dh_gen_retry *)message).n_new_nonce_hash2;
}

- (NSData *)setClientDhParamsNewNonceHash3:(id)message
{
    return ((TLSet_client_DH_params_answer$dh_gen_fail *)message).n_new_nonce_hash3;
}

- (id)exportAuthorization:(int32_t)datacenterId
{
    TLRPCauth_exportAuthorization$auth_exportAuthorization *exportAuthorization = [[TLRPCauth_exportAuthorization$auth_exportAuthorization alloc] init];
    exportAuthorization.dc_id = datacenterId;
    
    return exportAuthorization;
}

- (NSData *)exportedAuthorizationBytes:(id)message
{
    return ((TLauth_ExportedAuthorization *)message).bytes;
}

- (int32_t)exportedAuthorizationId:(id)message
{
    return ((TLauth_ExportedAuthorization *)message).n_id;
}

- (id)importAuthorization:(int32_t)authId bytes:(NSData *)bytes
{
    TLRPCauth_importAuthorization$auth_importAuthorization *importAuthorization = [[TLRPCauth_importAuthorization$auth_importAuthorization alloc] init];
    importAuthorization.n_id = authId;
    importAuthorization.bytes = bytes;
    
    return importAuthorization;
}

- (id)getConfig
{
    return [[TLRPChelp_getConfig$help_getConfig alloc] init];
}

- (NSArray *)datacenterAddressListFromConfig:(id)config datacenterId:(NSInteger)datacenterId
{
    if ([config isKindOfClass:[TLConfig class]])
    {
        TLConfig *concreteConfig = config;
        NSMutableArray *addressList = [[NSMutableArray alloc] init];
        
        for (TLDcOption *dcOption in concreteConfig.dc_options)
        {
            if (dcOption.n_id == datacenterId)
            {
                MTDatacenterAddress *address = [[MTDatacenterAddress alloc] initWithIp:dcOption.ip_address port:(uint16_t)dcOption.port];
                [addressList addObject:address];
            }
        }
        
        return addressList;
    }
    
    return nil;
}

- (id)getFutureSalts:(int32_t)count
{
    TLRPCget_future_salts$get_future_salts *getFutureSalts = [[TLRPCget_future_salts$get_future_salts alloc] init];
    getFutureSalts.num = count;
    
    return getFutureSalts;
}

- (bool)isMessageFutureSalts:(id)message
{
    return [message isKindOfClass:[TLFutureSalts class]];
}


- (int64_t)futureSaltsRequestMessageId:(id)message
{
    if ([self isMessageFutureSalts:message])
    {
        TLFutureSalts *futureSalts = message;
        return futureSalts.req_msg_id;
    }
    
    return 0;
}

- (NSArray *)saltInfoListFromMessage:(id)message
{
    if ([self isMessageFutureSalts:message])
    {
        TLFutureSalts *futureSalts = message;
        NSMutableArray *saltList = [[NSMutableArray alloc] init];
        for (TLFutureSalt *salt in futureSalts.salts)
        {
            [saltList addObject:[[MTDatacenterSaltInfo alloc] initWithSalt:salt.salt firstValidMessageId:salt.valid_since * 4294967296 lastValidMessageId:salt.valid_until * 4294967296]];
        }
        
        return saltList;
    }
    
    return nil;
}

- (id)resendMessagesRequest:(NSArray *)messageIds
{
    TLMsgResendReq$msg_resend_req *resendReq = [[TLMsgResendReq$msg_resend_req alloc] init];
    resendReq.msg_ids = messageIds;
    
    return resendReq;
}

- (id)connectionWithApiId:(int32_t)apiId deviceModel:(NSString *)deviceModel systemVersion:(NSString *)systemVersion appVersion:(NSString *)appVersion langCode:(NSString *)langCode query:(id)query
{
    TLInitConnection$initConnection *initConnection = [[TLInitConnection$initConnection alloc] init];
    initConnection.api_id = apiId;
    initConnection.device_model = deviceModel;
    initConnection.system_version = systemVersion;
    initConnection.app_version = appVersion;
    initConnection.lang_code = langCode;
    initConnection.query = query;
    
    return initConnection;
}

- (id)invokeAfterMessageId:(int64_t)messageId query:(id)query
{
    TLInvokeAfterMsg$invokeAfterMsg *invokeAfterMsg = [[TLInvokeAfterMsg$invokeAfterMsg alloc] init];
    invokeAfterMsg.msg_id = messageId;
    invokeAfterMsg.query = query;
    
    return invokeAfterMsg;
}
                
- (bool)isMessageContainer:(id)message
{
    return [message isKindOfClass:[TLMessageContainer class]];
}
                
- (NSArray *)containerMessages:(id)message
{
    if ([self isMessageContainer:message])
        return ((TLMessageContainer *)message).messages;
    
    return nil;
}
                
- (bool)isMessageProtoMessage:(id)message
{
    return [message isKindOfClass:[TLProtoMessage class]];
}
                
- (id)protoMessageBody:(id)message messageId:(int64_t *)messageId seqNo:(int32_t *)seqNo length:(int32_t *)length
{
    if ([self isMessageProtoMessage:message])
    {
        if (messageId != NULL)
            *messageId = ((TLProtoMessage *)message).msg_id;
        if (seqNo != NULL)
            *seqNo = ((TLProtoMessage *)message).seqno;
        if (length != NULL)
            *length = ((TLProtoMessage *)message).bytes;
        
        return ((TLProtoMessage *)message).body;
    }
    
    return nil;
}
                
- (bool)isMessageProtoCopyMessage:(id)message
{
    return [message isKindOfClass:[TLProtoMessageCopy class]];
}
                
- (id)protoCopyMessageBody:(id)message messageId:(int64_t *)messageId seqNo:(int32_t *)seqNo length:(int32_t *)length
{
    if ([self isMessageProtoCopyMessage:message])
    {
        if (messageId != NULL)
            *messageId = ((TLProtoMessageCopy *)message).orig_message.msg_id;
        if (seqNo != NULL)
            *seqNo = ((TLProtoMessageCopy *)message).orig_message.seqno;
        if (length != NULL)
            *length = ((TLProtoMessageCopy *)message).orig_message.bytes;

        return ((TLProtoMessageCopy *)message).orig_message.body;
    }

    return nil;
}

- (bool)isMessageRpcWithLayer:(id)message
{
    return [message isKindOfClass:[TLMetaRpc class]] && ((TLMetaRpc *)message).layerVersion != 0;
}

- (id)wrapInLayer:(id)message
{
    static int maxLayerVersion = 17;
    
    static NSMutableDictionary *layerClassesByVersion = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        layerClassesByVersion = [[NSMutableDictionary alloc] init];
        
        for (int i = maxLayerVersion + 1; i < maxLayerVersion + 10; i++)
        {
            if (NSClassFromString([[NSString alloc] initWithFormat:@"TLInvokeWithLayer%d$invokeWithLayer%d", i, i]) != nil)
                maxLayerVersion = i;
        }
    });
    
    Class layerClass = layerClassesByVersion[@(maxLayerVersion)];
    if (layerClass == nil)
    {
        layerClass = NSClassFromString([[NSString alloc] initWithFormat:@"TLInvokeWithLayer%d$invokeWithLayer%d", maxLayerVersion, maxLayerVersion]);
        
        if (layerClass != nil)
            layerClassesByVersion[@(maxLayerVersion)] = layerClass;
    }
    
    if (layerClass == nil)
        TGLog(@"[MTRequestMessageService#%p layer version %d class not found]", self, maxLayerVersion);
    
    id layerObject = [[layerClass alloc] init];
    [layerObject setQuery:message];
    
    return layerObject;
}

- (id)dropAnswerToMessageId:(int64_t)messageId
{
    TLRPCrpc_drop_answer$rpc_drop_answer *dropAnswer = [[TLRPCrpc_drop_answer$rpc_drop_answer alloc] init];
    dropAnswer.req_msg_id = messageId;
    
    return dropAnswer;
}

- (bool)isRpcDroppedAnswer:(id)message
{
    return [message isKindOfClass:[TLRpcResult class]] && [((TLRpcResult *)message).result isKindOfClass:[TLRpcDropAnswer class]];
}

- (int64_t)rpcDropedAnswerDropMessageId:(id)message
{
    if ([self isRpcDroppedAnswer:message])
        return ((TLRpcResult *)message).req_msg_id;
    
    return 0;
}

- (bool)isMessageRpcResult:(id)message
{
    return [message isKindOfClass:[TLRpcResult class]];
}

- (id)rpcResultBody:(id)message requestMessageId:(int64_t *)requestMessageId
{
    if ([self isMessageRpcResult:message])
    {
        if (requestMessageId != NULL)
            *requestMessageId = ((TLRpcResult *)message).req_msg_id;
        
        return ((TLRpcResult *)message).result;
    }
    
    return nil;
}

- (id)rpcResult:(id)resultBody requestBody:(id)requestBody isError:(bool *)isError
{
/*#if TARGET_IPHONE_SIMULATOR
    if ([resultBody isKindOfClass:[TLmessages_SentMessage class]])
    {
        *isError = true;
        TLError$error *error = [[TLError$error alloc] init];
        error.code = 420;
        error.text = @"FLOOD_WAIT_10";
        return error;
    }
#endif*/
    
    if ([resultBody isKindOfClass:[TLRpcError class]])
    {
        if (isError != NULL)
            *isError = true;
        
        TLError$richError *implicitError = [[TLError$richError alloc] init];
        implicitError.code = ((TLRpcError *)resultBody).error_code;
        implicitError.n_description = ((TLRpcError *)resultBody).error_message;
        
        return implicitError;
    }
    else if ([resultBody isKindOfClass:[TLRpcError class]])
    {
        if (isError != NULL)
            *isError = true;
        
        return resultBody;
    }
    else
    {
        if ([requestBody isKindOfClass:[TLMetaRpc class]])
        {
            if (![resultBody isKindOfClass:[(TLMetaRpc *)requestBody responseClass]])
            {
                TLError$richError *implicitError = [[TLError$richError alloc] init];
                implicitError.code = -1000;
                
                if (isError != NULL)
                    *isError = true;
                
                return implicitError;
            }
            else
                return resultBody;
        }
        else
            return resultBody;
    }
}

- (int32_t)rpcRequestBodyResponseSignature:(id)requestBody
{
    if ([requestBody isKindOfClass:[TLMetaRpc class]])
        return [(TLMetaRpc *)requestBody impliedResponseSignature];
    
    return 0;
}

- (NSString *)rpcErrorDescription:(id)error
{
    if ([error isKindOfClass:[TLRpcError class]])
        return [[NSString alloc] initWithFormat:@"%d: %@", ((TLRpcError *)error).error_code, ((TLRpcError *)error).error_message];
    else if ([error isKindOfClass:[TLError$error class]])
        return [[NSString alloc] initWithFormat:@"%d: %@", ((TLError$error *)error).code, ((TLError$error *)error).text];
    else if ([error isKindOfClass:[TLError$richError class]])
        return [[NSString alloc] initWithFormat:@"%d: %@:%@", ((TLError$richError *)error).code, ((TLError$richError *)error).type, ((TLError$richError *)error).n_description];
    
    return [error description];
}

- (int32_t)rpcErrorCode:(id)error
{
    if ([error isKindOfClass:[TLRpcError class]])
        return ((TLRpcError *)error).error_code;
    else if ([error isKindOfClass:[TLError class]])
        return ((TLError *)error).code;
    
    return 0;
}

- (NSString *)rpcErrorText:(id)error
{
    if ([error isKindOfClass:[TLRpcError class]])
        return ((TLRpcError *)error).error_message;
    else if ([error isKindOfClass:[TLError$error class]])
        return ((TLError$error *)error).text;
    else if ([error isKindOfClass:[TLError$richError class]])
        return ((TLError$richError *)error).type;
    
    return nil;
}

- (id)ping:(int64_t)pingId
{
    TLRPCping$ping *ping = [[TLRPCping$ping alloc] init];
    ping.ping_id = pingId;
    
    return ping;
}

- (bool)isMessagePong:(id)message
{
    return [message isKindOfClass:[TLPong class]];
}

- (int64_t)pongMessageId:(id)message
{
    if ([self isMessagePong:message])
    {
        return ((TLPong *)message).msg_id;
    }
    
    return 0;
}

- (int64_t)pongPingId:(id)message
{
    if ([self isMessagePong:message])
    {
        return ((TLPong *)message).ping_id;
    }
    
    return 0;
}

- (id)msgsAck:(NSArray *)messageIds
{
    TLMsgsAck$msgs_ack_manual *msgsAck = [[TLMsgsAck$msgs_ack_manual alloc] init];
    msgsAck.msg_ids = messageIds;
    
    return msgsAck;
}
                
- (bool)isMessageMsgsAck:(id)message
{
    return [message isKindOfClass:[TLMsgsAck class]];
}
                
- (NSArray *)msgsAckMessageIds:(id)message
{
    if ([self isMessageMsgsAck:message])
        return ((TLMsgsAck *)message).msg_ids;
    
    return nil;
}
                
- (bool)isMessageBadMsgNotification:(id)message
{
    return [message isKindOfClass:[TLBadMsgNotification class]];
}
                
- (int64_t)badMessageBadMessageId:(id)message
{
    if ([self isMessageBadMsgNotification:message])
        return ((TLBadMsgNotification *)message).bad_msg_id;
    
    return 0;
}
                
- (bool)isMessageBadServerSaltNotification:(id)message
{
    return [message isKindOfClass:[TLBadMsgNotification$bad_server_salt class]];
}
                
- (int64_t)badMessageNewServerSalt:(id)message
{
    if ([self isMessageBadServerSaltNotification:message])
        return ((TLBadMsgNotification$bad_server_salt *)message).n_new_server_salt;
    
    return 0;
}
                
- (int32_t)badMessageErrorCode:(id)message
{
    if ([self isMessageBadMsgNotification:message])
        return ((TLBadMsgNotification *)message).error_code;
    
    return 0;
}

- (bool)isMessageDetailedInfo:(id)message
{
    return [message isKindOfClass:[TLMsgDetailedInfo class]];
}

- (bool)isMessageDetailedResponseInfo:(id)message
{
    return [message isKindOfClass:[TLMsgDetailedInfo$msg_detailed_info class]];
}

- (int64_t)detailedInfoResponseRequestMessageId:(id)message
{
    if ([self isMessageDetailedResponseInfo:message])
        return ((TLMsgDetailedInfo$msg_detailed_info *)message).msg_id;
    
    return 0;
}

- (int64_t)detailedInfoResponseMessageId:(id)message
{
    if ([self isMessageDetailedInfo:message])
        return ((TLMsgDetailedInfo *)message).answer_msg_id;
    
    return 0;
}

- (int64_t)detailedInfoResponseMessageLength:(id)message
{
    if ([self isMessageDetailedInfo:message])
        return ((TLMsgDetailedInfo *)message).bytes;
    
    return 0;
}

- (bool)isMessageMsgsStateInfo:(id)message forInfoRequestMessageId:(int64_t)infoRequestMessageId
{
    if ([message isKindOfClass:[TLMsgsStateInfo class]])
        return ((TLMsgsStateInfo *)message).req_msg_id == infoRequestMessageId;
    
    return false;
}

- (bool)isMessageNewSession:(id)message
{
    return [message isKindOfClass:[TLNewSession class]];
}

- (int64_t)messageNewSessionFirstValidMessageId:(id)message
{
    if ([self isMessageNewSession:message])
        return ((TLNewSession *)message).first_msg_id;
    
    return 0;
}

- (id)httpWaitWithMaxDelay:(int32_t)maxDelay waitAfter:(int32_t)waitAfter maxWait:(int32_t)maxWait
{
    TLHttpWait$http_wait *httpWait = [[TLHttpWait$http_wait alloc] init];
    httpWait.max_delay = maxDelay;
    httpWait.wait_after = waitAfter;
    httpWait.max_wait = maxWait;
    
    return httpWait;
}

@end