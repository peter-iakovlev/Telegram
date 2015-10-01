#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputFile;
@class TLInputPhotoCrop;
@class TLInputPhoto;

@interface TLInputChatPhoto : NSObject <TLObject>


@end

@interface TLInputChatPhoto$inputChatPhotoEmpty : TLInputChatPhoto


@end

@interface TLInputChatPhoto$inputChatUploadedPhoto : TLInputChatPhoto

@property (nonatomic, retain) TLInputFile *file;
@property (nonatomic, retain) TLInputPhotoCrop *crop;

@end

@interface TLInputChatPhoto$inputChatPhoto : TLInputChatPhoto

@property (nonatomic, retain) TLInputPhoto *n_id;
@property (nonatomic, retain) TLInputPhotoCrop *crop;

@end

