#import "TGSearchSignals.h"

#import "TGChatListSignal.h"
#import "TGUserModel.h"
#import "TGGroupChatModel.h"
#import "TGPrivateChatModel.h"
#import "TGChannelChatModel.h"

@implementation TGSearchSignals

+ (SSignal *)contactUsers
{
    return nil;
}

static void enumerateStringParts(NSString *string, void (^block)(NSString *, bool *))
{
    static NSMutableCharacterSet *characterSet = nil;
    static NSCharacterSet *whitespaceCharacterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        characterSet = [[NSMutableCharacterSet alloc] init];
        [characterSet formUnionWithCharacterSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
        [characterSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        whitespaceCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    });
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:string];
    NSString *token = nil;
    bool stop = false;
    
    if ([scanner scanCharactersFromSet:characterSet intoString:&token])
    {
        token = [token stringByTrimmingCharactersInSet:whitespaceCharacterSet];
        if (token.length != 0)
        {
            block(token, &stop);
            if (stop)
                return;
        }
    }
    
    while ([scanner scanUpToCharactersFromSet:characterSet intoString:&token])
    {
        block(token, &stop);
        if (stop)
            return;
        
        if ([scanner scanCharactersFromSet:characterSet intoString:&token])
        {
            token = [token stringByTrimmingCharactersInSet:whitespaceCharacterSet];
            if (token.length != 0)
            {
                block(token, &stop);
                if (stop)
                    return;
            }
        }
    }
}

+ (SSignal *)searchChatsWithContext:(TGShareContext *)context chats:(NSArray *)chats users:(NSArray *)users query:(NSString *)query
{
    NSString *normalizedQuery = [query lowercaseString];
    
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        NSMutableArray *filteredChatModels = [[NSMutableArray alloc] init];
        NSMutableArray *filteredUserModels = [[NSMutableArray alloc] init];
        
        for (id chatModel in chats)
        {
            if ([chatModel isKindOfClass:[TGPrivateChatModel class]])
            {
                int32_t userId = ((TGPrivateChatModel *)chatModel).peerId.peerId;
                for (id model in users)
                {
                    if ([model isKindOfClass:[TGUserModel class]] && ((TGUserModel *)model).userId == userId)
                    {
                        TGUserModel *userModel = (TGUserModel *)model;
                        NSString *title = [[userModel displayName] lowercaseString];
                        __block bool matches = false;
                        enumerateStringParts(title, ^(NSString *part, bool *stop)
                        {
                            if ([[part lowercaseString] hasPrefix:normalizedQuery])
                            {
                                matches = true;
                                if (stop)
                                    *stop = true;
                            }
                        });
                        
                        if (matches)
                        {
                            [filteredChatModels addObject:chatModel];
                            [filteredUserModels addObject:userModel];
                        }
    
                        break;
                    }
                }
            }
            else if ([chatModel isKindOfClass:[TGGroupChatModel class]])
            {
                NSString *title = [((TGGroupChatModel *)chatModel).title lowercaseString];
                __block bool matches = false;
                enumerateStringParts(title, ^(NSString *part, bool *stop)
                {
                    if ([[part lowercaseString] hasPrefix:normalizedQuery])
                    {
                        matches = true;
                        if (stop)
                            *stop = true;
                    }
                });
                
                if (matches)
                    [filteredChatModels addObject:chatModel];
            }
            else if ([chatModel isKindOfClass:[TGChannelChatModel class]]) {
                NSString *title = [((TGChannelChatModel *)chatModel).title lowercaseString];
                __block bool matches = false;
                enumerateStringParts(title, ^(NSString *part, bool *stop)
                {
                    if ([[part lowercaseString] hasPrefix:normalizedQuery])
                    {
                        matches = true;
                        if (stop)
                            *stop = true;
                    }
                });
                
                if (matches)
                    [filteredChatModels addObject:chatModel];
            }
        }
        
        [subscriber putNext:@{@"chats": filteredChatModels, @"users": filteredUserModels}];
        [subscriber putCompletion];
        
        return nil;
    }];
}

+ (SSignal *)searchUsersWithContext:(TGShareContext *)context query:(NSString *)query
{
    if (query.length < 5)
        return [SSignal single:@{@"chats": @[], @"users": @[]}];
    
    return [[context function:[Api70 contacts_searchWithQ:query limit:@(100)]] map:^id(Api70_contacts_Found *result)
    {
        NSMutableArray *chatModels = [[NSMutableArray alloc] init];
        NSMutableArray *userModels = [[NSMutableArray alloc] init];
        
        for (Api70_User *user in result.users)
        {
            TGUserModel *userModel = [TGChatListSignal userModelWithApiUser:user];
            if (userModel != nil)
                [userModels addObject:userModel];
        }
        
        for (Api70_Peer *peerFound in result.results)
        {
            if ([peerFound isKindOfClass:[Api70_Peer_peerUser class]]) {
                int32_t userId = [((Api70_Peer_peerUser *)peerFound).userId intValue];
                
                for (TGUserModel *userModel in userModels)
                {
                    if (userModel.userId == userId)
                    {
                        [chatModels addObject:[[TGPrivateChatModel alloc] initWithUserId:userId]];
                        break;
                    }
                }
            }
        }
        
        return @{@"chats": chatModels, @"users": userModels};
    }];
}

@end
