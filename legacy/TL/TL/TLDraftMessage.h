#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLDraftMessage : NSObject <TLObject>

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t date;

@end

@interface TLDraftMessage$draftMessageEmptyMeta : TLDraftMessage


@end

@interface TLDraftMessage$draftMessageMeta : TLDraftMessage

@property (nonatomic) int32_t reply_to_msg_id;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSArray *entities;

@end

