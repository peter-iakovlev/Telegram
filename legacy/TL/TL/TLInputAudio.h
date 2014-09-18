#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLInputAudio : NSObject <TLObject>


@end

@interface TLInputAudio$inputAudioEmpty : TLInputAudio


@end

@interface TLInputAudio$inputAudio : TLInputAudio

@property (nonatomic) int64_t n_id;
@property (nonatomic) int64_t access_hash;

@end

