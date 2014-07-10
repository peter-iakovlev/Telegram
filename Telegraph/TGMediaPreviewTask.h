/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

@class TGWorkerTask;
@class TGWorkerPool;

@interface TGMediaPreviewTask : NSObject

- (void)executeWithWorkerTask:(TGWorkerTask *)workerTask workerPool:(TGWorkerPool *)workerPool;
- (void)executeWithTargetFilePath:(NSString *)targetFilePath uri:(NSString *)uri completion:(void (^)(bool))completion workerTask:(TGWorkerTask *)workerTask;

- (void)cancel;

@end
