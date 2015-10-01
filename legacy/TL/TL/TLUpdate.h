#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLChatParticipants;
@class TLUserStatus;
@class TLPhoneCall;
@class TLPhoneConnection;
@class TLUserProfilePhoto;
@class TLEncryptedMessage;
@class TLEncryptedChat;
@class TLNotifyPeer;
@class TLPeerNotifySettings;
@class TLSendMessageAction;
@class TLMessageMedia;
@class TLPrivacyKey;
@class TLMessage;
@class TLPeer;
@class TLContactLink;
@class TLWebPage;
@class TLMessageGroup;

@interface TLUpdate : NSObject <TLObject>


@end

@interface TLUpdate$updateMessageID : TLUpdate

@property (nonatomic) int32_t n_id;
@property (nonatomic) int64_t random_id;

@end

@interface TLUpdate$updateRestoreMessages : TLUpdate

@property (nonatomic, retain) NSArray *messages;
@property (nonatomic) int32_t pts;

@end

@interface TLUpdate$updateChatParticipants : TLUpdate

@property (nonatomic, retain) TLChatParticipants *participants;

@end

@interface TLUpdate$updateUserStatus : TLUpdate

@property (nonatomic) int32_t user_id;
@property (nonatomic, retain) TLUserStatus *status;

@end

@interface TLUpdate$updateContactRegistered : TLUpdate

@property (nonatomic) int32_t user_id;
@property (nonatomic) int32_t date;

@end

@interface TLUpdate$updateContactLocated : TLUpdate

@property (nonatomic, retain) NSArray *contacts;

@end

@interface TLUpdate$updateActivation : TLUpdate

@property (nonatomic) int32_t user_id;

@end

@interface TLUpdate$updateNewAuthorization : TLUpdate

@property (nonatomic) int64_t auth_key_id;
@property (nonatomic) int32_t date;
@property (nonatomic, retain) NSString *device;
@property (nonatomic, retain) NSString *location;

@end

@interface TLUpdate$updatePhoneCallRequested : TLUpdate

@property (nonatomic, retain) TLPhoneCall *phone_call;

@end

@interface TLUpdate$updatePhoneCallConfirmed : TLUpdate

@property (nonatomic) int64_t n_id;
@property (nonatomic, retain) NSData *a_or_b;
@property (nonatomic, retain) TLPhoneConnection *connection;

@end

@interface TLUpdate$updatePhoneCallDeclined : TLUpdate

@property (nonatomic) int64_t n_id;

@end

@interface TLUpdate$updateUserPhoto : TLUpdate

@property (nonatomic) int32_t user_id;
@property (nonatomic) int32_t date;
@property (nonatomic, retain) TLUserProfilePhoto *photo;
@property (nonatomic) bool previous;

@end

@interface TLUpdate$updateNewEncryptedMessage : TLUpdate

@property (nonatomic, retain) TLEncryptedMessage *message;
@property (nonatomic) int32_t qts;

@end

@interface TLUpdate$updateEncryptedChatTyping : TLUpdate

@property (nonatomic) int32_t chat_id;

@end

@interface TLUpdate$updateEncryption : TLUpdate

@property (nonatomic, retain) TLEncryptedChat *chat;
@property (nonatomic) int32_t date;

@end

@interface TLUpdate$updateEncryptedMessagesRead : TLUpdate

@property (nonatomic) int32_t chat_id;
@property (nonatomic) int32_t max_date;
@property (nonatomic) int32_t date;

@end

@interface TLUpdate$updateChatParticipantDelete : TLUpdate

@property (nonatomic) int32_t chat_id;
@property (nonatomic) int32_t user_id;
@property (nonatomic) int32_t version;

@end

@interface TLUpdate$updateDcOptions : TLUpdate

@property (nonatomic, retain) NSArray *dc_options;

@end

@interface TLUpdate$updateUserBlocked : TLUpdate

@property (nonatomic) int32_t user_id;
@property (nonatomic) bool blocked;

@end

@interface TLUpdate$updateNotifySettings : TLUpdate

@property (nonatomic, retain) TLNotifyPeer *peer;
@property (nonatomic, retain) TLPeerNotifySettings *notify_settings;

@end

@interface TLUpdate$updateUserTyping : TLUpdate

