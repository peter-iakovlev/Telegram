#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLInputDocument : NSObject <TLObject>


@end

@interface TLInputDocument$inputDocumentEmpty : TLInputDocument


@end

@interface TLInputDocument$inputDocument : TLInputDocument

@property (nonatomic) int64_t n_id;
@property (nonatomic) int64_t access_hash;

@end

