#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLPhoneCallProtocol;
@class TLPhoneCallDiscardReason;
@class TLPhoneConnection;

@interface TLPhoneCall : NSObject <TLObject>

@property (nonatomic) int64_t n_id;

@end

@interface TLPhoneCall$phoneCallEmpty : TLPhoneCall


@end

@interface TLPhoneCall$phoneCallWaitingMeta : TLPhoneCall

@property (nonatomic) int32_t flags;
@property (nonatomic) int64_t access_hash;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t admin_id;
@property (nonatomic) int32_t participant_id;
@property (nonatomic, retain) TLPhoneCallProtocol *protocol;
@property (nonatomic) int32_t receive_date;

@end

@interface TLPhoneCall$phoneCallRequested : TLPhoneCall

@property (nonatomic) int64_t access_hash;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t admin_id;
@property (nonatomic) int32_t participant_id;
@property (nonatomic, retain) NSData *g_a_hash;
@property (nonatomic, retain) TLPhoneCallProtocol *protocol;

@end

@interface TLPhoneCall$phoneCallDiscardedMeta : TLPhoneCall

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) TLPhoneCallDiscardReason *reason;
@property (nonatomic) int32_t duration;

@end

@interface TLPhoneCall$phoneCallAccepted : TLPhoneCall

@property (nonatomic) int64_t access_hash;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t admin_id;
@property (nonatomic) int32_t participant_id;
@property (nonatomic, retain) NSData *g_b;
@property (nonatomic, retain) TLPhoneCallProtocol *protocol;

@end

@interface TLPhoneCall$phoneCall : TLPhoneCall

@property (nonatomic) int64_t access_hash;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t admin_id;
@property (nonatomic) int32_t participant_id;
@property (nonatomic, retain) NSData *g_a_or_b;
@property (nonatomic) int64_t key_fingerprint;
@property (nonatomic, retain) TLPhoneCallProtocol *protocol;
@property (nonatomic, retain) TLPhoneConnection *connection;
@property (nonatomic, retain) NSArray *alternative_connections;
@property (nonatomic) int32_t start_date;

@end