@property (nonatomic) int32_t user_id;
@property (nonatomic, retain) TLSendMessageAction *action;

@end

@interface TLUpdate$updateChatUserTyping : TLUpdate

@property (nonatomic) int32_t chat_id;
@property (nonatomic) int32_t user_id;
@property (nonatomic, retain) TLSendMessageAction *action;

@end

@interface TLUpdate$updateUserName : TLUpdate

@property (nonatomic) int32_t user_id;
@property (nonatomic, retain) NSString *first_name;
@property (nonatomic, retain) NSString *last_name;
@property (nonatomic, retain) NSString *username;

@end

@interface TLUpdate$updateServiceNotification : TLUpdate

@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) TLMessageMedia *media;
@property (nonatomic) bool popup;

@end

@interface TLUpdate$updatePrivacy : TLUpdate

@property (nonatomic, retain) TLPrivacyKey *key;
@property (nonatomic, retain) NSArray *rules;

@end

@interface TLUpdate$updateUserPhone : TLUpdate

@property (nonatomic) int32_t user_id;
@property (nonatomic, retain) NSString *phone;

@end

@interface TLUpdate$updateNewMessage : TLUpdate

@property (nonatomic, retain) TLMessage *message;
@property (nonatomic) int32_t pts;
@property (nonatomic) int32_t pts_count;

@end

@interface TLUpdate$updateDeleteMessages : TLUpdate

@property (nonatomic, retain) NSArray *messages;
@property (nonatomic) int32_t pts;
@property (nonatomic) int32_t pts_count;

@end

@interface TLUpdate$updateReadHistoryInbox : TLUpdate

@property (nonatomic, retain) TLPeer *peer;
@property (nonatomic) int32_t max_id;
@property (nonatomic) int32_t pts;
@property (nonatomic) int32_t pts_count;

@end

@interface TLUpdate$updateReadHistoryOutbox : TLUpdate

@property (nonatomic, retain) TLPeer *peer;
@property (nonatomic) int32_t max_id;
@property (nonatomic) int32_t pts;
@property (nonatomic) int32_t pts_count;

@end

@interface TLUpdate$updateContactLink : TLUpdate

@property (nonatomic) int32_t user_id;
@property (nonatomic, retain) TLContactLink *my_link;
@property (nonatomic, retain) TLContactLink *foreign_link;

@end

@interface TLUpdate$updateReadMessagesContents : TLUpdate

@property (nonatomic, retain) NSArray *messages;
@property (nonatomic) int32_t pts;
@property (nonatomic) int32_t pts_count;

@end

@interface TLUpdate$updateChatParticipantAdd : TLUpdate

@property (nonatomic) int32_t chat_id;
@property (nonatomic) int32_t user_id;
@property (nonatomic) int32_t inviter_id;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t version;

@end

@interface TLUpdate$updateWebPage : TLUpdate

@property (nonatomic, retain) TLWebPage *webpage;
@property (nonatomic) int32_t pts;
@property (nonatomic) int32_t pts_count;

@end

@interface TLUpdate$updateChannelTooLong : TLUpdate

@property (nonatomic) int32_t channel_id;

@end

@interface TLUpdate$updateChannel : TLUpdate

@property (nonatomic) int32_t channel_id;

@end

@interface TLUpdate$updateChannelGroup : TLUpdate

@property (nonatomic) int32_t channel_id;
@property (nonatomic, retain) TLMessageGroup *group;

@end

@interface TLUpdate$updateNewChannelMessage : TLUpdate

@property (nonatomic, retain) TLMessage *message;
@property (nonatomic) int32_t pts;
@property (nonatomic) int32_t pts_count;

@end

@interface TLUpdate$updateReadChannelInbox : TLUpdate

@property (nonatomic) int32_t channel_id;
@property (nonatomic) int32_t max_id;

@end

@interface TLUpdate$updateDeleteChannelMessages : TLUpdate

@property (nonatomic) int32_t channel_id;
@property (nonatomic, retain) NSArray *messages;
@property (nonatomic) int32_t pts;
@property (nonatomic) int32_t pts_count;

@end

@interface TLUpdate$updateChannelMessageViews : TLUpdate

@property (nonatomic) int32_t channel_id;
@property (nonatomic) int32_t n_id;
@property (nonatomic) int32_t views;

@end

