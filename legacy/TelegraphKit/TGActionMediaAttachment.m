#import "TGActionMediaAttachment.h"

#import "TGImageMediaAttachment.h"

@implementation TGActionMediaAttachment

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.type = TGActionMediaAttachmentType;
    }
    return self;
}

- (void)serialize:(NSMutableData *)data
{
    int dataLengthPtr = (int)data.length;
    int zero = 0;
    [data appendBytes:&zero length:4];
    
    int actionType = _actionType;
    [data appendBytes:&actionType length:4];
    
    if (actionType == TGMessageActionChatAddMember || actionType == TGMessageActionChatDeleteMember)
    {
        int uid = [[_actionData objectForKey:@"uid"] intValue];
        [data appendBytes:&uid length:4];
    }
    else if (actionType == TGMessageActionJoinedByLink)
    {
        int uid = [[_actionData objectForKey:@"inviterId"] intValue];
        [data appendBytes:&uid length:4];
    }
    else if (actionType == TGMessageActionChatEditTitle)
    {
        NSString *title = [_actionData objectForKey:@"title"];
        NSData *titleData = [title dataUsingEncoding:NSUTF8StringEncoding];
        int length = (int)titleData.length;
        [data appendBytes:&length length:4];
        [data appendData:titleData];
    }
    else if (actionType == TGMessageActionCreateChat)
    {
        NSString *title = [_actionData objectForKey:@"title"];
        NSData *titleData = [title dataUsingEncoding:NSUTF8StringEncoding];
        int length = (int)titleData.length;
        [data appendBytes:&length length:4];
        [data appendData:titleData];
        
        NSArray *uids = [_actionData objectForKey:@"uids"];
        int count = (int)uids.count;
        [data appendBytes:&count length:4];
        for (NSNumber *nUid in uids)
        {
            int uid = [nUid intValue];
            [data appendBytes:&uid length:4];
        }
    }
    else if (actionType == TGMessageActionCreateBroadcastList)
    {
        NSString *title = [_actionData objectForKey:@"title"];
        NSData *titleData = [title dataUsingEncoding:NSUTF8StringEncoding];
        int length = (int)titleData.length;
        [data appendBytes:&length length:4];
        [data appendData:titleData];
        
        NSArray *uids = [_actionData objectForKey:@"uids"];
        int count = (int)uids.count;
        [data appendBytes:&count length:4];
        for (NSNumber *nUid in uids)
        {
            int uid = [nUid intValue];
            [data appendBytes:&uid length:4];
        }
    }
    else if (actionType == TGMessageActionChatEditPhoto)
    {
        TGImageMediaAttachment *photo = [_actionData objectForKey:@"photo"];
        if (photo != nil)
        {
            [photo serialize:data];
        }
    }
    else if (actionType == TGMessageActionContactRequest)
    {
        int hasPhone = [[_actionData objectForKey:@"hasPhone"] boolValue] ? 1 : 0;
        [data appendBytes:&hasPhone length:4];
    }
    else if (actionType == TGMessageActionAcceptContactRequest)
    {
    }
    else if (actionType == TGMessageActionContactRegistered)
    {
    }
    else if (actionType == TGMessageActionUserChangedPhoto)
    {
        TGImageMediaAttachment *photo = [_actionData objectForKey:@"photo"];
        if (photo != nil)
        {
            [photo serialize:data];
        }
    }
    else if (actionType == TGMessageActionEncryptedChatRequest)
    {
    }
    else if (actionType == TGMessageActionEncryptedChatAccept)
    {
        
    }
    else if (actionType == TGMessageActionEncryptedChatDecline)
    {
        
    }
    else if (actionType == TGMessageActionEncryptedChatMessageLifetime)
    {
        int32_t messageLifetime = [_actionData[@"messageLifetime"] intValue];
        [data appendBytes:&messageLifetime length:4];
    }
    else if (actionType == TGMessageActionEncryptedChatScreenshot)
    {   
    }
    else if (actionType == TGMessageActionChannelCreated)
    {
        NSString *title = [_actionData objectForKey:@"title"];
        NSData *titleData = [title dataUsingEncoding:NSUTF8StringEncoding];
        int length = (int)titleData.length;
        [data appendBytes:&length length:4];
        [data appendData:titleData];
    }
    else if (actionType == TGMessageActionChannelCommentsStatusChanged) {
        uint8_t enabled = [_actionData[@"enabled"] boolValue];
        [data appendBytes:&enabled length:1];
    } else if (actionType == TGMessageActionChannelInviter) {
        int32_t inviter = [_actionData[@"uid"] intValue];
        [data appendBytes:&inviter length:4];
    }
    
    int dataLength = (int)data.length - dataLengthPtr - 4;
    [data replaceBytesInRange:NSMakeRange(dataLengthPtr, 4) withBytes:&dataLength];
}

