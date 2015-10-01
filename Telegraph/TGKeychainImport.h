//
//  TGKeychainImport.h
//  Telegraph
//
//  Created by Peter on 17/02/14.
//
//

#import <Foundation/Foundation.h>

@protocol MTKeychain;

@interface TGKeychainImport : NSObject

+ (void)importKeychain:(id<MTKeychain>)keychain clientUserId:(int32_t)clientUserId;
+ (void)clearLegacyKeychain;

@end
