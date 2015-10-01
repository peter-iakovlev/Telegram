/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "ASWatcher.h"

typedef enum {
    TGDownloadItemClassThumbnail = 1,
    TGDownloadItemClassVideo = 2,
    TGDownloadItemClassImage = 3,
    TGDownloadItemClassDocument = 4,
    TGDownloadItemClassAudio = 5
} TGDownloadItemClass;

@interface TGDownloadItem : NSObject <NSCopying>

@property (nonatomic) id itemId;
@property (nonatomic) int messageId;
@property (nonatomic) int64_t groupId;
@property (nonatomic, strong) NSString *path;
@property (nonatomic) NSTimeInterval requestDate;
@property (nonatomic) float progress;

@end

@interface TGDownloadManager : NSObject <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

+ (TGDownloadManager *)instance;

- (void)requestItem:(NSString *)path options:(NSDictionary *)options changePriority:(bool)changePriority messageId:(int)messageId itemId:(id)itemId groupId:(int64_t)groupId itemClass:(TGDownloadItemClass)itemClass;
- (void)enqueueItem:(NSString *)path messageId:(int)messageId itemId:(id)itemId groupId:(int64_t)groupId itemClass:(TGDownloadItemClass)itemClass;
- (void)cancelItem:(id)itemId;
- (void)cancelItemsWithMessageIdsInArray:(NSArray *)messageIds groupId:(int64_t)groupId;
- (void)cancelItemsWithGroupId:(int64_t)groupId;

- (void)requestState:(ASHandle *)watcherHandle;

@end
