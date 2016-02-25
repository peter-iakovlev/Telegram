#import "TGShareMtSerialization.h"

#import "ApiLayer48.h"

#import <MTProtoKit/MTExportedAuthorizationData.h>
#import <MTProtoKit/MTDatacenterAddress.h>

@implementation TGShareMtSerialization

- (NSUInteger)currentLayer
{
    return 48;
}

- (id)parseMessage:(NSData *)data
{
    return [Api48__Environment parseObject:data];
}

- (MTExportAuthorizationResponseParser)exportAuthorization:(int32_t)datacenterId data:(__autoreleasing NSData **)data
{
    Api48_FunctionContext *exportAuthorization = [Api48 auth_exportAuthorizationWithDcId:@(datacenterId)];
    
    if (data)
        *data = exportAuthorization.payload;
    
    return ^MTExportedAuthorizationData *(NSData *data) {
        id response = exportAuthorization.responseParser(data);
        if ([response isKindOfClass:[Api48_auth_ExportedAuthorization class]])
        {
            Api48_auth_ExportedAuthorization *exportedAuthorization = response;
            return [[MTExportedAuthorizationData alloc] initWithAuthorizationBytes:exportedAuthorization.bytes authorizationId:[exportedAuthorization.pid intValue]];
        }
        return nil;
    };
}

- (NSData *)importAuthorization:(int32_t)authId bytes:(NSData *)bytes
{
    Api48_FunctionContext *importAuthorization = [Api48 auth_importAuthorizationWithPid:@(authId) bytes:bytes];
    
    return importAuthorization.payload;
}

- (MTRequestDatacenterAddressListParser)requestDatacenterAddressList:(int32_t)datacenterId data:(__autoreleasing NSData **)data
{
    Api48_FunctionContext *getConfig = [Api48 help_getConfig];
    
    if (data)
        *data = getConfig.payload;
    
    return ^MTDatacenterAddressListData *(NSData *data) {
        id response = getConfig.responseParser(data);
        if ([response isKindOfClass:[Api48_Config class]])
        {
            NSMutableArray *addressList = [[NSMutableArray alloc] init];
            for (Api48_DcOption *dcOption in ((Api48_Config *)response).dcOptions)
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
