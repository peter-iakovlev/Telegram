/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernConversationCompanion.h"

@class TGConversation;
@class TGConversationScrollState;
@class TGPIPSourceLocation;

@interface TGGenericModernConversationCompanion : TGModernConversationCompanion
{
    @public
    int64_t _conversationId;
    int64_t _attachedConversationId;
    int64_t _accessHash;
    
    bool _initialMayHaveUnreadMessages;
    bool _canResetInitialMessagePositioning;
    
    bool _everyMessageNeedsAuthor;
    bool _manualMessageManagement;
    
    int32_t _preferredInitialPositionedMessageId;
    TGConversationScrollState *_initialScrollState;
    TGPIPSourceLocation *_openPIPLocation;
}

@property (nonatomic, strong) NSNumber *botContextPeerId;
@property (nonatomic, strong) NSString *replaceInitialText;

- (instancetype)initWithConversation:(TGConversation *)conversation mayHaveUnreadMessages:(bool)mayHaveUnreadMessages;

- (void)setOthersUnreadCount:(int)unreadCount;
- (void)setPreferredInitialMessagePositioning:(int32_t)messageId pipLocation:(TGPIPSourceLocation *)pipLocation;
- (void)setInitialMessagePayloadWithForwardMessages:(NSArray *)initialForwardMessagePayload sendMessages:(NSArray *)initialSendMessagePayload sendFiles:(NSArray *)initialSendFilePayload;

- (int64_t)conversationId;
- (int64_t)messageAuthorPeerId;
- (bool)_shouldCacheRemoteAssetUris;
- (bool)_shouldDisplayProcessUnreadCount;
+ (CGSize)preferredInlineThumbnailSize;
- (int)messageLifetime;
- (NSUInteger)layer;
- (void)setLayer:(NSUInteger)layer;

- (void)loadInitialState:(bool)loadMessages;

- (NSString *)_conversationIdPathComponent;
- (NSString *)_sendMessagePathForMessageId:(int32_t)mid;
- (NSString *)_sendMessagePathPrefix;
- (NSDictionary *)_optionsForMessageActions;
- (void)_setupOutgoingMessage:(TGMessage *)message;
- (bool)_messagesNeedRandomId;
- (bool)canSendStickers;
- (bool)canSendMedia;
- (bool)canSendGifs;
- (bool)canSendGames;
- (bool)canSendInline;

- (void)standaloneForwardMessages:(NSArray *)messages;
- (void)standaloneSendMessages:(NSArray *)messages;
- (void)standaloneSendFiles:(NSArray *)files;
- (void)shareVCard;

- (void)scheduleReadHistory;

- (bool)shouldFastScrollDown;

- (void)updateMessagesLive:(NSDictionary *)messageIdToMessage animated:(bool)animated;

- (SSignal *)primaryTitlePanel;

- (bool)canAddNewMessagesToTop;

+ (bool)canDeleteMessageForEveryone:(TGMessage *)message peerId:(int64_t)peerId isPeerAdmin:(bool)isPeerAdmin;

@end
