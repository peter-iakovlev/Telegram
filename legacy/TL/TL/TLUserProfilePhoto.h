#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLFileLocation;

@interface TLUserProfilePhoto : NSObject <TLObject>


@end

@interface TLUserProfilePhoto$userProfilePhotoEmpty : TLUserProfilePhoto


@end

@interface TLUserProfilePhoto$userProfilePhoto : TLUserProfilePhoto

@property (nonatomic) int64_t photo_id;
@property (nonatomic, retain) TLFileLocation *photo_small;
@property (nonatomic, retain) TLFileLocation *photo_big;

@end

