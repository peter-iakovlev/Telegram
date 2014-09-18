/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGDataResource.h"

@interface TGImageManager : NSObject

+ (TGImageManager *)instance;

- (UIImage *)loadImageSyncWithUri:(NSString *)uri canWait:(bool)canWait decode:(bool)decode acceptPartialData:(bool)acceptPartialData asyncTaskId:(__autoreleasing id *)asyncTaskId progress:(void (^)(float))progress partialCompletion:(void (^)(UIImage *))partialCompletion completion:(void (^)(UIImage *))completion;
- (id)beginLoadingImageAsyncWithUri:(NSString *)uri decode:(bool)decode progress:(void (^)(float))progress partialCompletion:(void (^)(UIImage *))partialCompletion completion:(void (^)(UIImage *))completion;

- (TGDataResource *)loadDataSyncWithUri:(NSString *)uri canWait:(bool)canWait acceptPartialData:(bool)acceptPartialData asyncTaskId:(__autoreleasing id *)asyncTaskId progress:(void (^)(float))progress partialCompletion:(void (^)(TGDataResource *))partialCompletion completion:(void (^)(TGDataResource *))completion;
- (id)loadAttributeSyncForUri:(NSString *)uri attribute:(NSString *)attribute;

- (void)cancelTaskWithId:(id)taskId;

@end
