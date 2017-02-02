/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPreparedMessage.h"

@class TGDocumentMediaAttachment;
@class TGImageInfo;

@interface TGPreparedRemoteDocumentMessage : TGPreparedMessage

@property (nonatomic) int64_t documentId;
@property (nonatomic) int64_t accessHash;
@property (nonatomic) int datacenterId;
@property (nonatomic) int32_t userId;
@property (nonatomic) int documentDate;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic) int size;
@property (nonatomic, strong) TGImageInfo *thumbnailInfo;
@property (nonatomic, strong) NSArray *attributes;
@property (nonatomic, strong) NSString *caption;

- (instancetype)initWithDocumentMedia:(TGDocumentMediaAttachment *)documentMedia replyMessage:(TGMessage *)replyMessage botContextResult:(TGBotContextResultAttachment *)botContextResult replyMarkup:(TGReplyMarkupAttachment *)replyMarkup;;

- (TGDocumentMediaAttachment *)document;

@end
