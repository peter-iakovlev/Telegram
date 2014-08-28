/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGActor.h"

#import "ASWatcher.h"

@class TGPreparedMessage;

@interface TGModernSendMessageActor : TGActor <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

@property (nonatomic, readonly) TGPreparedMessage *preparedMessage;
@property (nonatomic) float uploadProgress;

+ (NSTimeInterval)defaultTimeoutInterval;

- (void)setupFailTimeout:(NSTimeInterval)timeout;
- (void)restartFailTimeoutIfRunning;
- (NSString *)pathForLocalImagePath:(NSString *)path;

- (bool)_encryptUploads;
- (void)_commitSend;
- (void)_fail;
- (void)_success:(id)result;

- (void)uploadFilesWithExtensions:(NSArray *)filePathsAndExtensions;
- (void)beginUploadProgress;
- (void)uploadsStarted;
- (void)uploadProgressChanged;
- (void)uploadsCompleted:(NSDictionary *)filePathToUploadedFile;

- (int64_t)peerId;

@end
