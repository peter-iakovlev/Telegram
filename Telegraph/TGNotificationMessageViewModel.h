/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGMessageViewModel.h"

@class TGActionMediaAttachment;

@interface TGNotificationMessageViewModel : TGMessageViewModel

- (instancetype)initWithMessage:(TGMessage *)message actionMedia:(TGActionMediaAttachment *)actionMedia author:(TGUser *)author additionalUsers:(NSArray *)additionalUsers context:(TGModernViewContext *)context;

@end
