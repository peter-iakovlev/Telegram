#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLphotos_Photos : NSObject <TLObject>

@property (nonatomic, retain) NSArray *photos;
@property (nonatomic, retain) NSArray *users;

@end

@interface TLphotos_Photos$photos_photos : TLphotos_Photos


@end

@interface TLphotos_Photos$photos_photosSlice : TLphotos_Photos

@property (nonatomic) int32_t count;

@end

