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

@interface TGMessageEditingContext: NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSString *text;
@property (nonatomic, readonly) int32_t messageId;
@property (nonatomic, readonly) bool isCaption;

- (instancetype)initWithText:(NSString *)text isCaption:(bool)isCaption messageId:(int32_t)messageId;

@end

@protocol TGModernConversationInputTextPanelDelegate <TGModernConversationInputPanelDelegate>

- (void)inputTextPanelHasIndicatedTypingActivity:(TGModernConversationInputTextPanel *)inputTextPanel;
- (void)inputTextPanelHasCancelledTypingActivity:(TGModernConversationInputTextPanel *)inputTextPanel;
- (void)inputPanelRequestedSendMessage:(TGModernConversationInputTextPanel *)inputTextPanel text:(NSString *)text;
- (void)inputPanelRequestedAttachmentsMenu:(TGModernConversationInputTextPanel *)inputTextPanel;
- (void)inputPanelRequestedSendImages:(TGModernConversationInputTextPanel *)inputTextPanel images:(NSArray *)images;
- (void)inputPanelRequestedSendData:(TGModernConversationInputTextPanel *)inputTextPanel data:(NSData *)data;
- (void)inputPanelRequestedSendSticker:(TGModernConversationInputTextPanel *)inputTextPanel sticker:(TGDocumentMediaAttachment *)sticker;
- (void)inputPanelRequestedSendGif:(TGModernConversationInputTextPanel *)inputTextPanel document:(TGDocumentMediaAttachment *)document;
- (void)inputPanelRequestedActivateCommand:(TGModernConversationInputTextPanel *)inputTextPanel command:(NSString *)command userId:(int32_t)userId messageId:(int32_t)messageId;
- (void)inputPanelRequestedToggleCommandKeyboard:(TGModernConversationInputTextPanel *)inputTextPanel showCommandKeyboard:(bool)showCommandKeyboard;
- (void)inputPanelTextChanged:(TGModernConversationInputTextPanel *)inputTextPanel text:(NSString *)text;
- (void)inputPanelMentionEntered:(TGModernConversationInputTextPanel *)inputTextPanel mention:(NSString *)mention startOfLine:(bool)startOfLine;
- (void)inputPanelMentionTextEntered:(TGModernConversationInputTextPanel *)inputTextPanel mention:(NSString *)mention text:(NSString *)text;
- (void)inputPanelHashtagEntered:(TGModernConversationInputTextPanel *)inputTextPanel hashtag:(NSString *)hashtag;
- (void)inputPanelCommandEntered:(TGModernConversationInputTextPanel *)inputTextPanel command:(NSString *)hashtag;
- (void)inputPanelLinkParsed:(TGModernConversationInputTextPanel *)inputTextPanel link:(NSString *)link probablyComplete:(bool)probablyComplete;
- (bool)isInputPanelTextEnabled:(TGModernConversationInputTextPanel *)inputTextPanel;
- (void)inputPanelFocused:(TGModernConversationInputTextPanel *)inputTextPanel;

- (bool)inputPanelAudioRecordingEnabled:(TGModernConversationInputTextPanel *)inputTextPanel;
- (void)inputPanelAudioRecordingStart:(TGModernConversationInputTextPanel *)inputTextPanel completion:(void (^)())completion;
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

@property (nonatomic, strong) NSString *contextPlaceholder;

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
@property (nonatomic) bool displayProgress;

@property (nonatomic, strong) TGMessageEditingContext *messageEditingContext;

- (instancetype)initWithFrame:(CGRect)frame accessoryView:(UIView *)panelAccessoryView;

- (HPGrowingTextView *)maybeInputField;

- (void)audioRecordingStarted;
- (void)audioRecordingFinished;

- (void)shakeControls;

- (void)replaceMention:(NSString *)mention;
- (void)replaceHashtag:(NSString *)hashtag;

- (void)startMention;
- (void)startHashtag;
- (void)startCommand;

- (void)showStickersPanel;

- (CGRect)attachmentButtonFrame;
- (CGRect)stickerButtonFrame;
- (CGRect)broadcastModeButtonFrame;

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

+ (void)replaceMention:(NSString *)mention inputField:(HPGrowingTextView *)inputField;
+ (void)replaceHashtag:(NSString *)hashtag inputField:(HPGrowingTextView *)inputField;

- (void)adjustCustomKeyboardForWidth:(CGFloat)width;

- (void)animateRecordingIn;
- (void)addMicLevel:(CGFloat)level;

- (void)setMessageEditingContext:(TGMessageEditingContext *)messageEditingContext animated:(bool)animated;

@end
