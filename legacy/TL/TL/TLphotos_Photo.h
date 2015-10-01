#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLPhoto;

@interface TLphotos_Photo : NSObject <TLObject>

@property (nonatomic, retain) TLPhoto *photo;
@property (nonatomic, retain) NSArray *users;

@end

@interface TLphotos_Photo$photos_photo : TLphotos_Photo


@end

