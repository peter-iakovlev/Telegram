/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGImageMessageViewModel.h"

@class TGImageMediaAttachment;

@interface TGPhotoMessageViewModel : TGImageMessageViewModel

- (instancetype)initWithMessage:(TGMessage *)message imageMedia:(TGImageMediaAttachment *)imageMedia authorPeer:(id)authorPeer context:(TGModernViewContext *)context forwardPeer:(id)forwardPeer forwardMessageId:(int32_t)forwardMessageId replyHeader:(TGMessage *)replyHeader replyAuthor:(id)replyAuthor;

@end
