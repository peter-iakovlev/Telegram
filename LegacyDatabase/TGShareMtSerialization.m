#import "TGShareMtSerialization.h"

#import "ApiLayer62.h"

#import <MTProtoKitDynamic/MTExportedAuthorizationData.h>
#import <MTProtoKitDynamic/MTDatacenterAddress.h>

@implementation TGShareMtSerialization

- (NSUInteger)currentLayer
{
    return 62;
}

- (id)parseMessage:(NSData *)data
{
    return [Api62__Environment parseObject:data];
}

- (MTExportAuthorizationResponseParser)exportAuthorization:(int32_t)datacenterId data:(__autoreleasing NSData **)data
{
    Api62_FunctionContext *exportAuthorization = [Api62 auth_exportAuthorizationWithDcId:@(datacenterId)];
    
    if (data)
        *data = exportAuthorization.payload;
    
    return ^MTExportedAuthorizationData *(NSData *data) {
        id response = exportAuthorization.responseParser(data);
        if ([response isKindOfClass:[Api62_auth_ExportedAuthorization class]])
        {
            Api62_auth_ExportedAuthorization *exportedAuthorization = response;
            return [[MTExportedAuthorizationData alloc] initWithAuthorizationBytes:exportedAuthorization.bytes authorizationId:[exportedAuthorization.pid intValue]];
        }
        return nil;
    };
}

- (NSData *)importAuthorization:(int32_t)authId bytes:(NSData *)bytes
{
    Api62_FunctionContext *importAuthorization = [Api62 auth_importAuthorizationWithPid:@(authId) bytes:bytes];
    
    return importAuthorization.payload;
}

- (MTRequestDatacenterAddressListParser)requestDatacenterAddressList:(int32_t)datacenterId data:(__autoreleasing NSData **)data
{
    Api62_FunctionContext *getConfig = [Api62 help_getConfig];
    
    if (data)
        *data = getConfig.payload;
    
    return ^MTDatacenterAddressListData *(NSData *data) {
        id response = getConfig.responseParser(data);
        if ([response isKindOfClass:[Api62_Config class]])
        {
            NSMutableArray *addressList = [[NSMutableArray alloc] init];
            for (Api62_DcOption *dcOption in ((Api62_Config *)response).dcOptions)
            {
                if ([dcOption.pid intValue] == datacenterId)
                {
                    MTDatacenterAddress *address = [[MTDatacenterAddress alloc] initWithIp:dcOption.ipAddress port:(uint16_t)[dcOption.port intValue] preferForMedia:[dcOption.flags intValue] & (1 << 1) restrictToTcp:[dcOption.flags intValue] & (1 << 2)];
                    [addressList addObject:address];
                }
            }
            return [[MTDatacenterAddressListData alloc] initWithAddressList:addressList];
        }
        return nil;
    };
}

@end
