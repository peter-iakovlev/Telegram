#import "TLUpdates+TG.h"

#import "TL/TLMetaScheme.h"

#import "TLUpdates$modernUpdateShortChatMessage.h"
#import "TLUpdates$modernUpdateShortMessage.h"
#import "TLMessage$modernMessage.h"
#import "TLUpdates$updateShortSentMessage.h"
#import "TLUpdate$updateChangePts.h"

@implementation TLUpdates (TG)

- (NSArray *)users
{
    if ([self isKindOfClass:[TLUpdates$updates class]])
        return ((TLUpdates$updates *)self).users;
    
    return @[];
}

- (NSArray *)chats
{
    if ([self isKindOfClass:[TLUpdates$updates class]])
        return ((TLUpdates$updates *)self).chats;
    
    return @[];
}

- (NSArray *)messages
{
    if ([self isKindOfClass:[TLUpdates$updates class]])
    {
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        
        for (id update in ((TLUpdates$updates *)self).updates)
        {
            if ([update isKindOfClass:[TLUpdate$updateNewMessage class]])
                [messages addObject:((TLUpdate$updateNewMessage *)update).message];
            else if ([update isKindOfClass:[TLUpdate$updateNewChannelMessage class]])
                [messages addObject:((TLUpdate$updateNewChannelMessage *)update).message];
            else if ([update isKindOfClass:[TLUpdate$updateEditChannelMessage class]])
                [messages addObject:((TLUpdate$updateEditChannelMessage *)update).message];
            else if ([update isKindOfClass:[TLUpdate$updateEditMessage class]])
                [messages addObject:((TLUpdate$updateEditMessage *)update).message];
        }
        
        return messages;
    }
    
    return @[];
}

- (TLMessage *)messageAtIndex:(NSUInteger)index pts:(int32_t *)pts pts_count:(int32_t *)pts_count
{
    NSInteger i = -1;
    if ([self isKindOfClass:[TLUpdates$updates class]])
    {
        for (id update in ((TLUpdates$updates *)self).updates)
        {
            if ([update isKindOfClass:[TLUpdate$updateNewMessage class]])
            {
                i++;
                if (i == (NSInteger)index)
                {
                    if (pts)
                        *pts = ((TLUpdate$updateNewMessage *)update).pts;
                    if (pts_count)
                        *pts_count = ((TLUpdate$updateNewMessage *)update).pts_count;
                    return ((TLUpdate$updateNewMessage *)update).message;
                }
            }
            else if ([update isKindOfClass:[TLUpdate$updateNewChannelMessage class]])
            {
                i++;
                if (i == (NSInteger)index)
                {
                    if (pts)
                        *pts = ((TLUpdate$updateNewChannelMessage *)update).pts;
                    if (pts_count)
                        *pts_count = ((TLUpdate$updateNewChannelMessage *)update).pts_count;
                    return ((TLUpdate$updateNewChannelMessage *)update).message;
                }
            }
        }
    }
    
    return nil;
}

