#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLFileHash : NSObject <TLObject>

@property (nonatomic) int32_t offset;
@property (nonatomic) int32_t limit;
@property (nonatomic, retain) NSData *n_hash;

@end

@interface TLFileHash$fileHash : TLFileHash


@end

