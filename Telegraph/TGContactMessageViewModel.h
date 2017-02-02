/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGMessageViewModel.h"

#import "TGContentBubbleViewModel.h"

@interface TGContactMessageViewModel : TGMessageViewModel

- (instancetype)initWithMessage:(TGMessage *)message contact:(TGUser *)contact authorPeer:(id)authorPeer context:(TGModernViewContext *)context viaUser:(TGUser *)viaUser;

- (void)setForwardHeader:(id)forwardPeer forwardAuthor:(id)forwardAuthor messageId:(int32_t)messageId;
- (void)setReplyHeader:(TGMessage *)replyHeader peer:(id)peer;

@end
