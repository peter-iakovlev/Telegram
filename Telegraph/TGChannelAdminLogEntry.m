#import "TGChannelAdminLogEntry.h"

#import "TL/TLMetaScheme.h"

#import "TGMessage+Telegraph.h"
#import "TGImageMediaAttachment+Telegraph.h"
#import "TGImageInfo+Telegraph.h"

#import "TGChannelManagementSignals.h"

@implementation TGChannelAdminLogEntry

- (instancetype)initWithEntryId:(int64_t)entryId timestamp:(int32_t)timestamp userId:(int32_t)userId content:(id<TGChannelAdminLogEntryContent>)content {
    self = [super init];
    if (self != nil) {
        _entryId = entryId;
        _timestamp = timestamp;
        _userId = userId;
        _content = content;
    }
    return self;
}

- (instancetype)initWithTL:(TLChannelAdminLogEvent *)event {
    id<TGChannelAdminLogEntryContent> content = nil;
    
    if ([event.action isKindOfClass:[TLChannelAdminLogEventAction$channelAdminLogEventActionChangeTitle class]]) {
        TLChannelAdminLogEventAction$channelAdminLogEventActionChangeTitle *action = (TLChannelAdminLogEventAction$channelAdminLogEventActionChangeTitle *)event.action;
        content = [[TGChannelAdminLogEntryChangeTitle alloc] initWithPreviousTitle:action.prev_value title:action.n_new_value];
    } else if ([event.action isKindOfClass:[TLChannelAdminLogEventAction$channelAdminLogEventActionChangeAbout class]]) {
        TLChannelAdminLogEventAction$channelAdminLogEventActionChangeAbout *action = (TLChannelAdminLogEventAction$channelAdminLogEventActionChangeAbout *)event.action;
        content = [[TGChannelAdminLogEntryChangeAbout alloc] initWithPreviousAbout:action.prev_value about:action.n_new_value];
    } else if ([event.action isKindOfClass:[TLChannelAdminLogEventAction$channelAdminLogEventActionChangeUsername class]]) {
        TLChannelAdminLogEventAction$channelAdminLogEventActionChangeUsername *action = (TLChannelAdminLogEventAction$channelAdminLogEventActionChangeUsername *)event.action;
        content = [[TGChannelAdminLogEntryChangeUsername alloc] initWithPreviousUsername:action.prev_value username:action.n_new_value];
    } else if ([event.action isKindOfClass:[TLChannelAdminLogEventAction$channelAdminLogEventActionChangePhoto class]]) {
        TLChannelAdminLogEventAction$channelAdminLogEventActionChangePhoto *action = (TLChannelAdminLogEventAction$channelAdminLogEventActionChangePhoto *)event.action;
        TGImageMediaAttachment *previousPhoto = nil;
        if ([action.prev_photo isKindOfClass:[TLChatPhoto$chatPhoto class]]) {
            TLChatPhoto$chatPhoto *concretePhoto = (TLChatPhoto$chatPhoto *)action.prev_photo;
            previousPhoto = [[TGImageMediaAttachment alloc] init];
            previousPhoto.imageInfo = [[TGImageInfo alloc] init];
            [previousPhoto.imageInfo addImageWithSize:CGSizeMake(160.0, 160.0) url:extractFileUrl(concretePhoto.photo_small)];
            [previousPhoto.imageInfo addImageWithSize:CGSizeMake(640.0, 640.0) url:extractFileUrl(concretePhoto.photo_big)];
        }
        TGImageMediaAttachment *photo = nil;
        if ([action.n_new_photo isKindOfClass:[TLChatPhoto$chatPhoto class]]) {
            TLChatPhoto$chatPhoto *concretePhoto = (TLChatPhoto$chatPhoto *)action.n_new_photo;
            photo = [[TGImageMediaAttachment alloc] init];
            photo.imageInfo = [[TGImageInfo alloc] init];
            [photo.imageInfo addImageWithSize:CGSizeMake(160.0, 160.0) url:extractFileUrl(concretePhoto.photo_small)];
            [photo.imageInfo addImageWithSize:CGSizeMake(640.0, 640.0) url:extractFileUrl(concretePhoto.photo_big)];
        }
        content = [[TGChannelAdminLogEntryChangePhoto alloc] initWithPreviousPhoto:previousPhoto photo:photo];
    } else if ([event.action isKindOfClass:[TLChannelAdminLogEventAction$channelAdminLogEventActionToggleInvites class]]) {
        TLChannelAdminLogEventAction$channelAdminLogEventActionToggleInvites *action = (TLChannelAdminLogEventAction$channelAdminLogEventActionToggleInvites *)event.action;
        content = [[TGChannelAdminLogEntryChangeInvites alloc] initWithValue:action.n_new_value];
    } else if ([event.action isKindOfClass:[TLChannelAdminLogEventAction$channelAdminLogEventActionToggleSignatures class]]) {
        TLChannelAdminLogEventAction$channelAdminLogEventActionToggleSignatures *action = (TLChannelAdminLogEventAction$channelAdminLogEventActionToggleSignatures *)event.action;
        content = [[TGChannelAdminLogEntryChangeSignatures alloc] initWithValue:action.n_new_value];
    } else if ([event.action isKindOfClass:[TLChannelAdminLogEventAction$channelAdminLogEventActionUpdatePinned class]]) {
        TLChannelAdminLogEventAction$channelAdminLogEventActionUpdatePinned *action = (TLChannelAdminLogEventAction$channelAdminLogEventActionUpdatePinned *)event.action;
        TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:action.message];
        content = [[TGChannelAdminLogEntryChangePinnedMessage alloc] initWithMessage:message.mid != 0 ? message : nil];
    } else if ([event.action isKindOfClass:[TLChannelAdminLogEventAction$channelAdminLogEventActionEditMessage class]]) {
        TLChannelAdminLogEventAction$channelAdminLogEventActionEditMessage *action = (TLChannelAdminLogEventAction$channelAdminLogEventActionEditMessage *)event.action;
        TGMessage *previousMessage = [[TGMessage alloc] initWithTelegraphMessageDesc:action.prev_message];
        TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:action.n_new_message];
        content = [[TGChannelAdminLogEntryEditMessage alloc] initWithPreviousMessage:previousMessage.mid != 0 ? previousMessage : nil message:message.mid != 0 ? message : nil];
    } else if ([event.action isKindOfClass:[TLChannelAdminLogEventAction$channelAdminLogEventActionDeleteMessage class]]) {
        TLChannelAdminLogEventAction$channelAdminLogEventActionDeleteMessage *action = (TLChannelAdminLogEventAction$channelAdminLogEventActionDeleteMessage *)event.action;
        TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:action.message];
        content = [[TGChannelAdminLogEntryDeleteMessage alloc] initWithMessage:message];
    } else if ([event.action isKindOfClass:[TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantJoin class]]) {
        content = [[TGChannelAdminLogEntryJoin alloc] init];
    } else if ([event.action isKindOfClass:[TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantLeave class]]) {
        content = [[TGChannelAdminLogEntryLeave alloc] init];
    } else if ([event.action isKindOfClass:[TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantInvite class]]) {
        TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantInvite *action = (TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantInvite *)event.action;
        content = [[TGChannelAdminLogEntryInvite alloc] initWithUserId:action.participant.user_id];
    } else if ([event.action isKindOfClass:[TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantToggleBan class]]) {
        TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantToggleBan *action = (TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantToggleBan *)event.action;
        
        TGChannelBannedRights *previousRights = [[TGChannelBannedRights alloc] initWithBanReadMessages:false banSendMessages:false banSendMedia:false banSendStickers:false banSendGifs:false banSendGames:false banSendInline:false banEmbedLinks:false timeout:0];
        TGChannelBannedRights *rights = [[TGChannelBannedRights alloc] initWithBanReadMessages:false banSendMessages:false banSendMedia:false banSendStickers:false banSendGifs:false banSendGames:false banSendInline:false banEmbedLinks:false timeout:0];
        
        TGCachedConversationMember *previousMember = [TGChannelManagementSignals parseMember:action.prev_participant];
        TGCachedConversationMember *member = [TGChannelManagementSignals parseMember:action.n_new_participant];
        
        if (previousMember.bannedRights != nil) {
            previousRights = previousMember.bannedRights;
        }
        
        if (member.bannedRights != nil) {
            rights = member.bannedRights;
        }
        
        content = [[TGChannelAdminLogEntryToggleBan alloc] initWithUserId:action.prev_participant.user_id previousRights:previousRights rights:rights];
    } else if ([event.action isKindOfClass:[TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantToggleAdmin class]]) {
        TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantToggleAdmin *action = (TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantToggleAdmin *)event.action;
        
        TGChannelAdminRights *previousRights = [[TGChannelAdminRights alloc] initWithCanChangeInfo:false canPostMessages:false canEditMessages:false canDeleteMessages:false canBanUsers:false canInviteUsers:false canChangeInviteLink:false canPinMessages:false canAddAdmins:false];
        TGChannelAdminRights *rights = [[TGChannelAdminRights alloc] initWithCanChangeInfo:false canPostMessages:false canEditMessages:false canDeleteMessages:false canBanUsers:false canInviteUsers:false canChangeInviteLink:false canPinMessages:false canAddAdmins:false];
        
        TGCachedConversationMember *previousMember = [TGChannelManagementSignals parseMember:action.prev_participant];
        TGCachedConversationMember *member = [TGChannelManagementSignals parseMember:action.n_new_participant];
        
        if (previousMember.adminRights != nil) {
            previousRights = previousMember.adminRights;
        }
        
        if (member.adminRights != nil) {
            rights = member.adminRights;
        }
        
        content = [[TGChannelAdminLogEntryToggleAdmin alloc] initWithUserId:action.prev_participant.user_id previousRights:previousRights rights:rights];
    }
    
    return [self initWithEntryId:event.n_id timestamp:event.date userId:event.user_id content:content];
}

