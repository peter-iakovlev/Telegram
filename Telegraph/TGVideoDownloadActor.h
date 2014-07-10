/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "ASActor.h"

#import "ASWatcher.h"

@interface TGVideoDownloadActor : ASActor <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

+ (void)rewriteLocalFilePath:(NSString *)localFilePath remoteUrl:(NSString *)remoteUrl;

+ (bool)isVideoDownloaded:(NSFileManager *)fileManager url:(NSString *)url;
+ (NSString *)localPathForVideoUrl:(NSString *)url;

- (void)videoPartDownloadSuccess:(int)offset length:(int)length data:(NSData *)data;
- (void)videoPartDownloadFailed:(int)offset length:(int)length;
- (void)videoPartDownloadProgress:(int)offset packetLength:(int)packetLength progress:(float)progress;

@end
