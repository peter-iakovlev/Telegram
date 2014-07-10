/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGImageMessageViewModel.h"

@class TGDocumentMediaAttachment;

@interface TGAnimatedImageMessageViewModel : TGImageMessageViewModel

- (instancetype)initWithMessage:(TGMessage *)message imageInfo:(TGImageInfo *)imageInfo document:(TGDocumentMediaAttachment *)document author:(TGUser *)author context:(TGModernViewContext *)context;

@end
