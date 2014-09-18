#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLChatLocated : NSObject <TLObject>

@property (nonatomic) int32_t chat_id;
@property (nonatomic) int32_t distance;

@end

@interface TLChatLocated$chatLocated : TLChatLocated


@end

