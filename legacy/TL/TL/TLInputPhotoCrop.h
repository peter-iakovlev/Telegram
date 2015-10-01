#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLInputPhotoCrop : NSObject <TLObject>


@end

@interface TLInputPhotoCrop$inputPhotoCropAuto : TLInputPhotoCrop


@end

@interface TLInputPhotoCrop$inputPhotoCrop : TLInputPhotoCrop

@property (nonatomic) double crop_left;
@property (nonatomic) double crop_top;
@property (nonatomic) double crop_width;

@end

