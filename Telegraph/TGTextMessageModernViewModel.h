/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGContentBubbleViewModel.h"

@class TGMessage;
@class TGUser;
@class TGModernViewContext;

@interface TGTextMessageModernViewModel : TGContentBubbleViewModel

@property (nonatomic) bool animateContentChanges;

- (instancetype)initWithMessage:(TGMessage *)message hasGame:(bool)hasGame hasInvoice:(bool)hasInvoice authorPeer:(id)authorPeer viaUser:(TGUser *)viaUser context:(TGModernViewContext *)context;

- (void)setIsUnsupported:(bool)isUnsupported;

@end
