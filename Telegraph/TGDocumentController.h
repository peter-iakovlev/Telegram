/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGViewController.h"

#import <QuickLook/QuickLook.h>

@interface TGDocumentController : QLPreviewController

- (instancetype)initWithURL:(NSURL *)url messageId:(int32_t)messageId;

@end
