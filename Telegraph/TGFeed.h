#import <Foundation/Foundation.h>

#import <LegacyComponents/PSKeyValueCoder.h>

@class TGFeedPosition;

@interface TGFeed : NSObject <PSCoding, NSCopying>

@property (nonatomic) int32_t fid;
@property (nonatomic) NSSet *channelIds;
@property (nonatomic) int32_t cachedChannelsHash;
@property (nonatomic) bool addsJoinedChannels;
@property (nonatomic) int32_t maxKnownMessageId;

@property (nonatomic) bool pinnedToTop;

@property (nonatomic) bool isDeleted;

@property (nonatomic) int32_t messageDate;
@property (nonatomic) int32_t minMessageDate;
@property (nonatomic) int32_t pinnedDate;
@property (nonatomic) int32_t maxReadDate;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSArray *media;

@property (nonatomic, strong) NSArray *chatIds;
@property (nonatomic, strong) NSArray *chatTitles;
@property (nonatomic, strong) NSArray *chatPhotosSmall;

@property (nonatomic) int32_t unreadCount;
@property (nonatomic) int32_t serviceUnreadCount;
@property (nonatomic, strong) TGFeedPosition *maxReadPosition;

- (int32_t)calculatedChannelsHash;
- (int32_t)date;

@end
