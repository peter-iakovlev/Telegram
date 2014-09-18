#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLEncryptedChat : NSObject <TLObject>

@property (nonatomic) int32_t n_id;

@end

@interface TLEncryptedChat$encryptedChatEmpty : TLEncryptedChat


@end

@interface TLEncryptedChat$encryptedChatWaiting : TLEncryptedChat

@property (nonatomic) int64_t access_hash;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t admin_id;
@property (nonatomic) int32_t participant_id;

@end

@interface TLEncryptedChat$encryptedChatDiscarded : TLEncryptedChat


@end

@interface TLEncryptedChat$encryptedChatRequested : TLEncryptedChat

@property (nonatomic) int64_t access_hash;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t admin_id;
@property (nonatomic) int32_t participant_id;
@property (nonatomic, retain) NSData *g_a;

@end

@interface TLEncryptedChat$encryptedChat : TLEncryptedChat

@property (nonatomic) int64_t access_hash;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t admin_id;
@property (nonatomic) int32_t participant_id;
@property (nonatomic, retain) NSData *g_a_or_b;
@property (nonatomic) int64_t key_fingerprint;

@end

