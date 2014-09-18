#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLFileLocation;

@interface TLChatPhoto : NSObject <TLObject>


@end

@interface TLChatPhoto$chatPhotoEmpty : TLChatPhoto


@end

@interface TLChatPhoto$chatPhoto : TLChatPhoto

@property (nonatomic, retain) TLFileLocation *photo_small;
@property (nonatomic, retain) TLFileLocation *photo_big;

@end

