/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPreparedMessage.h"

@class TGVideoInfo;
@class TGImageInfo;
@class TGVideoMediaAttachment;

@interface TGPreparedRemoteVideoMessage : TGPreparedMessage

@property (nonatomic) int64_t videoId;
@property (nonatomic) int64_t accessHash;
@property (nonatomic) CGSize videoSize;
@property (nonatomic) int32_t size;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic, strong) TGVideoInfo *videoInfo;
@property (nonatomic, strong) TGImageInfo *thumbnailInfo;

@property (nonatomic, strong) NSString *caption;

- (instancetype)initWithVideoId:(int64_t)videoId accessHash:(int64_t)accessHash videoSize:(CGSize)videoSize size:(int32_t)size duration:(NSTimeInterval)duration videoInfo:(TGVideoInfo *)videoInfo thumbnailInfo:(TGImageInfo *)thumbnailInfo caption:(NSString *)caption replyMessage:(TGMessage *)replyMessage replyMarkup:(TGReplyMarkupAttachment *)replyMarkup;

- (TGVideoMediaAttachment *)video;

@end
