#import "TGRecentContextBotsSignal.h"

#import "TGDatabase.h"

#import "TGTelegramNetworking.h"

@implementation TGRecentContextBotsSignal

+ (SQueue *)queue {
    static SQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[SQueue alloc] init];
    });
    return queue;
}

+ (SVariable *)_recentBots {
    static SVariable *variable = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        variable = [[SVariable alloc] init];
        [variable set:[self _loadRecentBots]];
    });
    return variable;
}

+ (SSignal *)_loadRecentBots {
    return [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"recentBots_v0"];
        if (data == nil) {
            [subscriber putNext:@[]];
            [subscriber putCompletion];
        } else {
            NSArray *array = nil;
            @try {
                array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            } @catch (NSException *e) {
            }
            if (array == nil) {
                [subscriber putNext:@[]];
                [subscriber putCompletion];
            } else {
                [subscriber putNext:array];
                [subscriber putCompletion];
            }
        }
        
        return nil;
    }] startOn:[self queue]];
}

+ (void)_storeRecentBots:(NSArray *)array {
    [[self queue] dispatch:^{
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:array] forKey:@"recentBots_v0"];
    }];
}

+ (void)clearRecentBots {
    [[self queue] dispatch:^{
        [self _storeRecentBots:@[]];
        [[self _recentBots] set:[SSignal single:@[]]];
    }];
}

+ (void)addRecentBot:(int32_t)userId {
    if (userId == 0) {
        return;
    }
    
    SSignal *signal = [[[[self _recentBots] signal] take:1] map:^id(NSArray *userIds) {
        NSMutableArray *updatedUserIds = [[NSMutableArray alloc] initWithArray:userIds];
        [updatedUserIds removeObject:@(userId)];
        [updatedUserIds insertObject:@(userId) atIndex:0];
        
        if (updatedUserIds.count > 128) {
            [updatedUserIds removeObjectsInRange:NSMakeRange(128, updatedUserIds.count - 128)];
        }
        
        [self _storeRecentBots:updatedUserIds];
        
        [TGDatabaseInstance() updatePeerRatings:@[[[TGPeerRatingUpdates alloc] initWithPeerId:userId category:TGPeerRatingCategoryInlineBots timestamps:@[@([TGTelegramNetworking instance].approximateRemoteTime)]]]];
        
        return updatedUserIds;
    }];
    [signal startWithNext:^(id next) {
        [[self _recentBots] set:[SSignal single:next]];
    }];
}

+ (SSignal *)recentBots {
    return [TGDatabaseInstance() modify:^id{
        NSMutableArray *userIds = [[NSMutableArray alloc] init];
        NSInteger count = 0;
        for (TGUser *user in [TGDatabaseInstance() _syncCachedRecentInlineBots:0.0f]) {
            [userIds addObject:@(user.uid)];
            count++;
            if (count == 5) {
                break;
            }
        }
        return userIds;
    }];
    //return [[self _recentBots] signal];
}

@end
