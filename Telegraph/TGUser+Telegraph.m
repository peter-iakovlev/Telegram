#import "TGUser+Telegraph.h"

#import "TGSchema.h"

#import "TGDatabase.h"

#import "TGTelegraph.h"

#import "TGImageInfo+Telegraph.h"

#import "TGStringUtils.h"

#import "TLUser$modernUser.h"

void extractUserPhoto(TLUserProfilePhoto *photo, TGUser *target)
{
    if ([photo isKindOfClass:[TLUserProfilePhoto$userProfilePhoto class]])
    {
        TLUserProfilePhoto$userProfilePhoto *profilePhoto = (TLUserProfilePhoto$userProfilePhoto *)photo;
        target.photoUrlSmall = extractFileUrl(profilePhoto.photo_small);
        target.photoUrlMedium = nil;
        target.photoUrlBig = extractFileUrl(profilePhoto.photo_big);
    }
    else
    {
        target.photoUrlSmall = nil;
        target.photoUrlMedium = nil;
        target.photoUrlBig = nil;
    }
}

TGUserPresence extractUserPresence(TLUserStatus *status)
{
    if ([status isKindOfClass:[TLUserStatus$userStatusOnline class]])
    {
        TGUserPresence presence;
        presence.online = true;
        presence.lastSeen = ((TLUserStatus$userStatusOnline *)status).expires;
        presence.temporaryLastSeen = 0;
        return presence;
    }
    else if ([status isKindOfClass:[TLUserStatus$userStatusOffline class]])
    {
        TGUserPresence presence;
        presence.online = false;
        presence.lastSeen = ((TLUserStatus$userStatusOffline *)status).was_online;
        presence.temporaryLastSeen = 0;
        
        return presence;
    }
    else if ([status isKindOfClass:[TLUserStatus$userStatusRecently class]])
    {
        TGUserPresence presence;
        presence.online = false;
        presence.lastSeen = TGUserPresenceValueLately;
        presence.temporaryLastSeen = 0;
        return presence;
    }
    else if ([status isKindOfClass:[TLUserStatus$userStatusLastWeek class]])
    {
        TGUserPresence presence;
        presence.online = false;
        presence.lastSeen = TGUserPresenceValueWithinAWeek;
        presence.temporaryLastSeen = 0;
        return presence;
    }
    else if ([status isKindOfClass:[TLUserStatus$userStatusLastMonth class]])
    {
        TGUserPresence presence;
        presence.online = false;
        presence.lastSeen = TGUserPresenceValueWithinAMonth;
        presence.temporaryLastSeen = 0;
        return presence;
    }
    else
    {
        TGUserPresence presence;
        presence.online = false;
        presence.lastSeen = TGUserPresenceValueALongTimeAgo;
        presence.temporaryLastSeen = 0;
        return presence;
    }
}

int extractUserLink(TLcontacts_Link *link)
{
    int value = 0;
    
    if ([link.my_link isKindOfClass:[TLContactLink$contactLinkContact class]])
        value |= TGUserLinkMyContact | TGUserLinkKnown;
    else if ([link.my_link isKindOfClass:[TLContactLink$contactLinkHasPhone class]])
        value |= TGUserLinkForeignHasPhone | TGUserLinkKnown;
    else if ([link.my_link isKindOfClass:[TLContactLink$contactLinkNone class]])
        value |= TGUserLinkKnown;
    
    if ([link.foreign_link isKindOfClass:[TLContactLink$contactLinkContact class]])
        value |= TGUserLinkForeignHasPhone | TGUserLinkKnown;
    else if ([link.foreign_link isKindOfClass:[TLContactLink$contactLinkHasPhone class]])
        value |= TGUserLinkForeignHasPhone | TGUserLinkKnown;
    else if ([link.foreign_link isKindOfClass:[TLContactLink$contactLinkNone class]])
        value |= TGUserLinkKnown;
    
    return value;
}

