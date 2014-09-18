#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLInputFileLocation : NSObject <TLObject>


@end

@interface TLInputFileLocation$inputFileLocation : TLInputFileLocation

@property (nonatomic) int64_t volume_id;
@property (nonatomic) int32_t local_id;
@property (nonatomic) int64_t secret;

@end

@interface TLInputFileLocation$inputVideoFileLocation : TLInputFileLocation

@property (nonatomic) int64_t n_id;
@property (nonatomic) int64_t access_hash;

@end

@interface TLInputFileLocation$inputEncryptedFileLocation : TLInputFileLocation

@property (nonatomic) int64_t n_id;
@property (nonatomic) int64_t access_hash;

@end

@interface TLInputFileLocation$inputAudioFileLocation : TLInputFileLocation

@property (nonatomic) int64_t n_id;
@property (nonatomic) int64_t access_hash;

@end

@interface TLInputFileLocation$inputDocumentFileLocation : TLInputFileLocation

@property (nonatomic) int64_t n_id;
@property (nonatomic) int64_t access_hash;

@end

