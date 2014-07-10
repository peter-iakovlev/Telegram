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

@class TGDoubleTapGestureRecognizer;

@interface TGContentBubbleViewModel : TGMessageViewModel
{
    TGTextMessageBackgroundViewModel *_backgroundModel;
    TGModernFlatteningViewModel *_contentModel;
    TGModernTextViewModel *_authorNameModel;
    TGModernTextViewModel *_forwardedHeaderModel;
    TGModernDateViewModel *_dateModel;
    TGModernClockProgressViewModel *_progressModel;
    TGModernImageViewModel *_checkFirstModel;
    TGModernImageViewModel *_checkSecondModel;
    bool _checkFirstEmbeddedInContent;
    bool _checkSecondEmbeddedInContent;
    TGModernImageViewModel *_unsentButtonModel;
    
    bool _incoming;
    int _deliveryState;
    bool _read;
    int32_t _date;
    
    bool _hasAvatar;
    
    int _forwardedUid;
}

- (instancetype)initWithMessage:(TGMessage *)message author:(TGUser *)author context:(TGModernViewContext *)context;

- (void)setAuthorNameColor:(UIColor *)authorNameColor;
- (void)setForwardHeader:(TGUser *)forwardUser;

- (void)messageDoubleTapGesture:(TGDoubleTapGestureRecognizer *)recognizer;
- (void)gestureRecognizer:(TGDoubleTapGestureRecognizer *)recognizer didBeginAtPoint:(CGPoint)point;
- (void)gestureRecognizerDidFail:(TGDoubleTapGestureRecognizer *)recognizer;
- (bool)gestureRecognizerShouldHandleLongTap:(TGDoubleTapGestureRecognizer *)recognizer;
- (int)gestureRecognizer:(TGDoubleTapGestureRecognizer *)recognizer shouldFailTap:(CGPoint)point;
- (void)doubleTapGestureRecognizerSingleTapped:(TGDoubleTapGestureRecognizer *)recognizer;

- (void)layoutContentForHeaderHeight:(CGFloat)headerHeight;
- (CGSize)contentSizeForContainerSize:(CGSize)containerSize needsContentsUpdate:(bool *)needsContentsUpdate;

@end