- (TGMediaAttachment *)parseMediaAttachment:(NSInputStream *)is
{
    int dataLength = 0;
    [is read:(uint8_t *)&dataLength maxLength:4];
    
    TGActionMediaAttachment *actionAttachment = [[TGActionMediaAttachment alloc] init];
    
    int actionType = 0;
    [is read:(uint8_t *)&actionType maxLength:4];
    actionAttachment.actionType = (TGMessageAction)actionType;
    
    if (actionType == TGMessageActionChatAddMember || actionType == TGMessageActionChatDeleteMember)
    {
        int uid = 0;
        [is read:(uint8_t *)&uid maxLength:4];
        actionAttachment.actionData = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:uid] forKey:@"uid"];
    }
    else if (actionType == TGMessageActionJoinedByLink)
    {
        int uid = 0;
        [is read:(uint8_t *)&uid maxLength:4];
        actionAttachment.actionData = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:uid] forKey:@"inviterId"];
    }
    else if (actionType == TGMessageActionChatEditTitle)
    {
        int length = 0;
        [is read:(uint8_t *)&length maxLength:4];
        uint8_t *titleBytes = malloc(length);
        [is read:titleBytes maxLength:length];
        NSString *title = [[NSString alloc] initWithBytesNoCopy:titleBytes length:length encoding:NSUTF8StringEncoding freeWhenDone:true];
        actionAttachment.actionData = [NSDictionary dictionaryWithObject:(title == nil ? @"" : title) forKey:@"title"];
    }
    else if (actionType == TGMessageActionCreateChat)
    {
        int length = 0;
        [is read:(uint8_t *)&length maxLength:4];
        uint8_t *titleBytes = malloc(length);
        [is read:titleBytes maxLength:length];
        NSString *title = [[NSString alloc] initWithBytesNoCopy:titleBytes length:length encoding:NSUTF8StringEncoding freeWhenDone:true];
        
        int count = 0;
        [is read:(uint8_t *)&count maxLength:4];
        NSMutableArray *uids = [[NSMutableArray alloc] initWithCapacity:count];
        for (int i = 0; i < count; i++)
        {
            int uid = 0;
            [is read:(uint8_t *)&uid maxLength:4];
            if (uid != 0)
                [uids addObject:[[NSNumber alloc] initWithInt:uid]];
        }
        
        actionAttachment.actionData = [[NSDictionary alloc] initWithObjectsAndKeys:(title == nil ? @"" : title), @"title", uids, @"uids", nil];
    }
    else if (actionType == TGMessageActionCreateBroadcastList)
    {
        int length = 0;
        [is read:(uint8_t *)&length maxLength:4];
        uint8_t *titleBytes = malloc(length);
        [is read:titleBytes maxLength:length];
        NSString *title = [[NSString alloc] initWithBytesNoCopy:titleBytes length:length encoding:NSUTF8StringEncoding freeWhenDone:true];
        
        int count = 0;
        [is read:(uint8_t *)&count maxLength:4];
        NSMutableArray *uids = [[NSMutableArray alloc] initWithCapacity:count];
        for (int i = 0; i < count; i++)
        {
            int uid = 0;
            [is read:(uint8_t *)&uid maxLength:4];
            if (uid != 0)
                [uids addObject:[[NSNumber alloc] initWithInt:uid]];
        }
        
        actionAttachment.actionData = [[NSDictionary alloc] initWithObjectsAndKeys:(title == nil ? @"" : title), @"title", uids, @"uids", nil];
    }
    else if (actionType == TGMessageActionChatEditPhoto)
    {
        TGImageMediaAttachment *photo = (TGImageMediaAttachment *)[[[TGImageMediaAttachment alloc] init] parseMediaAttachment:is];
        if (photo != nil)
            actionAttachment.actionData = [[NSDictionary alloc] initWithObjectsAndKeys:photo, @"photo", nil];
    }
    else if (actionType == TGMessageActionContactRequest)
    {
        int hasPhone = 0;
        [is read:(uint8_t *)&hasPhone maxLength:4];
        actionAttachment.actionData = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithBool:hasPhone != 0], @"hasPhone", nil];
    }
    else if (actionType == TGMessageActionAcceptContactRequest)
    {
    }
    else if (actionType == TGMessageActionContactRegistered)
    {
    }
    else if (actionType == TGMessageActionUserChangedPhoto)
    {
        TGImageMediaAttachment *photo = (TGImageMediaAttachment *)[[[TGImageMediaAttachment alloc] init] parseMediaAttachment:is];
        if (photo != nil)
            actionAttachment.actionData = [[NSDictionary alloc] initWithObjectsAndKeys:photo, @"photo", nil];
    }
    else if (actionType == TGMessageActionEncryptedChatRequest)
    {
    }
    else if (actionType == TGMessageActionEncryptedChatAccept)
    {
    }
    else if (actionType == TGMessageActionEncryptedChatDecline)
    {   
    }
    else if (actionType == TGMessageActionEncryptedChatMessageLifetime)
    {
        int32_t messageLifetime = 0;
        [is read:(uint8_t *)&messageLifetime maxLength:4];
        actionAttachment.actionData = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:messageLifetime], @"messageLifetime", nil];
    }
    else if (actionType == TGMessageActionEncryptedChatScreenshot)
    {
    }
    else if (actionType == TGMessageActionChannelCreated)
    {
        int length = 0;
        [is read:(uint8_t *)&length maxLength:4];
        uint8_t *titleBytes = malloc(length);
        [is read:titleBytes maxLength:length];
        NSString *title = [[NSString alloc] initWithBytesNoCopy:titleBytes length:length encoding:NSUTF8StringEncoding freeWhenDone:true];
        actionAttachment.actionData = [NSDictionary dictionaryWithObject:(title == nil ? @"" : title) forKey:@"title"];
    }
    else if (actionType == TGMessageActionChannelCommentsStatusChanged) {
        uint8_t enabled = 0;
        [is read:(uint8_t *)&enabled maxLength:1];
        actionAttachment.actionData = @{@"enabled": @(enabled != 0)};
    } else if (actionType == TGMessageActionChannelInviter) {
        int32_t uid = 0;
        [is read:(uint8_t *)&uid maxLength:4];
        actionAttachment.actionData = @{@"uid": @(uid)};
    }
    
    return actionAttachment;
}

@end
