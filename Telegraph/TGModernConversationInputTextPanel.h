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

@protocol TGModernConversationInputTextPanelDelegate <TGModernConversationInputPanelDelegate>

- (void)inputTextPanelHasIndicatedTypingActivity:(TGModernConversationInputTextPanel *)inputTextPanel;
- (void)inputPanelRequestedSendMessage:(TGModernConversationInputTextPanel *)inputTextPanel text:(NSString *)text;
- (void)inputPanelRequestedAttachmentsMenu:(TGModernConversationInputTextPanel *)inputTextPanel;
- (void)inputPanelRequestedSendImages:(TGModernConversationInputTextPanel *)inputTextPanel images:(NSArray *)images;
- (void)inputPanelRequestedSendData:(TGModernConversationInputTextPanel *)inputTextPanel data:(NSData *)data;

- (void)inputPanelAudioRecordingStart:(TGModernConversationInputTextPanel *)inputTextPanel;
- (void)inputPanelAudioRecordingCancel:(TGModernConversationInputTextPanel *)inputTextPanel;
- (void)inputPanelAudioRecordingComplete:(TGModernConversationInputTextPanel *)inputTextPanel;
- (NSTimeInterval)inputPanelAudioRecordingDuration:(TGModernConversationInputTextPanel *)inputTextPanel;

@end

@interface TGModernConversationInputTextPanel : TGModernConversationInputPanel

@property (nonatomic, strong) UIImageView *fieldBackground;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *attachButton;

@property (nonatomic, strong) UIView *inputFieldClippingContainer;
@property (nonatomic, strong) HPGrowingTextView *inputField;
@property (nonatomic, strong) UIView *inputFieldPlaceholder;

@property (nonatomic) UIInterfaceOrientation interfaceOrientation;

@property (nonatomic, strong) UIView *panelAccessoryView;

- (instancetype)initWithFrame:(CGRect)frame accessoryView:(UIView *)panelAccessoryView;

- (HPGrowingTextView *)maybeInputField;

- (void)audioRecordingStarted;
- (void)audioRecordingFinished;

- (void)shakeControls;

- (CGRect)attachmentButtonFrame;

@end
