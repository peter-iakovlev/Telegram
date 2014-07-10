//
//  TGKeychainImport.h
//  Telegraph
//
//  Created by Peter on 17/02/14.
//
//

#import <Foundation/Foundation.h>

@class MTKeychain;

@interface TGKeychainImport : NSObject

+ (void)importKeychain:(MTKeychain *)keychain clientUserId:(int32_t)clientUserId;
+ (void)clearLegacyKeychain;

@end
