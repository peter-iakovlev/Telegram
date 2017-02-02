#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLDraftMessage : NSObject <TLObject>


@end

@interface TLDraftMessage$draftMessageEmpty : TLDraftMessage


@end

@interface TLDraftMessage$draftMessageMeta : TLDraftMessage

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t reply_to_msg_id;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSArray *entities;
@property (nonatomic) int32_t date;

@end

