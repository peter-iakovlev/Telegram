#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLConfig : NSObject <TLObject>

@property (nonatomic) int32_t date;
@property (nonatomic) bool test_mode;
@property (nonatomic) int32_t this_dc;
@property (nonatomic, retain) NSArray *dc_options;
@property (nonatomic) int32_t chat_size_max;
@property (nonatomic) int32_t broadcast_size_max;

@end

@interface TLConfig$config : TLConfig


@end

