#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLMessageFwdHeader : NSObject <TLObject>

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t from_id;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t channel_id;
@property (nonatomic) int32_t channel_post;
@property (nonatomic, retain) NSString *post_author;

@end

@interface TLMessageFwdHeader$messageFwdHeaderMeta : TLMessageFwdHeader


@end

