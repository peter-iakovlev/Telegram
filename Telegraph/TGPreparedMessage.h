/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

@class TGMessage;
@class TGBotContextResultAttachment;
@class TGReplyMarkupAttachment;

@interface TGPreparedMessage : NSObject

@property (nonatomic) int64_t randomId;
@property (nonatomic) int32_t mid;
@property (nonatomic) int32_t date;
@property (nonatomic) bool isBroadcast;

@property (nonatomic) int32_t replacingMid;

@property (nonatomic) int32_t messageLifetime;

@property (nonatomic, strong) TGMessage *replyMessage;
@property (nonatomic, strong) TGBotContextResultAttachment *botContextResult;
@property (nonatomic, strong) TGReplyMarkupAttachment *replyMarkup;

@property (nonatomic, copy) void (^executeOnAdd)();

- (TGMessage *)message;

@end
