#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLFileLocation : NSObject <TLObject>

@property (nonatomic) int64_t volume_id;
@property (nonatomic) int32_t local_id;
@property (nonatomic) int64_t secret;

@end

@interface TLFileLocation$fileLocationUnavailable : TLFileLocation


@end

@interface TLFileLocation$fileLocation : TLFileLocation

@property (nonatomic) int32_t dc_id;

@end

