#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLAudio : NSObject <TLObject>

@property (nonatomic) int64_t n_id;

@end

@interface TLAudio$audioEmpty : TLAudio


@end

@interface TLAudio$audio : TLAudio

@property (nonatomic) int64_t access_hash;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t duration;
@property (nonatomic, retain) NSString *mime_type;
@property (nonatomic) int32_t size;
@property (nonatomic) int32_t dc_id;

@end

