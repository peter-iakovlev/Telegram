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

#import "TLDcOption$modernDcOption.h"

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

+ (NSData *)serializeMessage:(id)message
{
    NSOutputStream *os = [[NSOutputStream alloc] initToMemory];
    [os open];
    TLMetaClassStore::serializeObject(os, message, true);
    NSData *data = [os currentBytes];
    [os close];
    
    return data;
}

- (id)parseMessage:(NSData *)data
{
    NSInputStream *is = [[NSInputStream alloc] initWithData:data];
    [is open];
    
    bool readError = false;
    int32_t topSignature = [is readInt32:&readError];
    if (readError)
    {
        [is close];
        return nil;
    }
    
    __autoreleasing NSError *error = nil;
    id topObject = TLMetaClassStore::constructObject(is, topSignature, nil, nil, &error);
    if (error != nil)
        TGLog(@"%@", error.description);
    
    [is close];
    
    return topObject;
}

+ (id)parseResponse:(NSData *)data request:(TLMetaRpc *)request
{
    NSInputStream *is = [[NSInputStream alloc] initWithData:data];
    [is open];
    
    bool readError = false;
    int32_t topSignature = [is readInt32:&readError];
    if (readError)
    {
        [is close];
        return nil;
    }
    
    __autoreleasing NSError *error = nil;
    TLSerializationContext *context = [[TLSerializationContext alloc] init];
    context.impliedSignature = request.impliedResponseSignature;
    id topObject = TLMetaClassStore::constructObject(is, topSignature, nil, context, &error);
    if (error != nil)
        TGLog(@"%@", error.description);
    
    [is close];
    
    return topObject;
}

- (MTExportAuthorizationResponseParser)exportAuthorization:(int32_t)datacenterId data:(__autoreleasing NSData **)data
{
    TLRPCauth_exportAuthorization$auth_exportAuthorization *exportAuthorization = [[TLRPCauth_exportAuthorization$auth_exportAuthorization alloc] init];
    exportAuthorization.dc_id = datacenterId;
    
    if (data)
        *data = [TGTLSerialization serializeMessage:exportAuthorization];
    
    return ^id (NSData *response)
    {
        id result = [self parseMessage:response];
        if ([result isKindOfClass:[TLauth_ExportedAuthorization class]])
        {
            return [[MTExportedAuthorizationData alloc] initWithAuthorizationBytes:((TLauth_ExportedAuthorization *)result).bytes authorizationId:((TLauth_ExportedAuthorization *)result).n_id];
        }
        return nil;
    };
}

- (NSData *)importAuthorization:(int32_t)authId bytes:(NSData *)bytes
{
    TLRPCauth_importAuthorization$auth_importAuthorization *importAuthorization = [[TLRPCauth_importAuthorization$auth_importAuthorization alloc] init];
    importAuthorization.n_id = authId;
    importAuthorization.bytes = bytes;
    
    return [TGTLSerialization serializeMessage:importAuthorization];
}

- (MTRequestDatacenterAddressListParser)requestDatacenterAddressWithData:(__autoreleasing NSData **)data
{
    NSData *getConfigData = [TGTLSerialization serializeMessage:[[TLRPChelp_getConfig$help_getConfig alloc] init]];
    if (data)
        *data = getConfigData;
    
    return ^MTDatacenterAddressListData *(NSData *response)
    {
        id result = [self parseMessage:response];
        if ([result isKindOfClass:[TLConfig class]])
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            for (TLDcOption$modernDcOption *dcOption in ((TLConfig *)result).dc_options)
            {
                NSMutableArray *array = dict[@(dcOption.n_id)];
                if (array == nil) {
                    array = [[NSMutableArray alloc] init];
                    dict[@(dcOption.n_id)] = array;
                }
                
                MTDatacenterAddress *address = [[MTDatacenterAddress alloc] initWithIp:dcOption.ip_address port:(uint16_t)dcOption.port preferForMedia:dcOption.flags & (1 << 1) restrictToTcp:dcOption.flags & (1 << 2) cdn:dcOption.flags & (1 << 3)  preferForProxy:dcOption.flags & (1 << 4)];
                [array addObject:address];
            }
            
            return [[MTDatacenterAddressListData alloc] initWithAddressList:dict];
        }
        return nil;
    };
}

- (NSUInteger)currentLayer
{
    return 70;
}

@end
