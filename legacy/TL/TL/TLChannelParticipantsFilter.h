#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLChannelParticipantsFilter : NSObject <TLObject>


@end

@interface TLChannelParticipantsFilter$channelParticipantsRecent : TLChannelParticipantsFilter


@end

@interface TLChannelParticipantsFilter$channelParticipantsAdmins : TLChannelParticipantsFilter


@end

@interface TLChannelParticipantsFilter$channelParticipantsBanned : TLChannelParticipantsFilter

@property (nonatomic, retain) NSString *q;

@end

@interface TLChannelParticipantsFilter$channelParticipantsSearch : TLChannelParticipantsFilter

@property (nonatomic, retain) NSString *q;

@end

@interface TLChannelParticipantsFilter$channelParticipantsKicked : TLChannelParticipantsFilter

@property (nonatomic, retain) NSString *q;

@end

