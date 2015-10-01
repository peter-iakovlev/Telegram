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

@class TGMapSnapshotOptions;
@class TGDocumentMediaAttachment;

@class SThreadPool;

@interface TGMediaPreviewTask : NSObject

- (void)executeWithWorkerTask:(TGWorkerTask *)workerTask workerPool:(TGWorkerPool *)workerPool;
- (void)executeWithWorkerTask:(TGWorkerTask *)workerTask threadPool:(SThreadPool *)workerPool;

- (void)executeWithTargetFilePath:(NSString *)targetFilePath uri:(NSString *)uri completion:(void (^)(bool))completion workerTask:(TGWorkerTask *)workerTask;
- (void)executeTempDownloadWithTargetFilePath:(NSString *)targetFilePath uri:(NSString *)uri progress:(void (^)(float))progress completionWithData:(void (^)(NSData *))completionWithData workerTask:(TGWorkerTask *)workerTask;
- (void)executeWithTargetFilePath:(NSString *)targetFilePath uri:(NSString *)uri progress:(void (^)(float))progress completion:(void (^)(bool))completion workerTask:(TGWorkerTask *)workerTask;
- (void)executeWithTargetFilePath:(NSString *)targetFilePath document:(TGDocumentMediaAttachment *)document progress:(void (^)(float))progress completion:(void (^)(bool))completion workerTask:(TGWorkerTask *)workerTask;
- (void)executeMultipartWithImageUri:(NSString *)imageUri targetFilePath:(NSString *)targetFilePath progress:(void (^)(float))progress completion:(void (^)(bool))completion;
- (void)executeWithMapSnapshotOptions:(TGMapSnapshotOptions *)snapshotOptions completionWithImage:(void (^)(UIImage *image))completionWithImage workerTask:(TGWorkerTask *)workerTask;

- (void)cancel;

@end
