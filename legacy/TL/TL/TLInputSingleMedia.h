#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputMedia;

@interface TLInputSingleMedia : NSObject <TLObject>


@end

@interface TLInputSingleMedia$inputSingleMediaMeta : TLInputSingleMedia

@property (nonatomic, retain) TLInputMedia *media;
@property (nonatomic) int32_t flags;
@property (nonatomic) int64_t random_id;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSArray *entities;

@end