@end

@implementation TGChannelAdminLogEntryChangeTitle

- (instancetype)initWithPreviousTitle:(NSString *)previousTitle title:(NSString *)title {
    self = [super init];
    if (self != nil) {
        _previousTitle = previousTitle;
        _title = title;
    }
    return self;
}

@end

@implementation TGChannelAdminLogEntryChangeAbout

- (instancetype)initWithPreviousAbout:(NSString *)previousAbout about:(NSString *)about {
    self = [super init];
    if (self != nil) {
        _previousAbout = previousAbout;
        _about = about;
    }
    return self;
}

@end

@implementation TGChannelAdminLogEntryChangeUsername

- (instancetype)initWithPreviousUsername:(NSString *)previousUsername username:(NSString *)username {
    self = [super init];
    if (self != nil) {
        _previousUsername = previousUsername;
        _username = username;
    }
    return self;
}

@end

@implementation TGChannelAdminLogEntryChangePhoto

- (instancetype)initWithPreviousPhoto:(TGImageMediaAttachment *)previousPhoto photo:(TGImageMediaAttachment *)photo {
    self = [super init];
    if (self != nil) {
        _previousPhoto = previousPhoto;
        _photo = photo;
    }
    return self;
}

@end

@implementation TGChannelAdminLogEntryChangeInvites

