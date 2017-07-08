/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "TGModernConversationCompanion.h"

typedef enum {
    TGModernConversationTitleViewActivityTyping,
    TGModernConversationTitleViewActivityAudioRecording,
    TGModernConversationTitleViewActivityVideoMessageRecording,
    TGModernConversationTitleViewActivityUploading,
    TGModernConversationTitleViewActivityPlaying
} TGModernConversationTitleViewActivity;

@class TGModernConversationTitleView;

@protocol TGModernConversationTitleViewDelegate <NSObject>

@optional

- (void)titleViewTapped:(TGModernConversationTitleView *)titleView;

@end

@interface TGModernConversationTitleView : UIView

@property (nonatomic, weak) id<TGModernConversationTitleViewDelegate> delegate;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *status;
@property (nonatomic) bool statusHasAccentColor;
@property (nonatomic) TGModernConversationControllerTitleToggle toggleMode;
@property (nonatomic, strong) NSString *typingStatus;

- (void)setBackButtonTitle:(NSString *)backButtonTitle;
- (void)setOrientation:(UIInterfaceOrientation)orientation;
- (void)setEditingMode:(bool)editingMode animated:(bool)animated;

- (void)setStatus:(NSString *)status animated:(bool)animated;
- (void)setAttributedStatus:(NSAttributedString *)attributedStatus animated:(bool)animated;
- (void)setTypingStatus:(NSString *)typingStatus activity:(TGModernConversationTitleViewActivity)activity animated:(bool)animated;
- (void)setIcons:(NSArray *)icons;
- (void)setModalProgressStatus:(NSString *)modalProgressStatus;
- (void)setUnreadCount:(int)unreadCount;
- (void)setShowUnreadCount:(bool)showUnreadCount;
- (void)disableUnreadCount;

- (void)suspendAnimations;
- (void)resumeAnimations;

- (void)setShowStatus:(bool)showStatus;

@end
