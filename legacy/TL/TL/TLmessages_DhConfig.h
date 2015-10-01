#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLmessages_DhConfig : NSObject <TLObject>

@property (nonatomic, retain) NSData *random;

@end

@interface TLmessages_DhConfig$messages_dhConfigNotModified : TLmessages_DhConfig


@end

@interface TLmessages_DhConfig$messages_dhConfig : TLmessages_DhConfig

@property (nonatomic) int32_t g;
@property (nonatomic, retain) NSData *p;
@property (nonatomic) int32_t version;

@end

