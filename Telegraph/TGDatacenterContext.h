/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "TL/TLMetaScheme.h"

#ifdef __cplusplus
struct TGServerSalt;
#endif

@protocol TGTransport;

@interface TGDatacenterContext : NSObject

@property (nonatomic) int datacenterId;
@property (nonatomic, strong) NSArray *addressSet;

@property (nonatomic, strong) NSData *authKey;
@property (nonatomic, strong) NSData *authKeyId;

@property (nonatomic) bool authorized;

@property (nonatomic) int64_t authSessionId;
@property (nonatomic) int64_t authUploadSessionId;
@property (nonatomic) int64_t authDownloadSessionId;

@property (nonatomic, strong) id<TGTransport> datacenterTransport;
@property (nonatomic, strong) id<TGTransport> datacenterUploadTransport;

@property (nonatomic) int32_t initializedConnectionHash;

- (id)initWithSerializedData:(NSData *)data;
- (NSData *)serialize;

- (void)clear;
- (void)clearServerSalts;

- (int64_t)selectServerSalt:(int)date;
- (void)mergeServerSalts:(int)date salts:(NSArray *)salts;
#ifdef __cplusplus
- (void)addServerSalt:(TGServerSalt)serverSalt;
#endif
- (bool)containsServerSalt:(int64_t)salt;

@end
