/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPreparedMessage.h"

@class TGWebPageMediaAttachment;

@interface TGPreparedTextMessage : TGPreparedMessage

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) TGMessage *replyMessage;
@property (nonatomic) bool disableLinkPreviews;
@property (nonatomic, strong) TGWebPageMediaAttachment *parsedWebpage;

- (instancetype)initWithText:(NSString *)text replyMessage:(TGMessage *)replyMessage disableLinkPreviews:(bool)disableLinkPreviews parsedWebpage:(TGWebPageMediaAttachment *)parsedWebpage;

@end
