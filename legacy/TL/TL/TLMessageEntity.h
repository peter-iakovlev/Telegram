#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputUser;

@interface TLMessageEntity : NSObject <TLObject>

@property (nonatomic) int32_t offset;
@property (nonatomic) int32_t length;

@end

@interface TLMessageEntity$messageEntityUnknown : TLMessageEntity


@end

@interface TLMessageEntity$messageEntityMention : TLMessageEntity


@end

@interface TLMessageEntity$messageEntityHashtag : TLMessageEntity


@end

@interface TLMessageEntity$messageEntityBotCommand : TLMessageEntity


@end

@interface TLMessageEntity$messageEntityUrl : TLMessageEntity


@end

@interface TLMessageEntity$messageEntityEmail : TLMessageEntity


@end

@interface TLMessageEntity$messageEntityBold : TLMessageEntity


@end

@interface TLMessageEntity$messageEntityItalic : TLMessageEntity


@end

@interface TLMessageEntity$messageEntityCode : TLMessageEntity


@end

@interface TLMessageEntity$messageEntityPre : TLMessageEntity

@property (nonatomic, retain) NSString *language;

@end

@interface TLMessageEntity$messageEntityTextUrl : TLMessageEntity

@property (nonatomic, retain) NSString *url;

@end

@interface TLMessageEntity$messageEntityMentionName : TLMessageEntity

@property (nonatomic) int32_t user_id;

@end

@interface TLMessageEntity$inputMessageEntityMentionName : TLMessageEntity

@property (nonatomic, retain) TLInputUser *user_id;

@end

