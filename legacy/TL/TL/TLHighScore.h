#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLHighScore : NSObject <TLObject>

@property (nonatomic) int32_t pos;
@property (nonatomic) int32_t user_id;
@property (nonatomic) int32_t score;

@end

@interface TLHighScore$highScore : TLHighScore


@end

