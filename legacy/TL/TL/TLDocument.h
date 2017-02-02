#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLPhotoSize;

@interface TLDocument : NSObject <TLObject>

@property (nonatomic) int64_t n_id;

@end

@interface TLDocument$documentEmpty : TLDocument


@end

@interface TLDocument$document : TLDocument

@property (nonatomic) int64_t access_hash;
@property (nonatomic) int32_t date;
@property (nonatomic, retain) NSString *mime_type;
@property (nonatomic) int32_t size;
@property (nonatomic, retain) TLPhotoSize *thumb;
@property (nonatomic) int32_t dc_id;
@property (nonatomic) int32_t version;
@property (nonatomic, retain) NSArray *attributes;

@end

