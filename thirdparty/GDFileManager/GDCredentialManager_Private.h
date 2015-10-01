//
//  GDCredentialManager_Private.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 11/07/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDCredentialManager.h"

@interface GDCredentialManager ()

@property (nonatomic) dispatch_queue_t isolationQueue;

- (NSArray *)loadCredentialsForAccount:(NSString *)account;
- (void)saveCredentials:(NSArray *)credentials forAccount:(NSString *)account;

@end
