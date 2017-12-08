#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputMedia;

@interface TLInputSingleMedia : NSObject <TLObject>


@end

@interface TLInputSingleMedia$inputSingleMedia : TLInputSingleMedia

@property (nonatomic, retain) TLInputMedia *media;
@property (nonatomic) int64_t random_id;

@end

