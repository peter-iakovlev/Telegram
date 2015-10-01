/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPreparedMessage.h"

@class TGDocumentMediaAttachment;

@interface TGPreparedLocalDocumentMessage : TGPreparedMessage

@property (nonatomic) int64_t localDocumentId;
@property (nonatomic) int32_t size;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) NSString *localThumbnailDataPath;
@property (nonatomic) CGSize thumbnailSize;
@property (nonatomic, strong) NSArray *attributes;

@property (nonatomic, strong) TGMessage *replyMessage;

- (NSString *)localDocumentDirectory;
- (NSString *)localDocumentFileName;

+ (instancetype)messageWithTempDocumentPath:(NSString *)tempDocumentPath size:(int32_t)size mimeType:(NSString *)mimeType thumbnailImage:(UIImage *)thumbnailImage thumbnailSize:(CGSize)thumbnailSize attributes:(NSArray *)attributes replyMessage:(TGMessage *)replyMessage;
+ (instancetype)messageByCopyingDataFromMessage:(TGPreparedLocalDocumentMessage *)source;
+ (instancetype)messageByCopyingDataFromMedia:(TGDocumentMediaAttachment *)media replyMessage:(TGMessage *)replyMessage;
+ (instancetype)messageWithLocalDocumentId:(int64_t)localDocumentId size:(int32_t)size mimeType:(NSString *)mimeType localThumbnailDataPath:(NSString *)localThumbnailDataPath thumbnailSize:(CGSize)localThumbnailSize attributes:(NSArray *)attributes;

+ (NSString *)localDocumentDirectoryForLocalDocumentId:(int64_t)localDocumentId;
+ (NSString *)localDocumentDirectoryForDocumentId:(int64_t)documentId;

@end
