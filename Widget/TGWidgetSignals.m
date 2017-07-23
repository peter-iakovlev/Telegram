#import "TGWidgetSignals.h"
#import <libkern/OSAtomic.h>
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>

#import "TGWidget.h"
#import <LegacyDatabase/LegacyDatabase.h>

NSString *const TGWidgetSyncIdentifier = @"org.telegram.WidgetUpdate";
const CGSize TGWidgetAvatarSize = { 56.0f, 56.0f };
const NSTimeInterval TGWidgetUpdateThrottleInterval = 20.0;

@implementation TGWidgetSignals

#pragma mark - Signal

static SVariable *topPeersVar;
static NSTimeInterval lastRefreshTime;
static NSDictionary *cachedUnreadCounts;

+ (SSignal *)resultSignalWithContext:(id)context users:(NSArray *)users unreadCounts:(NSDictionary *)unreadCounts
{
    if (context == nil)
        context = [NSNull null];
    if (users == nil)
        users = [[NSArray alloc] init];
    //if (unreadCounts == nil)
    unreadCounts = [[NSDictionary alloc] init];
    
    return [SSignal single:@{ @"context": context, @"users": users, @"unreadCounts": unreadCounts }];
}

+ (SSignal *)topPeersSignal
{
    SSignal *(^makeRemoteSignal)(TGShareContext *, NSArray *) = ^SSignal *(TGShareContext *context, NSArray *users)
    {
//        NSTimeInterval timeout = (TGWidgetUpdateThrottleInterval + lastRefreshTime) - CFAbsoluteTimeGetCurrent();
//        if (timeout < DBL_EPSILON)
//        {
//            lastRefreshTime = CFAbsoluteTimeGetCurrent();
//            return [[self remoteUnreadCountForUsers:users context:context] mapToSignal:^SSignal *(NSDictionary *unreadCounts)
//            {
//                cachedUnreadCounts = unreadCounts;
//                return [self resultSignalWithContext:context users:users unreadCounts:cachedUnreadCounts];
//            }];
//        }
//        else
//        {
            return [self resultSignalWithContext:context users:users unreadCounts:cachedUnreadCounts];
//        }
    };
    
    SSignal *(^makeLoadSignal)(bool) = ^SSignal *(bool fireInitialSignal)
    {
        return [[[TGWidget instance] shareContext] mapToSignal:^SSignal *(TGShareContext *context)
        {
            if ([context isKindOfClass:[TGShareContext class]])
            {
                TGLegacyDatabase *database = ((TGShareContext *)context).legacyDatabase;
                
                NSArray *users = [database topUsers];
                NSDictionary *unreadCounts = nil;
                SSignal *resultSignal = nil;
                
                if (fireInitialSignal)
                {
                    unreadCounts = [database unreadCountsForUsers:users];
                    cachedUnreadCounts = unreadCounts;
                    resultSignal = [self resultSignalWithContext:context users:users unreadCounts:cachedUnreadCounts];
                }
                
                SSignal *remoteSignal = makeRemoteSignal(context, users);
                if (resultSignal != nil)
                    return [resultSignal then:remoteSignal];
                else
                    return remoteSignal;
            }
            return [SSignal single:nil];
        }];
    };
    
    if (topPeersVar == nil)
    {
        topPeersVar = [[SVariable alloc] init];
        [topPeersVar set:makeLoadSignal(true)];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [topPeersVar set:makeLoadSignal(false)];
        });
    }
    
    return topPeersVar.signal;
}

+ (SSignal *)remoteUnreadCountForUsers:(NSArray *)users context:(TGShareContext *)context
{
    if (users.count == 0)
        return [SSignal single:[NSDictionary dictionary]];
    
    NSMutableArray *peers = [[NSMutableArray alloc] init];
    for (TGLegacyUser *user in users)
    {
        [peers addObject:[Api70_InputPeer inputPeerUserWithUserId:@(user.userId) accessHash:@(user.accessHash)]];
    }
    
    return [[context function:[Api70 messages_getPeerDialogsWithPeers:peers]] map:^id(Api70_messages_PeerDialogs *dialogs)
    {
        NSMutableDictionary *counts = [[NSMutableDictionary alloc] init];
        for (Api70_Dialog *dialog in dialogs.dialogs)
        {
            int32_t peerId = 0;
            if ([dialog.peer isKindOfClass:[Api70_Peer_peerUser class]])
                peerId = (int32_t)[[(Api70_Peer_peerUser *)dialog.peer userId] integerValue];
            
            if (peerId != 0)
                counts[@(peerId)] = dialog.unreadCount;
        }
        return counts;
    }];
}

#pragma mark - 

+ (SSignal *)userAvatarWithContext:(TGShareContext *)context user:(TGLegacyUser *)user
{
    if (user.photoSmall.length == 0)
        return [TGChatListAvatarSignal chatListAvatarWithContext:context letters:[self initialsForFirstName:user.firstName lastName:user.lastName] peerId:TGPeerIdPrivateMake(user.userId) imageSize:TGWidgetAvatarSize];
    else
        return [TGChatListAvatarSignal chatListAvatarWithContext:context location:[[TGFileLocation alloc] initWithFileUrl:user.photoSmall] imageSize:TGWidgetAvatarSize];
}

#pragma mark -

static bool isEmojiCharacter(NSString *singleChar)
{
    const unichar high = [singleChar characterAtIndex:0];
    
    if (0xd800 <= high && high <= 0xdbff && singleChar.length >= 2)
    {
        const unichar low = [singleChar characterAtIndex:1];
        const int codepoint = ((high - 0xd800) * 0x400) + (low - 0xdc00) + 0x10000;
        
        return (0x1d000 <= codepoint && codepoint <= 0x1f77f);
    }
    
    return (0x2100 <= high && high <= 0x27bf);
}

+ (NSString *)_cleanedUpString:(NSString *)string
{
    NSMutableString *__block buffer = [NSMutableString stringWithCapacity:string.length];
    
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length)
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock: ^(NSString* substring, __unused NSRange substringRange, __unused NSRange enclosingRange, __unused BOOL* stop)
     {
         [buffer appendString:isEmojiCharacter(substring) ? @"" : substring];
     }];
    
    return buffer;
}

+ (NSString *)initialsForFirstName:(NSString *)firstName lastName:(NSString *)lastName
{
    NSString *initials = @"";
    
    NSString *cleanFirstName = [self _cleanedUpString:firstName];
    NSString *cleanLastName = [self _cleanedUpString:lastName];
    
    if (cleanFirstName.length != 0 && cleanLastName.length != 0)
        initials = [[NSString alloc] initWithFormat:@"%@\u200B%@", [cleanFirstName substringToIndex:1], [cleanLastName substringToIndex:1]];
    else if (cleanFirstName.length != 0)
        initials = [cleanFirstName substringToIndex:1];
    else if (cleanLastName.length != 0)
        initials = [cleanLastName substringToIndex:1];
    
    return [initials uppercaseString];
}

@end
