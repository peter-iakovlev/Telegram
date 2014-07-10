#import "TGActionMediaAttachment+Telegraph.h"

#import "TGImageMediaAttachment+Telegraph.h"

@implementation TGActionMediaAttachment (Telegraph)

- (id)initWithTelegraphActionDesc:(TLMessageAction *)actionDesc
{
    self = [super init];
    if (self != nil)
    {
        self.type = TGActionMediaAttachmentType;
        
        if ([actionDesc isKindOfClass:[TLMessageAction$messageActionChatAddUser class]])
        {
            TLMessageAction$messageActionChatAddUser *concreteAction = (TLMessageAction$messageActionChatAddUser *)actionDesc;
            self.actionType = TGMessageActionChatAddMember;
            self.actionData = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:concreteAction.user_id] forKey:@"uid"];
        }
        else if ([actionDesc isKindOfClass:[TLMessageAction$messageActionChatDeleteUser class]])
        {
            TLMessageAction$messageActionChatDeleteUser *concreteAction = (TLMessageAction$messageActionChatDeleteUser *)actionDesc;
            self.actionType = TGMessageActionChatDeleteMember;
            self.actionData = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:concreteAction.user_id] forKey:@"uid"];
        }
        else if ([actionDesc isKindOfClass:[TLMessageAction$messageActionChatEditTitle class]])
        {
            TLMessageAction$messageActionChatEditTitle *concreteAction = (TLMessageAction$messageActionChatEditTitle *)actionDesc;
            self.actionType = TGMessageActionChatEditTitle;
            self.actionData = [NSDictionary dictionaryWithObject:(concreteAction.title == nil ? @"" : concreteAction.title) forKey:@"title"];
        }
        else if ([actionDesc isKindOfClass:[TLMessageAction$messageActionChatCreate class]])
        {
            TLMessageAction$messageActionChatCreate *concreteAction = (TLMessageAction$messageActionChatCreate *)actionDesc;
            self.actionType = TGMessageActionCreateChat;
            self.actionData = [[NSDictionary alloc] initWithObjectsAndKeys:concreteAction.title, @"title", concreteAction.users, @"uids", nil];
        }
        else if ([actionDesc isKindOfClass:[TLMessageAction$messageActionChatEditPhoto class]])
        {
            TLMessageAction$messageActionChatEditPhoto *concreteAction = (TLMessageAction$messageActionChatEditPhoto *)actionDesc;
            self.actionType = TGMessageActionChatEditPhoto;
            TGImageMediaAttachment *photo = [[TGImageMediaAttachment alloc] initWithTelegraphDesc:concreteAction.photo];
            self.actionData = [[NSDictionary alloc] initWithObjectsAndKeys: photo, @"photo", nil];
        }
        else if ([actionDesc isKindOfClass:[TLMessageAction$messageActionChatDeletePhoto class]])
        {
            self.actionType = TGMessageActionChatEditPhoto;
        }
        else if ([actionDesc isKindOfClass:[TLMessageAction$messageActionSentRequest class]])
        {
            self.actionType = TGMessageActionContactRequest;
            self.actionData = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithBool:((TLMessageAction$messageActionSentRequest *)actionDesc).has_phone], @"hasPhone", nil];
        }
        else if ([actionDesc isKindOfClass:[TLMessageAction$messageActionAcceptRequest class]])
        {
            self.actionType = TGMessageActionAcceptContactRequest;
        }
    }
    return self;
}

@end
