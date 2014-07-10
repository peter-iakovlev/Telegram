/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGActor.h"

@class TGNetworkWorkerGuard;
@class TGLiveUploadActorData;

@interface TGLiveUploadActor : TGActor

- (void)updateSize:(NSUInteger)availableSize;
- (TGLiveUploadActorData *)finishRestOfFile:(NSUInteger)finalSize;
- (TGLiveUploadActorData *)finishRestOfFileWithHeader:(NSData *)header finalSize:(NSUInteger)finalSize;
- (void)completeWhenReady;
- (float)progress;

@end

@interface TGLiveUploadActorData : NSObject

@property (nonatomic, strong) NSString *path;

@end

@interface TGLiveUploadPart : NSObject

@property (nonatomic) int32_t partIndex;
@property (nonatomic) NSUInteger offset;
@property (nonatomic) NSUInteger length;

@end