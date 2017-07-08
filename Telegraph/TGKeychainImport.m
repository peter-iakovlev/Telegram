//
//  TGKeychainImport.m
//  Telegraph
//
//  Created by Peter on 17/02/14.
//
//

#import "TGKeychainImport.h"

#import <MTProtoKit/MTContext.h>
#import <MTProtoKit/MTProtoKit.h>
#import <MTProtoKit/MTDatacenterAddressSet.h>
#import <MTProtoKit/MTDatacenterAddress.h>
#import <MTProtoKit/MTDatacenterAuthInfo.h>
#import <MTProtoKit/MTKeychain.h>

#import "TGDatacenterContext.h"

@implementation TGKeychainImport

+ (NSMutableDictionary *)getKeychainQuery
{
    NSString *service = @"com.telegraph.Telegraph";
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)kSecClassGenericPassword, (__bridge id)kSecClass,
            service, (__bridge id)kSecAttrService,
            service, (__bridge id)kSecAttrAccount,
            (__bridge id)kSecAttrAccessibleAfterFirstUnlock, (__bridge id)kSecAttrAccessible,
            nil];
}

+ (int64_t)clientKeychainId
{
    static int64_t value = 0;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^
    {
        int64_t storedValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"clientKeychainId"] longLongValue];
        if (storedValue == 0)
        {
            arc4random_buf(&storedValue, 8);
            [[NSUserDefaults standardUserDefaults] setObject:[[NSNumber alloc] initWithLongLong:storedValue] forKey:@"clientKeychainId"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        value = storedValue;
    });
    
    return value;
}

+ (void)importKeychain:(id<MTKeychain>)keychain clientUserId:(int32_t)clientUserId
{
    NSMutableDictionary *datacenterAddressSets = [[NSMutableDictionary alloc] init];
    NSInteger currentDatacenterId = 0;
    NSMutableDictionary *datacenterAuthInfo = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *datacenterAuthTokens = [[NSMutableDictionary alloc] init];
    
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr)
    {
        @try
        {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        }
        @catch (NSException *e)
        {
            TGLog(@"Unarchive of credentials failed: %@", e);
        }
    }
    
    if (ret != nil && [ret isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = (NSDictionary *)ret;
        
        int datacenterSetId = [[dict objectForKey:@"backendId"] intValue];
        NSNumber *keychainId = [dict objectForKey:@"clientKeychainId"];
        int64_t currentClientKeychainId = [self clientKeychainId];
        bool keychainKeyMatches = (keychainId == nil || [keychainId longLongValue] == currentClientKeychainId);
        if (datacenterSetId == 1 && [[dict objectForKey:@"version"] intValue] == 5 && keychainKeyMatches)
        {
            NSArray *datacenterDatas = [dict objectForKey:@"datacenters"];
            for (NSData *data in datacenterDatas)
            {
                TGDatacenterContext *datacenter = [[TGDatacenterContext alloc] initWithSerializedData:data];
                if (datacenter != nil)
                {
                    if (datacenter.addressSet.count != 0)
                    {
                        NSString *address = datacenter.addressSet[0][@"address"];
                        uint16_t port = (uint16_t)([datacenter.addressSet[0][@"port"] intValue]);
                        if (address.length != 0 && port != 0)
                        {
                            datacenterAddressSets[@(datacenter.datacenterId)] = [[MTDatacenterAddressSet alloc] initWithAddressList:@[
                                                                                                                                      [[MTDatacenterAddress alloc] initWithIp:address port:port preferForMedia:false restrictToTcp:false cdn:false preferForProxy:false]
                            ]];
                        }
                    }
                    
                    if (datacenter.authKey != nil && datacenter.authKeyId.length == 8)
                    {
                        int64_t authKeyId = 0;
                        [datacenter.authKeyId getBytes:&authKeyId length:8];
                        datacenterAuthInfo[@(datacenter.datacenterId)] = [[MTDatacenterAuthInfo alloc] initWithAuthKey:datacenter.authKey authKeyId:authKeyId saltSet:@[] authKeyAttributes:@{}];
                        
                        if (datacenter.authorized && clientUserId != 0)
                            datacenterAuthTokens[@(datacenter.datacenterId)] = @(clientUserId);
                    }
                }
            }
            
            currentDatacenterId = [[dict objectForKey:@"currentDatacenter"] intValue];
        }
    }
    
    if (datacenterAddressSets.count != 0 && currentDatacenterId != 0 && datacenterAuthInfo.count != 0)
    {
        [keychain setObject:@(currentDatacenterId) forKey:@"defaultDatacenterId" group:@"persistent"];
        [keychain setObject:datacenterAddressSets forKey:@"datacenterAddressSetById" group:@"persistent"];
        [keychain setObject:datacenterAuthInfo forKey:@"datacenterAuthInfoById" group:@"persistent"];
        [keychain setObject:datacenterAuthTokens forKey:@"authTokenById" group:@"persistent"];
    }
}

+ (void)clearLegacyKeychain
{
    NSMutableDictionary *keychainQuery = [self getKeychainQuery];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
}

@end
