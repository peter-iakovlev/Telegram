/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernConversationInputPanel.h"

#import "TGModernButton.h"

@class HPGrowingTextView;
@class TGModernConversationInputTextPanel;
@class TGDocumentMediaAttachment;
@class TGModernConversationAssociatedInputPanel;
@class TGBotReplyMarkup;
@class TGBotReplyMarkupButton;
@class TGViewController;
@class TGUser;
@class TGModernConversationInputMicButton;

@interface TGMessageEditingContext: NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSString *text;
@property (nonatomic, strong, readonly) NSArray *entities;
@property (nonatomic, readonly) int32_t messageId;
@property (nonatomic, readonly) bool isCaption;

+ (NSAttributedString *)attributedStringForText:(NSString *)text entities:(NSArray *)entities;

- (instancetype)initWithText:(NSString *)text entities:(NSArray *)entities isCaption:(bool)isCaption messageId:(int32_t)messageId;

@end

@protocol TGModernConversationInputTextPanelDelegate <TGModernConversationInputPanelDelegate>

- (void)inputTextPanelHasIndicatedTypingActivity:(TGModernConversationInputTextPanel *)inputTextPanel;
- (void)inputTextPanelHasCancelledTypingActivity:(TGModernConversationInputTextPanel *)inputTextPanel;
- (void)inputPanelRequestedSendMessage:(TGModernConversationInputTextPanel *)inputTextPanel text:(NSString *)text;
- (void)inputPanelRequestedSendMessage:(TGModernConversationInputTextPanel *)inputTextPanel text:(NSString *)text entities:(NSArray *)entities;
- (void)inputPanelRequestedAttachmentsMenu:(TGModernConversationInputTextPanel *)inputTextPanel;
- (void)inputPanelRequestedSendImages:(TGModernConversationInputTextPanel *)inputTextPanel images:(NSArray *)images;
- (void)inputPanelRequestedSendData:(TGModernConversationInputTextPanel *)inputTextPanel data:(NSData *)data;
- (void)inputPanelRequestedSendSticker:(TGModernConversationInputTextPanel *)inputTextPanel sticker:(TGDocumentMediaAttachment *)sticker;
- (void)inputPanelRequestedSendGif:(TGModernConversationInputTextPanel *)inputTextPanel document:(TGDocumentMediaAttachment *)document;
- (void)inputPanelRequestedActivateCommand:(TGModernConversationInputTextPanel *)inputTextPanel button:(TGBotReplyMarkupButton *)button userId:(int32_t)userId messageId:(int32_t)messageId;
- (void)inputPanelRequestedToggleCommandKeyboard:(TGModernConversationInputTextPanel *)inputTextPanel showCommandKeyboard:(bool)showCommandKeyboard;
- (void)inputPanelTextChanged:(TGModernConversationInputTextPanel *)inputTextPanel text:(NSString *)text;
- (void)inputPanelMentionEntered:(TGModernConversationInputTextPanel *)inputTextPanel mention:(NSString *)mention startOfLine:(bool)startOfLine;
- (void)inputPanelMentionTextEntered:(TGModernConversationInputTextPanel *)inputTextPanel mention:(NSString *)mention text:(NSString *)text;
- (void)inputPanelHashtagEntered:(TGModernConversationInputTextPanel *)inputTextPanel hashtag:(NSString *)hashtag;
- (void)inputPanelCommandEntered:(TGModernConversationInputTextPanel *)inputTextPanel command:(NSString *)hashtag;
- (void)inputPanelLinkParsed:(TGModernConversationInputTextPanel *)inputTextPanel link:(NSString *)link probablyComplete:(bool)probablyComplete;
- (bool)isInputPanelTextEnabled:(TGModernConversationInputTextPanel *)inputTextPanel;
- (void)inputPanelFocused:(TGModernConversationInputTextPanel *)inputTextPanel;

- (void)inputPanelExpandedKeyboard:(TGModernConversationInputTextPanel *)inputTextPanel expanded:(bool)expanded;

- (bool)inputPanelAudioRecordingEnabled:(TGModernConversationInputTextPanel *)inputTextPanel;
- (void)inputPanelAudioRecordingStart:(TGModernConversationInputTextPanel *)inputTextPanel video:(bool)video completion:(void (^)())completion;
- (void)inputPanelAudioRecordingCancel:(TGModernConversationInputTextPanel *)inputTextPanel;
- (void)inputPanelAudioRecordingComplete:(TGModernConversationInputTextPanel *)inputTextPanel;
- (void)inputPanelAudioButtonInteractionUpdate:(TGModernConversationInputTextPanel *)inputTextPanel value:(CGPoint)value;
- (NSTimeInterval)inputPanelAudioRecordingDuration:(TGModernConversationInputTextPanel *)inputTextPanel;
- (void)inputPanelRecordingModeChanged:(TGModernConversationInputTextPanel *)inputTextPanel video:(bool)video;
- (void)inputPanelRecordingLocked:(TGModernConversationInputTextPanel *)inputTextPanel video:(bool)video;
- (void)inputPanelRecordingRequestedLockedAction:(TGModernConversationInputTextPanel *)inputTextPanel;
- (void)inputPanelRecordingStopped:(TGModernConversationInputTextPanel *)inputTextPanel;

