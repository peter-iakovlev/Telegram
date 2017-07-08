/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "ASWatcher.h"

#import <SSignalKit/SSignalKit.h>

@class TGModernViewInlineMediaContext;
@class TGConversation;
@class TGMessage;

typedef struct {
    int32_t mid;
    bool paused;
    float position;
} TGPlayingMessageStatus;

@interface TGModernViewContext : NSObject

@property (nonatomic) bool contentUpdatesDisabled;
@property (nonatomic, strong) ASHandle *companionHandle;
@property (nonatomic) bool editing;
@property (nonatomic) bool animationsEnabled;
@property (nonatomic) bool viewStatusEnabled;
@property (nonatomic) bool commandsEnabled;
@property (nonatomic, strong) NSString *searchText;
@property (nonatomic, strong) TGConversation *conversation;
@property (nonatomic, strong) TGConversation *conversationForUnreadCalculations;
@property (nonatomic) bool isBot;
@property (nonatomic) bool isPublicGroup;
@property (nonatomic) bool autoplayAnimations;

@property (nonatomic) bool outgoingMessagesAreAlwaysRead;
@property (nonatomic) bool isAdminLog;
@property (nonatomic) bool adminLogIsGroup;

@property (nonatomic, strong) SSignal *playingAudioMessageStatus;
@property (nonatomic, copy) void (^playAudioMessageId)(int32_t);
@property (nonatomic, copy) void (^resumeAudioMessage)();
@property (nonatomic, copy) void (^pauseAudioMessage)();

@property (nonatomic, strong) SSignal *callbackInProgress;

@property (nonatomic, copy) void (^replySwipeInteraction)(int32_t, bool);
@property (nonatomic, copy) bool (^canReplyToMessageId)(int32_t);

- (bool)isMediaVisibleInMessage:(int32_t)messageId;
- (bool)isMessageChecked:(int32_t)messageId;
- (bool)isSecretMessageViewed:(int32_t)messageId;
- (bool)isSecretMessageScreenshotted:(int32_t)messageId;
- (NSTimeInterval)secretMessageViewDate:(int32_t)messageId;

- (bool)isMessageUnread:(TGMessage *)message;

@end
