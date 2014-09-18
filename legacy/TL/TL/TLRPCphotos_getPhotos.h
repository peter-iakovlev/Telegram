#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLphotos_Photos;

@interface TLRPCphotos_getPhotos : TLMetaRpc

@property (nonatomic, retain) NSArray *n_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCphotos_getPhotos$photos_getPhotos : TLRPCphotos_getPhotos


@end

