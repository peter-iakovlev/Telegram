#import <Foundation/Foundation.h>

#import "TGMessage.h"
#import "TGCachedConversationData.h"
#import "TGConversation.h"

@class TLChannelAdminLogEvent;

@protocol TGChannelAdminLogEntryContent <NSObject>

@end

@interface TGChannelAdminLogEntry : NSObject

@property (nonatomic, readonly) int64_t entryId;
@property (nonatomic, readonly) int32_t timestamp;
@property (nonatomic, readonly) int32_t userId;
@property (nonatomic, strong, readonly) id<TGChannelAdminLogEntryContent> content;

- (instancetype)initWithEntryId:(int64_t)entryId timestamp:(int32_t)timestamp userId:(int32_t)userId content:(id<TGChannelAdminLogEntryContent>)content;

- (instancetype)initWithTL:(TLChannelAdminLogEvent *)event;

@end

@interface TGChannelAdminLogEntryChangeTitle : NSObject <TGChannelAdminLogEntryContent>

@property (nonatomic, strong, readonly) NSString *previousTitle;
@property (nonatomic, strong, readonly) NSString *title;

- (instancetype)initWithPreviousTitle:(NSString *)previousTitle title:(NSString *)title;

@end

@interface TGChannelAdminLogEntryChangeAbout : NSObject <TGChannelAdminLogEntryContent>

@property (nonatomic, strong, readonly) NSString *previousAbout;
@property (nonatomic, strong, readonly) NSString *about;

- (instancetype)initWithPreviousAbout:(NSString *)previousAbout about:(NSString *)about;

@end

@interface TGChannelAdminLogEntryChangeUsername : NSObject <TGChannelAdminLogEntryContent>

@property (nonatomic, strong, readonly) NSString *previousUsername;
@property (nonatomic, strong, readonly) NSString *username;

- (instancetype)initWithPreviousUsername:(NSString *)previousUsername username:(NSString *)username;

@end

@interface TGChannelAdminLogEntryChangePhoto : NSObject <TGChannelAdminLogEntryContent>

@property (nonatomic, strong, readonly) TGImageMediaAttachment *previousPhoto;
@property (nonatomic, strong, readonly) TGImageMediaAttachment *photo;

- (instancetype)initWithPreviousPhoto:(TGImageMediaAttachment *)previousPhoto photo:(TGImageMediaAttachment *)photo;

@end

@interface TGChannelAdminLogEntryChangeInvites : NSObject <TGChannelAdminLogEntryContent>

@property (nonatomic, readonly) bool value;

- (instancetype)initWithValue:(bool)value;

@end

@interface TGChannelAdminLogEntryChangeSignatures : NSObject <TGChannelAdminLogEntryContent>

@property (nonatomic, readonly) bool value;

- (instancetype)initWithValue:(bool)value;

@end

@interface TGChannelAdminLogEntryChangePinnedMessage : NSObject <TGChannelAdminLogEntryContent>

@property (nonatomic, strong, readonly) TGMessage *message;

- (instancetype)initWithMessage:(TGMessage *)message;

@end

@interface TGChannelAdminLogEntryEditMessage : NSObject <TGChannelAdminLogEntryContent>

@property (nonatomic, strong, readonly) TGMessage *previousMessage;
@property (nonatomic, strong, readonly) TGMessage *message;

- (instancetype)initWithPreviousMessage:(TGMessage *)previousMessage message:(TGMessage *)message;

@end

@interface TGChannelAdminLogEntryDeleteMessage : NSObject <TGChannelAdminLogEntryContent>

@property (nonatomic, strong, readonly) TGMessage *message;

- (instancetype)initWithMessage:(TGMessage *)message;

@end

@interface TGChannelAdminLogEntryJoin : NSObject <TGChannelAdminLogEntryContent>

- (instancetype)init;

@end

@interface TGChannelAdminLogEntryLeave : NSObject <TGChannelAdminLogEntryContent>

- (instancetype)init;

@end

@interface TGChannelAdminLogEntryInvite : NSObject <TGChannelAdminLogEntryContent>

@property (nonatomic, readonly) int32_t userId;

- (instancetype)initWithUserId:(int32_t)userId;

@end

@interface TGChannelAdminLogEntryToggleBan : NSObject <TGChannelAdminLogEntryContent>

@property (nonatomic, readonly) int32_t userId;
@property (nonatomic, strong, readonly) TGChannelBannedRights *previousRights;
@property (nonatomic, strong, readonly) TGChannelBannedRights *rights;

- (instancetype)initWithUserId:(int32_t)userId previousRights:(TGChannelBannedRights *)previousRights rights:(TGChannelBannedRights *)rights;

@end

@interface TGChannelAdminLogEntryToggleAdmin : NSObject <TGChannelAdminLogEntryContent>

@property (nonatomic, readonly) int32_t userId;
@property (nonatomic, strong, readonly) TGChannelAdminRights *previousRights;
@property (nonatomic, strong, readonly) TGChannelAdminRights *rights;

- (instancetype)initWithUserId:(int32_t)userId previousRights:(TGChannelAdminRights *)previousRights rights:(TGChannelAdminRights *)rights;

@end