- (bool)maxPtsAndCount:(int32_t *)pts ptsCount:(int32_t *)ptsCount
{
    bool single = true;
    int32_t maxPts = 0;
    int32_t maxPtsCount = 0;
    
    if ([self isKindOfClass:[TLUpdates$updates class]] || [self isKindOfClass:[TLUpdates$updatesCombined class]])
    {
        NSArray *containedUpdates = @[];
        
        if ([self isKindOfClass:[TLUpdates$updates class]])
        {
            TLUpdates$updates *updates = (TLUpdates$updates *)self;
            containedUpdates = updates.updates;
        }
        else if ([self isKindOfClass:[TLUpdates$updatesCombined class]])
        {
            TLUpdates$updatesCombined *updatesCombined = (TLUpdates$updatesCombined *)self;
            containedUpdates = updatesCombined.updates;
        }
        
        for (TLUpdate *update in containedUpdates)
        {
            if ([update hasPts])
            {
                NSAssert([update respondsToSelector:@selector(pts_count)], @"update with pts should also contain pts_count");
                if ([(TLUpdate$updateNewMessage *)update pts] > maxPts)
                {
                    if (maxPts != 0)
                        single = false;
                    maxPts = [(TLUpdate$updateNewMessage *)update pts];
                    maxPtsCount = [(TLUpdate$updateNewMessage *)update pts_count];
                }
            }
        }
    }
    else if ([self isKindOfClass:[TLUpdates$updateShort class]])
    {
        TLUpdates$updateShort *updateShort = (TLUpdates$updateShort *)self;
        if ([updateShort.update hasPts])
        {
            NSAssert([updateShort.update respondsToSelector:@selector(pts_count)], @"update with pts should also contain pts_count");
            
            if ([(TLUpdate$updateNewMessage *)updateShort.update pts] > maxPts)
            {
                if (maxPts != 0)
                    single = false;
                maxPts = [(TLUpdate$updateNewMessage *)updateShort.update pts];
                maxPtsCount = [(TLUpdate$updateNewMessage *)updateShort.update pts_count];
            }
        }
    }
    else if ([self isKindOfClass:[TLUpdates$modernUpdateShortChatMessage class]])
    {
        TLUpdates$modernUpdateShortChatMessage *updateShortChatMessage = (TLUpdates$modernUpdateShortChatMessage *)self;
        
        if (updateShortChatMessage.pts > maxPts)
        {
            if (maxPts != 0)
                single = false;
            maxPts = updateShortChatMessage.pts;
            maxPtsCount = updateShortChatMessage.pts_count;
        }
    }
    else if ([self isKindOfClass:[TLUpdates$modernUpdateShortMessage class]])
    {
        TLUpdates$modernUpdateShortMessage *updateShortMessage = (TLUpdates$modernUpdateShortMessage *)self;
        
        if (updateShortMessage.pts > maxPts)
        {
            if (maxPts != 0)
                single = false;
            maxPts = updateShortMessage.pts;
            maxPtsCount = updateShortMessage.pts_count;
        }
    }
    else if ([self isKindOfClass:[TLUpdates$updateShortSentMessage class]])
    {
        TLUpdates$updateShortSentMessage *updateShortSentMessage = (TLUpdates$updateShortSentMessage *)self;
        
        if (updateShortSentMessage.pts > maxPts)
        {
            if (maxPts != 0)
                single = false;
            maxPts = updateShortSentMessage.pts;
            maxPtsCount = updateShortSentMessage.pts_count;
        }
    }
    
    if (pts)
        *pts = maxPts;
    if (ptsCount)
        *ptsCount = maxPtsCount;
    
    return single;
}

- (int32_t)maxSeq
{
    if ([self isKindOfClass:[TLUpdates$updates class]] || [self isKindOfClass:[TLUpdates$updatesCombined class]])
    {
        return ((TLUpdates$updates *)self).seq;
    }
    
    return 0;
}

- (NSArray *)updatesList
{
    if ([self isKindOfClass:[TLUpdates$updates class]])
    {
        return ((TLUpdates$updates *)self).updates;
    }
    if ([self isKindOfClass:[TLUpdates$updatesCombined class]])
    {
        return ((TLUpdates$updatesCombined *)self).updates;
    }
    
    return @[];
}

@end

@implementation TLUpdate (TG)

- (bool)hasPts
{
    if ([self isKindOfClass:[TLUpdate$updateNewMessage class]]) {
        return true;
    } else if ([self isKindOfClass:[TLUpdate$updateEditMessage class]]) {
        return true;
    } else if ([self isKindOfClass:[TLUpdate$updateDeleteMessages class]]) {
        return true;
    } else if ([self isKindOfClass:[TLUpdate$updateReadHistoryInbox class]]) {
        return true;
    } else if ([self isKindOfClass:[TLUpdate$updateReadHistoryOutbox class]]) {
        return true;
    } else if ([self isKindOfClass:[TLUpdate$updateReadMessagesContents class]]) {
        return true;
    } else if ([self isKindOfClass:[TLUpdate$updateChangePts class]]) {
        return true;
    } else if ([self isKindOfClass:[TLUpdate$updateWebPage class]]) {
        return true;
    }
    return false;
}

@end
