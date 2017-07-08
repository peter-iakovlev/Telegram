/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGImageMessageViewModel.h"

@class TGVideoMediaAttachment;
@class TGWebPageMediaAttachment;

@interface TGVideoMessageViewModel : TGImageMessageViewModel

- (instancetype)initWithMessage:(TGMessage *)message imageInfo:(TGImageInfo *)imageInfo video:(TGVideoMediaAttachment *)video authorPeer:(id)authorPeer context:(TGModernViewContext *)context forwardPeer:(id)forwardPeer forwardAuthor:(id)forwardAuthor forwardMessageId:(int32_t)forwardMessageId replyHeader:(TGMessage *)replyHeader replyAuthor:(id)replyAuthor viaUser:(TGUser *)viaUser webPage:(TGWebPageMediaAttachment *)webPage;

+ (NSString *)filePathForVideoId:(int64_t)videoId local:(bool)local;

@end
