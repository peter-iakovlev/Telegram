#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLProtoMessage;

@interface TLProtoMessageCopy : NSObject <TLObject>

@property (nonatomic, retain) TLProtoMessage *orig_message;

@end

@interface TLProtoMessageCopy$msg_copy : TLProtoMessageCopy


@end

