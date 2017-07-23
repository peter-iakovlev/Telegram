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
@class TGInvoiceMediaAttachment;

@class TGDoubleTapGestureRecognizer;
@class TGMessageViewCountContentProperty;
@class TGMessageViewsViewModel;
@class TGModernLabelViewModel;

extern bool debugShowMessageIds;

@interface TGContentBubbleViewModel : TGMessageViewModel
{
    TGTextMessageBackgroundViewModel *_backgroundModel;
    TGModernFlatteningViewModel *_contentModel;
    TGModernTextViewModel *_authorNameModel;
    TGModernTextViewModel *_viaUserModel;
    TGModernTextViewModel *_authorSignatureModel;
    NSString *_authorSignature;
    TGUser *_viaUser;
    TGModernTextViewModel *_forwardedHeaderModel;
    TGReplyHeaderModel *_replyHeaderModel;
    TGWebpageFooterModel *_webPageFooterModel;
    
    TGModernDateViewModel *_dateModel;
    TGModernLabelViewModel *_editedLabelModel;
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
    bool _inhibitChecks;
    
    int64_t _forwardedPeerId;
    int64_t _forwardedMessageId;
    
    int32_t _replyMessageId;
    
    TGWebPageMediaAttachment *_webPage;
    TGMessageViewCountContentProperty *_messageViews;
    TGMessageViewsViewModel *_messageViewsModel;
}

+ (void)debugEnableShowMessageIds;

- (instancetype)initWithMessage:(TGMessage *)message authorPeer:(id)authorPeer viaUser:(TGUser *)viaUser context:(TGModernViewContext *)context;

- (void)setAuthorNameColor:(UIColor *)authorNameColor;
- (void)setForwardHeader:(id)forwardPeer forwardAuthor:(id)forwardAuthor messageId:(int32_t)messageId forwardSignature:(NSString *)forwardSignature;
- (void)setReplyHeader:(TGMessage *)replyHeader peer:(id)peer;
- (void)setWebPageFooter:(TGWebPageMediaAttachment *)webPage invoice:(TGInvoiceMediaAttachment *)invoice viewStorage:(TGModernViewStorage *)viewStorage;

- (void)messageDoubleTapGesture:(TGDoubleTapGestureRecognizer *)recognizer;
- (void)gestureRecognizer:(TGDoubleTapGestureRecognizer *)recognizer didBeginAtPoint:(CGPoint)point;
- (void)gestureRecognizerDidFail:(TGDoubleTapGestureRecognizer *)recognizer;
- (bool)gestureRecognizerShouldHandleLongTap:(TGDoubleTapGestureRecognizer *)recognizer;
- (int)gestureRecognizer:(TGDoubleTapGestureRecognizer *)recognizer shouldFailTap:(CGPoint)point;
- (void)doubleTapGestureRecognizerSingleTapped:(TGDoubleTapGestureRecognizer *)recognizer;
- (void)instantPageButtonPressed;

- (void)layoutContentForHeaderHeight:(CGFloat)headerHeight;
- (void)layoutContentForHeaderHeight:(CGFloat)headerHeight containerSize:(CGSize)containerSize;
- (CGSize)contentSizeForContainerSize:(CGSize)containerSize needsContentsUpdate:(bool *)needsContentsUpdate infoWidth:(CGFloat)infoWidth;

+ (TGReplyHeaderModel *)replyHeaderModelFromMessage:(TGMessage *)replyHeader peer:(id)peer incoming:(bool)incoming system:(bool)system;

@end
