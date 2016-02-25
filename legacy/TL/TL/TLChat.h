#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLChat : NSObject <TLObject>

@property (nonatomic) int32_t n_id;

@end

@interface TLChat$chatEmpty : TLChat


@end

@interface TLChat$channelForbidden : TLChat

@property (nonatomic) int64_t access_hash;
@property (nonatomic, retain) NSString *title;

@end

@interface TLChat$chatForbidden : TLChat

@property (nonatomic, retain) NSString *title;

@end

