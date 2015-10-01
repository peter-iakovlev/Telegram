/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernConversationInputPanel.h"

@class HPGrowingTextView;
@class TGModernConversationInputTextPanel;
@class TGDocumentMediaAttachment;
@class TGModernConversationAssociatedInputPanel;
@class TGBotReplyMarkup;
@class TGViewController;

@protocol TGModernConversationInputTextPanelDelegate <TGModernConversationInputPanelDelegate>

- (void)inputTextPanelHasIndicatedTypingActivity:(TGModernConversationInputTextPanel *)inputTextPanel;
- (void)inputTextPanelHasCancelledTypingActivity:(TGModernConversationInputTextPanel *)inputTextPanel;
- (void)inputPanelRequestedSendMessage:(TGModernConversationInputTextPanel *)inputTextPanel text:(NSString *)text;
- (void)inputPanelRequestedAttachmentsMenu:(TGModernConversationInputTextPanel *)inputTextPanel;
- (void)inputPanelRequestedSendImages:(TGModernConversationInputTextPanel *)inputTextPanel images:(NSArray *)images;
- (void)inputPanelRequestedSendData:(TGModernConversationInputTextPanel *)inputTextPanel data:(NSData *)data;
- (void)inputPanelRequestedSendSticker:(TGModernConversationInputTextPanel *)inputTextPanel sticker:(TGDocumentMediaAttachment *)sticker;
- (void)inputPanelRequestedActivateCommand:(TGModernConversationInputTextPanel *)inputTextPanel command:(NSString *)command userId:(int32_t)userId messageId:(int32_t)messageId;
- (void)inputPanelTextChanged:(TGModernConversationInputTextPanel *)inputTextPanel text:(NSString *)text;
- (void)inputPanelMentionEntered:(TGModernConversationInputTextPanel *)inputTextPanel mention:(NSString *)mention;
- (void)inputPanelHashtagEntered:(TGModernConversationInputTextPanel *)inputTextPanel hashtag:(NSString *)hashtag;
- (void)inputPanelCommandEntered:(TGModernConversationInputTextPanel *)inputTextPanel command:(NSString *)hashtag;
- (void)inputPanelLinkParsed:(TGModernConversationInputTextPanel *)inputTextPanel link:(NSString *)link probablyComplete:(bool)probablyComplete;
- (bool)isInputPanelTextEnabled:(TGModernConversationInputTextPanel *)inputTextPanel;
- (void)inputPanelFocused:(TGModernConversationInputTextPanel *)inputTextPanel;

- (bool)inputPanelAudioRecordingEnabled:(TGModernConversationInputTextPanel *)inputTextPanel;
- (void)inputPanelAudioRecordingStart:(TGModernConversationInputTextPanel *)inputTextPanel;
- (void)inputPanelAudioRecordingCancel:(TGModernConversationInputTextPanel *)inputTextPanel;
- (void)inputPanelAudioRecordingComplete:(TGModernConversationInputTextPanel *)inputTextPanel;
- (NSTimeInterval)inputPanelAudioRecordingDuration:(TGModernConversationInputTextPanel *)inputTextPanel;

- (bool)inputPanelSendShouldBeAlwaysEnabled:(TGModernConversationInputTextPanel *)inputTextPanel;

- (TGViewController *)inputPanelParentViewController:(TGModernConversationInputTextPanel *)inputTextPanel;

- (void)inputPanelToggleBroadcastMode:(TGModernConversationInputTextPanel *)inputTextPanel;

@end

@interface TGModernConversationInputTextPanel : TGModernConversationInputPanel

@property (nonatomic, strong) UIImageView *fieldBackground;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *attachButton;

@property (nonatomic, strong) UIView *inputFieldClippingContainer;
@property (nonatomic, strong) HPGrowingTextView *inputField;
@property (nonatomic, strong) UIImageView *inputFieldPlaceholder;

@property (nonatomic, readonly) bool changingKeyboardMode;
@property (nonatomic) bool enableKeyboard;
@property (nonatomic) bool canShowKeyboardAutomatically;

@property (nonatomic, strong) UIView *panelAccessoryView;

@property (nonatomic, strong) TGBotReplyMarkup *replyMarkup;
@property (nonatomic) bool hasBots;
@property (nonatomic) bool canBroadcast;
@property (nonatomic) bool isBroadcasting;
@property (nonatomic) bool isAlwaysBroadcasting;
@property (nonatomic) bool isChannel;
@property (nonatomic) bool inputDisabled;

- (instancetype)initWithFrame:(CGRect)frame accessoryView:(UIView *)panelAccessoryView;

- (HPGrowingTextView *)maybeInputField;

- (void)audioRecordingStarted;
- (void)audioRecordingFinished;

- (void)shakeControls;

- (void)replaceMention:(NSString *)mention;
- (void)replaceHashtag:(NSString *)hashtag;

- (CGRect)attachmentButtonFrame;

- (void)setAssociatedStickerList:(NSArray *)stickerList stickerSelected:(void (^)(TGDocumentMediaAttachment *))stickerSelected;
- (void)setAssociatedPanel:(TGModernConversationAssociatedInputPanel *)associatedPanel animated:(bool)animated;
- (TGModernConversationAssociatedInputPanel *)associatedPanel;

- (void)setPrimaryExtendedPanel:(TGModernConversationAssociatedInputPanel *)extendedPanel animated:(bool)animated;
- (void)setPrimaryExtendedPanel:(TGModernConversationAssociatedInputPanel *)extendedPanel animated:(bool)animated skipHeightAnimation:(bool)skipHeightAnimation;
- (void)setSecondaryExtendedPanel:(TGModernConversationAssociatedInputPanel *)extendedPanel animated:(bool)animated;
- (void)setSecondaryExtendedPanel:(TGModernConversationAssociatedInputPanel *)extendedPanel animated:(bool)animated skipHeightAnimation:(bool)skipHeightAnimation;
- (TGModernConversationAssociatedInputPanel *)primaryExtendedPanel;
- (TGModernConversationAssociatedInputPanel *)secondaryExtendedPanel;

+ (NSString *)linkCandidateInText:(NSString *)text;

- (void)adjustCustomKeyboardForWidth:(CGFloat)width;

@end