int extractUserLinkFromUpdate(TLUpdate$updateContactLink *linkUpdate)
{
    int value = 0;
    
    if ([linkUpdate.my_link isKindOfClass:[TLContactLink$contactLinkContact class]])
        value |= TGUserLinkMyContact | TGUserLinkKnown;
    else if ([linkUpdate.my_link isKindOfClass:[TLContactLink$contactLinkHasPhone class]])
        value |= TGUserLinkForeignHasPhone | TGUserLinkKnown;
    else if ([linkUpdate.my_link isKindOfClass:[TLContactLink$contactLinkNone class]])
        value |= TGUserLinkKnown;

    if ([linkUpdate.foreign_link isKindOfClass:[TLContactLink$contactLinkContact class]])
        value |= TGUserLinkForeignHasPhone | TGUserLinkKnown;
    else if ([linkUpdate.foreign_link isKindOfClass:[TLContactLink$contactLinkHasPhone class]])
        value |= TGUserLinkForeignHasPhone | TGUserLinkKnown;
    else if ([linkUpdate.foreign_link isKindOfClass:[TLContactLink$contactLinkNone class]])
        value |= TGUserLinkKnown;
    
    return value;
}

@implementation TGUser (Telegraph)

//user flags:# id:int access_hash:flags.0?long first_name:flags.1?string last_name:flags.2?string username:flags.3?string phone:flags.4?string photo:flags.5?UserProfilePhoto status:flags.6?UserStatus bot_info_version:flags.14?int = User;

- (id)initWithTelegraphUserDesc:(TLUser *)user
{
    self = [self init];
    if (self != nil)
    {
        int32_t uid = 0;
        NSString *userPhone = nil;
        if ([user isKindOfClass:[TLUser$modernUser class]])
        {
            TLUser$modernUser *concreteUser = (TLUser$modernUser *)user;
            
            uid = concreteUser.n_id;
            self.uid = uid;
            self.phoneNumberHash = concreteUser.access_hash;
            self.firstName = concreteUser.first_name;
            self.lastName = concreteUser.last_name;
            self.userName = concreteUser.username;
            userPhone = concreteUser.phone;
            extractUserPhoto(concreteUser.photo, self);
            self.presence = extractUserPresence(concreteUser.status);
            
            if (concreteUser.flags & (1 << 14))
                self.kind = TGUserKindBot;
            if (concreteUser.flags & (1 << 15))
                self.kind = TGUserKindSmartBot;
            self.botKind = (concreteUser.flags & (1 << 16)) ? TGBotKindPrivate : TGBotKindGeneric;
            self.botInfoVersion = concreteUser.bot_info_version;
            
            self.isVerified = concreteUser.flags & (1 << 17);
            self.hasExplicitContent = concreteUser.flags & (1 << 18);
            self.restrictionReason = concreteUser.restriction_reason;
            self.contextBotPlaceholder = concreteUser.inlineBotPlaceholder;
            self.isContextBot = concreteUser.flags & (1 << 19);
            self.minimalRepresentation = concreteUser.flags & (1 << 20);
            self.botInlineGeo = concreteUser.flags & (1 << 21);
        }
        else if ([user isKindOfClass:[TLUser$userEmpty class]])
        {
            uid = ((TLUser$userEmpty *)user).n_id;
            self.minimalRepresentation = true;
        }
        
        if (userPhone.length != 0)
        {
            if (![userPhone hasPrefix:@"+"])
                userPhone = [[NSString alloc] initWithFormat:@"+%@", userPhone];
            self.phoneNumber = userPhone;
        }
        
        if (uid != 0 && userPhone.length != 0)
        {   
            TGContactBinding *binding = [TGDatabaseInstance() contactBindingWithId:self.contactId];
            if (binding != nil)
            {
                if (uid != TGTelegraphInstance.clientUserId)
                {
                    self.phonebookFirstName = binding.firstName;
                    self.phonebookLastName = binding.lastName;
                }
            }
        }
    }
    return self;
}

@end
