#import <Foundation/Foundation.h>
#import <LegacyComponents/TGConversation.h>
#import "TGFeed.h"

@protocol TGDialogListItem <NSObject>

@property (nonatomic, readonly) int64_t conversationId;
@property (nonatomic, readonly) NSNumber *feedId;

@property (nonatomic) int32_t messageDate;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSArray *media;

@property (nonatomic) uint8_t kind;

@property (nonatomic, readonly) int32_t date;
@property (nonatomic, readonly) bool isChannel;
@property (nonatomic, readonly) bool isChannelGroup;
@property (nonatomic, readonly) int channelRole;

@property (nonatomic, assign) bool isDeleted;
@property (nonatomic, readonly) bool isDeactivated;

@property (nonatomic, readonly) bool isBroadcast;

@property (nonatomic) int32_t maxReadDate;

@property (nonatomic, readonly) bool isAd;

- (bool)pinnedToTop;

@end

@interface TGConversation (TGDialogListItem) <TGDialogListItem>

@end

@interface TGFeed (TGDialogListItem) <TGDialogListItem>

@end
