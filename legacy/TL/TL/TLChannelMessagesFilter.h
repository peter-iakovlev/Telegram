#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLChannelMessagesFilter : NSObject <TLObject>


@end

@interface TLChannelMessagesFilter$channelMessagesFilterEmpty : TLChannelMessagesFilter


@end

@interface TLChannelMessagesFilter$channelMessagesFilter : TLChannelMessagesFilter

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) NSArray *ranges;

@end

@interface TLChannelMessagesFilter$channelMessagesFilterCollapsed : TLChannelMessagesFilter


@end