- (instancetype)initWithValue:(bool)value {
    self = [super init];
    if (self != nil) {
        _value = value;
    }
    return self;
}

@end

@implementation TGChannelAdminLogEntryChangeSignatures

- (instancetype)initWithValue:(bool)value {
    self = [super init];
    if (self != nil) {
        _value = value;
    }
    return self;
}

@end

@implementation TGChannelAdminLogEntryChangePinnedMessage

- (instancetype)initWithMessage:(TGMessage *)message {
    self = [super init];
    if (self != nil) {
        _message = message;
    }
    return self;
}

@end

@implementation TGChannelAdminLogEntryEditMessage

- (instancetype)initWithPreviousMessage:(TGMessage *)previousMessage message:(TGMessage *)message {
    self = [super init];
    if (self != nil) {
        _previousMessage = previousMessage;
        _message = message;
    }
    return self;
}

@end

@implementation TGChannelAdminLogEntryDeleteMessage

- (instancetype)initWithMessage:(TGMessage *)message {
    self = [super init];
    if (self != nil) {
        _message = message;
    }
    return self;
}

@end

@implementation TGChannelAdminLogEntryJoin

- (instancetype)init {
    self = [super init];
    if (self != nil) {
    }
    return self;
}

@end

@implementation TGChannelAdminLogEntryLeave
- (instancetype)init {
    self = [super init];
    if (self != nil) {
        
    }
    return self;
}

@end

@implementation TGChannelAdminLogEntryInvite

- (instancetype)initWithUserId:(int32_t)userId {
    self = [super init];
    if (self != nil) {
        _userId = userId;
    }
    return self;
}

@end

@implementation TGChannelAdminLogEntryToggleBan

- (instancetype)initWithUserId:(int32_t)userId previousRights:(TGChannelBannedRights *)previousRights rights:(TGChannelBannedRights *)rights {
    self = [super init];
    if (self != nil) {
        _userId = userId;
        _previousRights = previousRights;
        _rights = rights;
    }
    return self;
}

@end

@implementation TGChannelAdminLogEntryToggleAdmin

- (instancetype)initWithUserId:(int32_t)userId previousRights:(TGChannelAdminRights *)previousRights rights:(TGChannelAdminRights *)rights {
    self = [super init];
    if (self != nil) {
        _userId = userId;
        _previousRights = previousRights;
        _rights = rights;
    }
    return self;
}

@end

