/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGMediaAttachment.h"

#import "TGImageInfo.h"

#define TGDocumentMediaAttachmentType ((int)0xE6C64318)

@interface TGDocumentMediaAttachment : TGMediaAttachment <TGMediaAttachmentParser>

@property (nonatomic) int64_t localDocumentId;

@property (nonatomic) int64_t documentId;
@property (nonatomic) int64_t accessHash;
@property (nonatomic) int datacenterId;
@property (nonatomic) int32_t userId;
@property (nonatomic) int date;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic) int size;
@property (nonatomic, strong) TGImageInfo *thumbnailInfo;

@property (nonatomic, strong) NSString *documentUri;

- (NSString *)safeFileName;
+ (NSString *)safeFileNameForFileName:(NSString *)fileName;

@end
