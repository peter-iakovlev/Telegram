/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPreparedMessage.h"

@class TGAudioMediaAttachment;
@class TGLiveUploadActorData;
@class TGDataItem;

@interface TGPreparedLocalAudioMessage : TGPreparedMessage

@property (nonatomic) int64_t localAudioId;
@property (nonatomic) int32_t duration;
@property (nonatomic) int32_t fileSize;

@property (nonatomic, strong) TGLiveUploadActorData *liveData;

@property (nonatomic, strong) TGMessage *replyMessage;

+ (instancetype)messageWithTempDataItem:(TGDataItem *)tempDataItem duration:(int32_t)duration replyMessage:(TGMessage *)replyMessage;
+ (instancetype)messageWithLocalAudioId:(int64_t)localAudioId duration:(int32_t)duration fileSize:(int32_t)fileSize replyMessage:(TGMessage *)replyMessage;
+ (instancetype)messageByCopyingDataFromMedia:(TGAudioMediaAttachment *)audioMedia replyMessage:(TGMessage *)replyMessage;
+ (instancetype)messageByCopyingDataFromMessage:(TGPreparedLocalAudioMessage *)source;

- (NSString *)localAudioFileDirectory;
+ (NSString *)localAudioFileDirectoryForLocalAudioId:(int64_t)audioId;
+ (NSString *)localAudioFileDirectoryForRemoteAudioId:(int64_t)audioId;

- (NSString *)localAudioFilePath1;
+ (NSString *)localAudioFilePathForLocalAudioId1:(int64_t)audioId;
+ (NSString *)localAudioFilePathForRemoteAudioId1:(int64_t)audioId;

@end
