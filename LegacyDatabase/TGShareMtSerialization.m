#import "TGShareMtSerialization.h"

#import "ApiLayer86.h"

#import <MTProtoKitDynamic/MTExportedAuthorizationData.h>
#import <MTProtoKitDynamic/MTDatacenterAddress.h>

@implementation TGShareMtSerialization

- (NSUInteger)currentLayer
{
    return 86;
}

- (id)parseMessage:(NSData *)data
{
    return [Api86__Environment parseObject:data];
}

- (MTExportAuthorizationResponseParser)exportAuthorization:(int32_t)datacenterId data:(__autoreleasing NSData **)data
{
    Api86_FunctionContext *exportAuthorization = [Api86 auth_exportAuthorizationWithDcId:@(datacenterId)];
    
    if (data)
        *data = exportAuthorization.payload;
    
    return ^MTExportedAuthorizationData *(NSData *data) {
        id response = exportAuthorization.responseParser(data);
        if ([response isKindOfClass:[Api86_auth_ExportedAuthorization class]])
        {
            Api86_auth_ExportedAuthorization *exportedAuthorization = response;
            return [[MTExportedAuthorizationData alloc] initWithAuthorizationBytes:exportedAuthorization.bytes authorizationId:[exportedAuthorization.pid intValue]];
        }
        return nil;
    };
}

- (NSData *)importAuthorization:(int32_t)authId bytes:(NSData *)bytes
{
    Api86_FunctionContext *importAuthorization = [Api86 auth_importAuthorizationWithPid:@(authId) bytes:bytes];
    
    return importAuthorization.payload;
}

- (MTRequestDatacenterAddressListParser)requestDatacenterAddressWithData:(__autoreleasing NSData **)data
{
    Api86_FunctionContext *getConfig = [Api86 help_getConfig];
    
    if (data)
        *data = getConfig.payload;
    
    return ^MTDatacenterAddressListData *(NSData *data) {
        id response = getConfig.responseParser(data);
        if ([response isKindOfClass:[Api86_Config class]])
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            for (Api86_DcOption *dcOption in ((Api86_Config *)response).dcOptions)
            {
                NSMutableArray *array = dict[@([dcOption.pid intValue])];
                if (array == nil) {
                    array = [[NSMutableArray alloc] init];
                    dict[@([dcOption.pid intValue])] = array;
                }
                
                MTDatacenterAddress *address = [[MTDatacenterAddress alloc] initWithIp:dcOption.ipAddress port:(uint16_t)[dcOption.port intValue] preferForMedia:[dcOption.flags intValue] & (1 << 1) restrictToTcp:[dcOption.flags intValue] & (1 << 2) cdn:[dcOption.flags intValue] & (1 << 3) preferForProxy:[dcOption.flags intValue] & (1 << 4) secret:dcOption.secret];
                [array addObject:address];
            }
            return [[MTDatacenterAddressListData alloc] initWithAddressList:dict];
        }
        return nil;
    };
}

@end
