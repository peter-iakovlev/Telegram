#import "TGUser+Telegraph.h"

#import "TGSchema.h"

#import "TGDatabase.h"

#import "TGTelegraph.h"

#import "TGImageInfo+Telegraph.h"

#import "TGStringUtils.h"

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
        return presence;
    }
    else if ([status isKindOfClass:[TLUserStatus$userStatusOffline class]])
    {
        TGUserPresence presence;
        presence.online = false;
        presence.lastSeen = ((TLUserStatus$userStatusOffline *)status).was_online;
        return presence;
    }
    else
    {
        TGUserPresence presence;
        presence.online = false;
        presence.lastSeen = 0;
        return presence;
    }
}

int extractUserLink(TLcontacts_Link *link)
{
    int value = TGUserLinkKnown;
    
    if ([link.my_link isKindOfClass:[TLcontacts_MyLink$contacts_myLinkRequested class]])
    {
        value |= TGUserLinkMyRequested;
        if (((TLcontacts_MyLink$contacts_myLinkRequested *)link.my_link).contact)
            value |= TGUserLinkMyContact;
    }
    else if ([link.my_link isKindOfClass:[TLcontacts_MyLink$contacts_myLinkContact class]])
        value |= TGUserLinkMyContact;
    
    if ([link.foreign_link isKindOfClass:[TLcontacts_ForeignLink$contacts_foreignLinkRequested class]])
    {
        value |= TGUserLinkForeignRequested;
        if (((TLcontacts_ForeignLink$contacts_foreignLinkRequested *)link.foreign_link).has_phone)
            value |= TGUserLinkForeignHasPhone;
    }
    else if ([link.foreign_link isKindOfClass:[TLcontacts_ForeignLink$contacts_foreignLinkMutual class]])
        value |= TGUserLinkForeignMutual;
    
    return value;
}

int extractUserLinkFromUpdate(TLUpdate$updateContactLink *linkUpdate)
{
    int value = TGUserLinkKnown;
    
    if ([linkUpdate.my_link isKindOfClass:[TLcontacts_MyLink$contacts_myLinkRequested class]])
    {
        value |= TGUserLinkMyRequested;
        if (((TLcontacts_MyLink$contacts_myLinkRequested *)linkUpdate.my_link).contact)
            value |= TGUserLinkMyContact;
    }
    else if ([linkUpdate.my_link isKindOfClass:[TLcontacts_MyLink$contacts_myLinkContact class]])
        value |= TGUserLinkMyContact;
    
    if ([linkUpdate.foreign_link isKindOfClass:[TLcontacts_ForeignLink$contacts_foreignLinkRequested class]])
    {
        value |= TGUserLinkForeignRequested;
        if (((TLcontacts_ForeignLink$contacts_foreignLinkRequested *)linkUpdate.foreign_link).has_phone)
            value |= TGUserLinkForeignHasPhone;
    }
    else if ([linkUpdate.foreign_link isKindOfClass:[TLcontacts_ForeignLink$contacts_foreignLinkMutual class]])
        value |= TGUserLinkForeignMutual;
    
    return value;
}

@implementation TGUser (Telegraph)

- (id)initWithTelegraphUserDesc:(TLUser *)user
{
    self = [super init];
    if (self != nil)
    {
        int uid = user.n_id;
        self.uid = uid;

        NSString *userPhone = nil;
        if ([user isKindOfClass:[TLUser$userSelf class]])
        {
            TLUser$userSelf *concreteUser = (TLUser$userSelf *)user;
            self.firstName = concreteUser.first_name;
            self.lastName = concreteUser.last_name;
            userPhone = concreteUser.phone;
            extractUserPhoto(concreteUser.photo, self);
            self.presence = extractUserPresence(concreteUser.status);
        }
        else if ([user isKindOfClass:[TLUser$userContact class]])
        {
            TLUser$userContact *concreteUser = (TLUser$userContact *)user;
            self.firstName = concreteUser.first_name;
            self.lastName = concreteUser.last_name;
            self.phoneNumberHash = concreteUser.access_hash;
            userPhone = concreteUser.phone;
            extractUserPhoto(concreteUser.photo, self);
            self.presence = extractUserPresence(concreteUser.status);
        }
        else if ([user isKindOfClass:[TLUser$userForeign class]])
        {
            TLUser$userForeign *concreteUser = (TLUser$userForeign *)user;
            self.firstName = concreteUser.first_name;
            self.lastName = concreteUser.last_name;
            self.phoneNumberHash = concreteUser.access_hash;
            extractUserPhoto(concreteUser.photo, self);
            self.presence = extractUserPresence(concreteUser.status);
        }
        else if ([user isKindOfClass:[TLUser$userRequest class]])
        {
            TLUser$userRequest *concreteUser = (TLUser$userRequest *)user;
            self.firstName = concreteUser.first_name;
            self.lastName = concreteUser.last_name;
            userPhone = concreteUser.phone;
            self.phoneNumberHash = concreteUser.access_hash;
            extractUserPhoto(concreteUser.photo, self);
            self.presence = extractUserPresence(concreteUser.status);
        }
        else if ([user isKindOfClass:[TLUser$userDeleted class]])
        {
            TLUser$userDeleted *concreteUser = (TLUser$userDeleted *)user;
            self.firstName = concreteUser.first_name;
            self.lastName = concreteUser.last_name;
            TGUserPresence presence;
            presence.online = false;
            presence.lastSeen = 0;
            self.presence = presence;
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
