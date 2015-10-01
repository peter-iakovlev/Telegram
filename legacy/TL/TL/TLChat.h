#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLChatPhoto;

@interface TLChat : NSObject <TLObject>

@property (nonatomic) int32_t n_id;

@end

@interface TLChat$chatEmpty : TLChat


@end

@interface TLChat$channelForbidden : TLChat

@property (nonatomic) int64_t access_hash;
@property (nonatomic, retain) NSString *title;

@end

@interface TLChat$chat : TLChat

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) TLChatPhoto *photo;
@property (nonatomic) int32_t participants_count;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t version;

@end

@interface TLChat$chatForbidden : TLChat

@property (nonatomic, retain) NSString *title;

@end

