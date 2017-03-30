#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLWebDocument : NSObject <TLObject>

@property (nonatomic, retain) NSString *url;
@property (nonatomic) int64_t access_hash;
@property (nonatomic) int32_t size;
@property (nonatomic, retain) NSString *mime_type;
@property (nonatomic, retain) NSArray *attributes;
@property (nonatomic) int32_t dc_id;

@end

@interface TLWebDocument$webDocument : TLWebDocument


@end