- (bool)inputPanelSendShouldBeAlwaysEnabled:(TGModernConversationInputTextPanel *)inputTextPanel;

- (TGViewController *)inputPanelParentViewController:(TGModernConversationInputTextPanel *)inputTextPanel;

- (void)inputPanelToggleBroadcastMode:(TGModernConversationInputTextPanel *)inputTextPanel;

- (void)inputPanelRequestedFastCamera:(TGModernConversationInputTextPanel *)inputTextPanel;
- (void)inputPanelPannedFastCamera:(TGModernConversationInputTextPanel *)inputTextPanel location:(CGPoint)location;
- (void)inputPanelReleasedFastCamera:(TGModernConversationInputTextPanel *)inputTextPanel location:(CGPoint)location;

@end

@interface TGModernConversationInputTextPanel : TGModernConversationInputPanel

@property (nonatomic, strong) UIImageView *fieldBackground;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *attachButton;
@property (nonatomic, strong) TGModernConversationInputMicButton *micButton;
@property (nonatomic, strong) UIButton *broadcastButton;

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, strong) UIView *inputFieldClippingContainer;
@property (nonatomic, strong) HPGrowingTextView *inputField;
@property (nonatomic, strong) UIImageView *inputFieldPlaceholder;

@property (nonatomic, strong) NSString *contextPlaceholder;
@property (nonatomic) TGUser *contextBotMode;
@property (nonatomic) bool contextBotInputMode;
@property (nonatomic) NSString *mentionTextMode;

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

@property (nonatomic) bool keepInputPanel;

@property (nonatomic) bool videoMessageAvailable;
@property (nonatomic) bool videoMessage;

@property (nonatomic, assign) bool ignoreNextMicButtonEvent;
@property (nonatomic, assign) bool lockImmediately;
@property (nonatomic, readonly) bool isLocked;

@property (nonatomic, readonly) bool isCustomKeyboardExpanded;

@property (nonatomic, strong) TGMessageEditingContext *messageEditingContext;

@property (nonatomic, copy) bool (^canOpenStickersPanel)();
@property (nonatomic, copy) bool (^canRecordMedia)();

- (instancetype)initWithFrame:(CGRect)frame accessoryView:(UIView *)panelAccessoryView;

- (HPGrowingTextView *)maybeInputField;

- (void)audioRecordingStarted;
- (void)audioRecordingFinished;
- (void)recordingFinished;
- (void)recordingStopped;

- (void)shakeControls;

- (void)replaceMention:(NSString *)mention username:(bool)username userId:(int32_t)userId;
- (void)replaceHashtag:(NSString *)hashtag;

- (void)startMention;
- (void)startHashtag;
- (void)startCommand;

- (void)showStickersPanel;

- (CGRect)attachmentButtonFrame;
- (CGRect)stickerButtonFrame;
- (TGModernButton *)stickerButton;
- (CGRect)micButtonFrame;
- (CGRect)broadcastModeButtonFrame;

- (void)setAssociatedStickerList:(NSDictionary *)stickerList stickerSelected:(void (^)(TGDocumentMediaAttachment *))stickerSelected;
- (void)setAssociatedPanel:(TGModernConversationAssociatedInputPanel *)associatedPanel animated:(bool)animated;
- (TGModernConversationAssociatedInputPanel *)associatedPanel;
- (bool)associatedPanelVisible;

- (void)setPrimaryExtendedPanel:(TGModernConversationAssociatedInputPanel *)extendedPanel animated:(bool)animated;
- (void)setPrimaryExtendedPanel:(TGModernConversationAssociatedInputPanel *)extendedPanel animated:(bool)animated skipHeightAnimation:(bool)skipHeightAnimation;
- (void)setSecondaryExtendedPanel:(TGModernConversationAssociatedInputPanel *)extendedPanel animated:(bool)animated;
- (void)setSecondaryExtendedPanel:(TGModernConversationAssociatedInputPanel *)extendedPanel animated:(bool)animated skipHeightAnimation:(bool)skipHeightAnimation;
- (TGModernConversationAssociatedInputPanel *)primaryExtendedPanel;
- (TGModernConversationAssociatedInputPanel *)secondaryExtendedPanel;

+ (NSString *)linkCandidateInText:(NSString *)text;

+ (void)replaceMention:(NSString *)mention inputField:(HPGrowingTextView *)inputField;
+ (void)replaceMention:(NSString *)mention inputField:(HPGrowingTextView *)inputField username:(bool)username userId:(int32_t)userId;
+ (void)replaceHashtag:(NSString *)hashtag inputField:(HPGrowingTextView *)inputField;

- (void)animateRecordingIn;
- (void)addMicLevel:(CGFloat)level;

- (void)setMessageEditingContext:(TGMessageEditingContext *)messageEditingContext animated:(bool)animated;

- (void)resign;

- (void)updateModeButtonVisibility:(bool)animated reset:(bool)reset;

- (bool)hasInteractiveDismissal;

- (void)setCustomKeyboardExpanded:(bool)expanded animated:(bool)animated;

- (void)willDisappear;
- (bool)isActive;

@end
