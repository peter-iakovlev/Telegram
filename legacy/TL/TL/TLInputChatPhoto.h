#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputFile;
@class TLInputPhoto;

@interface TLInputChatPhoto : NSObject <TLObject>


@end

@interface TLInputChatPhoto$inputChatPhotoEmpty : TLInputChatPhoto


@end

@interface TLInputChatPhoto$inputChatUploadedPhoto : TLInputChatPhoto

@property (nonatomic, retain) TLInputFile *file;

@end

@interface TLInputChatPhoto$inputChatPhoto : TLInputChatPhoto

@property (nonatomic, retain) TLInputPhoto *n_id;

@end

