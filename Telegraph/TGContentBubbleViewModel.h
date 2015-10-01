/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGMessageViewModel.h"

@class TGModernFlatteningViewModel;
@class TGTextMessageBackgroundViewModel;
@class TGModernTextViewModel;
@class TGModernDateViewModel;
@class TGModernClockProgressViewModel;
@class TGModernImageViewModel;
@class TGReplyHeaderModel;
@class TGWebpageFooterModel;
@class TGWebPageMediaAttachment;

@class TGDoubleTapGestureRecognizer;
@class TGMessageViewCountContentProperty;
@class TGMessageViewsViewModel;

extern bool debugShowMessageIds;

@interface TGContentBubbleViewModel : TGMessageViewModel
{
    TGTextMessageBackgroundViewModel *_backgroundModel;
    TGModernFlatteningViewModel *_contentModel;
    TGModernTextViewModel *_authorNameModel;
    TGModernTextViewModel *_forwardedHeaderModel;
    TGReplyHeaderModel *_replyHeaderModel;
    TGWebpageFooterModel *_webPageFooterModel;
    
    TGModernDateViewModel *_dateModel;
    TGModernClockProgressViewModel *_progressModel;
    TGModernImageViewModel *_checkFirstModel;
    TGModernImageViewModel *_checkSecondModel;
    bool _checkFirstEmbeddedInContent;
    bool _checkSecondEmbeddedInContent;
    TGModernImageViewModel *_unsentButtonModel;
    
    bool _incoming;
    bool _incomingAppearance;
    int _deliveryState;
    bool _read;
    int32_t _date;
    
    bool _hasAvatar;
    
    int64_t _forwardedPeerId;
    int64_t _forwardedMessageId;
    
    int32_t _replyMessageId;
    
    TGWebPageMediaAttachment *_webPage;
    TGMessageViewCountContentProperty *_messageViews;
    TGMessageViewsViewModel *_messageViewsModel;
}

+ (void)debugEnableShowMessageIds;

- (instancetype)initWithMessage:(TGMessage *)message authorPeer:(id)authorPeer context:(TGModernViewContext *)context;

- (void)setAuthorNameColor:(UIColor *)authorNameColor;
- (void)setForwardHeader:(id)forwardPeer messageId:(int32_t)messageId;
- (void)setReplyHeader:(TGMessage *)replyHeader peer:(id)peer;
- (void)setWebPageFooter:(TGWebPageMediaAttachment *)webPage viewStorage:(TGModernViewStorage *)viewStorage;

- (void)messageDoubleTapGesture:(TGDoubleTapGestureRecognizer *)recognizer;
- (void)gestureRecognizer:(TGDoubleTapGestureRecognizer *)recognizer didBeginAtPoint:(CGPoint)point;
- (void)gestureRecognizerDidFail:(TGDoubleTapGestureRecognizer *)recognizer;
- (bool)gestureRecognizerShouldHandleLongTap:(TGDoubleTapGestureRecognizer *)recognizer;
- (int)gestureRecognizer:(TGDoubleTapGestureRecognizer *)recognizer shouldFailTap:(CGPoint)point;
- (void)doubleTapGestureRecognizerSingleTapped:(TGDoubleTapGestureRecognizer *)recognizer;

- (void)layoutContentForHeaderHeight:(CGFloat)headerHeight;
- (CGSize)contentSizeForContainerSize:(CGSize)containerSize needsContentsUpdate:(bool *)needsContentsUpdate hasDate:(bool)hasDate hasViews:(bool)hasViews;

+ (TGReplyHeaderModel *)replyHeaderModelFromMessage:(TGMessage *)replyHeader peer:(id)peer incoming:(bool)incoming system:(bool)system;

@end
