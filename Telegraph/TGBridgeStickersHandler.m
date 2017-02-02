#import "TGBridgeStickersHandler.h"
#import "TGBridgeStickersSubscription.h"
#import "TGBridgeServer.h"

#import "TGStickersSignals.h"

#import "TGBridgeStickerPack+TGStickerPack.h"
#import "TGBridgeDocumentMediaAttachment+TGDocumentMediaAttachment.h"

@implementation TGBridgeStickersHandler

+ (SSignal *)handlingSignalForSubscription:(TGBridgeSubscription *)subscription server:(TGBridgeServer *)server
{
    if ([subscription isKindOfClass:[TGBridgeRecentStickersSubscription class]])
    {
        TGBridgeRecentStickersSubscription *recentStickersSubscription = (TGBridgeRecentStickersSubscription *)subscription;
        NSUInteger limit = recentStickersSubscription.limit;
        
        return [[[server server] mapToSignal:^SSignal *(TGBridgeServer *server) {
            return [server serviceSignalForKey:@"stickers" producer:nil];
        }] map:^NSArray *(NSDictionary *dict)
        {
            NSArray *stickerPacks = dict[@"packs"];
            NSDictionary *documentIdsUseCount = dict[@"documentIdsUseCount"];
            
            NSMutableSet *processedDocumentIds = [[NSMutableSet alloc] init];
            NSMutableArray *bridgeRecentDocuments = [[NSMutableArray alloc] init];
            
            for (TGStickerPack *stickerPack in stickerPacks)
            {
                for (TGDocumentMediaAttachment *document in stickerPack.documents)
                {
                    if (![processedDocumentIds containsObject:@(document.documentId)] && documentIdsUseCount[@(document.documentId)] != nil)
                    {
                        TGBridgeDocumentMediaAttachment *bridgeDocument = [TGBridgeDocumentMediaAttachment attachmentWithTGDocumentMediaAttachment:document];
                        if (bridgeDocument != nil)
                            [bridgeRecentDocuments addObject:bridgeDocument];
                        
                        [processedDocumentIds addObject:@(document.documentId)];
                    }
                }
            }
            
            [bridgeRecentDocuments sortUsingComparator:^NSComparisonResult(TGBridgeDocumentMediaAttachment *document1, TGBridgeDocumentMediaAttachment *document2)
            {
                int useCount1 = [documentIdsUseCount[@(document1.documentId)] intValue];
                int useCount2 = [documentIdsUseCount[@(document2.documentId)] intValue];
                if (useCount1 > useCount2)
                    return NSOrderedAscending;
                else if (useCount1 < useCount2)
                    return NSOrderedDescending;
                return NSOrderedSame;
            }];
            
            if (bridgeRecentDocuments.count > limit)
                [bridgeRecentDocuments removeObjectsInRange:NSMakeRange(limit, bridgeRecentDocuments.count - limit)];
            
            return bridgeRecentDocuments;
        }];
    }
    
    return [SSignal fail:nil];
}

+ (NSArray *)handledSubscriptions
{
    return @[ [TGBridgeRecentStickersSubscription class] ];
}

@end
