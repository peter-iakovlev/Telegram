/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPreparedMessage.h"

@class TGVideoMediaAttachment;
@class TGLiveUploadActorData;

@interface TGPreparedLocalVideoMessage : TGPreparedMessage

@property (nonatomic) int64_t localVideoId;

@property (nonatomic) CGSize videoSize;
@property (nonatomic) int32_t size;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic, strong) NSString *localThumbnailDataPath;
@property (nonatomic) CGSize thumbnailSize;
@property (nonatomic, strong) NSString *assetUrl;

@property (nonatomic, strong) NSString *caption;

@property (nonatomic, strong) TGLiveUploadActorData *liveData;

- (NSString *)localVideoPath;

+ (instancetype)messageWithTempVideoPath:(NSString *)tempVideoPath videoSize:(CGSize)videoSize size:(int32_t)size duration:(NSTimeInterval)duration previewImage:(UIImage *)previewImage thumbnailSize:(CGSize)thumbnailSize assetUrl:(NSString *)assetUrl caption:(NSString *)caption replyMessage:(TGMessage *)replyMessage replyMarkup:(TGReplyMarkupAttachment *)replyMarkup;;
+ (instancetype)messageWithLocalVideoId:(int64_t)localVideoId videoSize:(CGSize)videoSize size:(int32_t)size duration:(NSTimeInterval)duration localThumbnailDataPath:(NSString *)localThumbnailDataPath thumbnailSize:(CGSize)thumbnailSize assetUrl:(NSString *)assetUrl caption:(NSString *)caption replyMessage:(TGMessage *)replyMessage replyMarkup:(TGReplyMarkupAttachment *)replyMarkup;;
+ (instancetype)messageByCopyingDataFromMedia:(TGVideoMediaAttachment *)videoAttachment replyMessage:(TGMessage *)replyMessage replyMarkup:(TGReplyMarkupAttachment *)replyMarkup;;
+ (instancetype)messageByCopyingDataFromMessage:(TGPreparedLocalVideoMessage *)source;

@end
