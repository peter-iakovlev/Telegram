#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLChatPhoto;
@class TLChannelAdminRights;

@interface TLChat : NSObject <TLObject>

@property (nonatomic) int32_t n_id;

@end

@interface TLChat$chatEmpty : TLChat


@end

@interface TLChat$chatForbidden : TLChat

@property (nonatomic, retain) NSString *title;

@end

@interface TLChat$channelMeta : TLChat

@property (nonatomic) int32_t flags;
@property (nonatomic) int64_t access_hash;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) TLChatPhoto *photo;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t version;
@property (nonatomic, retain) NSString *restriction_reason;
@property (nonatomic, retain) TLChannelAdminRights *admin_rights;

@end

@interface TLChat$channelForbiddenMeta : TLChat

@property (nonatomic) int32_t flags;
@property (nonatomic) int64_t access_hash;
@property (nonatomic, retain) NSString *title;
@property (nonatomic) int32_t until_date;

@end

