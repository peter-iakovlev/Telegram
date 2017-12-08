#import "TGSharedMediaCacheSignals.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGDatabase.h"

#import "TGModernConversationController.h"

@implementation TGSharedMediaCacheSignals

+ (SSignal *)cachedMediaForPeerId:(int64_t)peerId itemType:(TGSharedMediaCacheItemType)itemType important:(bool)important
{
    return [[SSignal alloc] initWithGenerator:^(SSubscriber *subscriber)
    {
        __block bool isCancelled = false;
        
        [TGDatabaseInstance() cachedMediaForPeerId:peerId itemType:itemType limit:128 important:important completion:^(NSArray *messages, __unused bool indexDownloaded)
        {
            [subscriber putNext:messages];
            
            [TGDatabaseInstance() cachedMediaForPeerId:peerId itemType:itemType limit:0 important:important completion:^(NSArray *messages, bool indexDownloaded)
            {
                [subscriber putNext:@(indexDownloaded)];
                [subscriber putNext:messages];
                
                if (indexDownloaded && TGPeerIdIsChannel(peerId)) {
                    TGConversationMigrationData *migrationData = [TGDatabaseInstance() _channelCachedDataSync:peerId].migrationData;
                    if (migrationData != nil) {
                        [TGDatabaseInstance() cachedMediaForPeerId:migrationData.peerId itemType:itemType limit:0 important:false completion:^(NSArray *migratedMessages, __unused bool indexDownloaded) {
                            NSMutableArray *updatedMessages = [[NSMutableArray alloc] init];
                            
                            for (TGMessage *message in migratedMessages) {
                                if (message.mid < TGMessageLocalMidBaseline) {
                                    message.mid += migratedMessageIdOffset;
                                    [updatedMessages addObject:message];
                                }
                            }
                            
                            [subscriber putNext:[messages arrayByAddingObjectsFromArray:updatedMessages]];
                            [subscriber putCompletion];
                        } buildIndex:false isCancelled:nil];
                    } else {
                        [subscriber putCompletion];
                    }
                } else {
                    [subscriber putCompletion];
                }
            } buildIndex:false isCancelled:nil];
        } buildIndex:peerId <= INT_MIN isCancelled:^bool
        {
            return isCancelled;
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            isCancelled = true;
        }];
    }];
}

@end
