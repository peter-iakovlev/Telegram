/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPreparedMessage.h"

@class TGImageInfo;
@class TGBotContextResultAttachment;

@interface TGPreparedRemoteImageMessage : TGPreparedMessage

@property (nonatomic) int64_t imageId;
@property (nonatomic) int64_t accessHash;
@property (nonatomic, strong) TGImageInfo *imageInfo;

@property (nonatomic, strong) NSString *caption;

- (instancetype)initWithImageId:(int64_t)imageId accessHash:(int64_t)accessHash imageInfo:(TGImageInfo *)imageInfo caption:(NSString *)caption replyMessage:(TGMessage *)replyMessage botContextResult:(TGBotContextResultAttachment *)botContextResult replyMarkup:(TGReplyMarkupAttachment *)replyMarkup;;

+ (NSString *)filePathForRemoteImageId:(int64_t)imageId;

@end
