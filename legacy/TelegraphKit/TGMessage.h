/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "TGActionMediaAttachment.h"
#import "TGMediaAttachment.h"
#import "TGImageMediaAttachment.h"
#import "TGLocationMediaAttachment.h"
#import "TGLocalMessageMetaMediaAttachment.h"
#import "TGVideoMediaAttachment.h"
#import "TGContactMediaAttachment.h"
#import "TGForwardedMessageMediaAttachment.h"
#import "TGUnsupportedMediaAttachment.h"
#import "TGDocumentMediaAttachment.h"
#import "TGAudioMediaAttachment.h"

typedef enum {
    TGMessageDeliveryStateDelivered = 0,
    TGMessageDeliveryStatePending = 1,
    TGMessageDeliveryStateFailed = 2
} TGMessageDeliveryState;

#define TGMessageLocalMidBaseline 800000000

@interface TGMessage : NSObject <NSCopying>

@property (nonatomic) int mid;
@property (nonatomic) bool unread;
@property (nonatomic) bool outgoing;
@property (nonatomic) TGMessageDeliveryState deliveryState;
@property (nonatomic) int64_t fromUid;
@property (nonatomic) int64_t toUid;
@property (nonatomic) int64_t cid;
@property (nonatomic, copy) NSString *text;
@property (nonatomic) NSTimeInterval date;
@property (nonatomic, strong) NSArray *mediaAttachments;

@property (nonatomic) int32_t realDate;
@property (nonatomic) int64_t randomId;

@property (nonatomic) int forwardUid;

@property (nonatomic, strong) TGActionMediaAttachment *actionInfo;

@property (nonatomic, strong) id additionalProperties;
@property (nonatomic, strong) id cachedLayoutData;

@property (nonatomic, strong) NSArray *textCheckingResults;

@property (nonatomic) int32_t messageLifetime;
@property (nonatomic) int64_t flags;

@property (nonatomic) bool isBroadcast;

- (bool)local;

+ (void)registerMediaAttachmentParser:(int)type parser:(id<TGMediaAttachmentParser>)parser;

- (NSData *)serializeMediaAttachments:(bool)includeMeta;
+ (NSData *)serializeMediaAttachments:(bool)includeMeta attachments:(NSArray *)attachments;
+ (NSData *)serializeAttachment:(TGMediaAttachment *)attachment;
+ (NSArray *)parseMediaAttachments:(NSData *)data;

@end

@interface TGMediaId : NSObject <NSCopying>

@property (nonatomic, readonly) uint8_t type;
@property (nonatomic, readonly) int64_t itemId;

- (id)initWithType:(uint8_t)type itemId:(int64_t)itemId;

@end

