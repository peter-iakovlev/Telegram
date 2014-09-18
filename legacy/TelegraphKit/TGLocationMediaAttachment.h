/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGMediaAttachment.h"

#define TGLocationMediaAttachmentType 0x0C9ED06E

@interface TGLocationMediaAttachment : TGMediaAttachment <TGMediaAttachmentParser>

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@end
