/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPreparedMessage.h"

@class TGVenueAttachment;

@interface TGPreparedMapMessage : TGPreparedMessage

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@property (nonatomic, strong) TGVenueAttachment *venue;

- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude venue:(TGVenueAttachment *)venue replyMessage:(TGMessage *)replyMessage replyMarkup:(TGReplyMarkupAttachment *)replyMarkup;

@end
