/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernViewModel.h"

@class TGUser;
@class TGMessage;
@class TGModernViewContext;

typedef struct {
    CGFloat topInset;
    CGFloat bottomInset;
    CGFloat topInsetCollapsed;
    CGFloat bottomInsetCollapsed;
    CGFloat leftInset;
    CGFloat rightInset;
    
    CGFloat leftImageInset;
    CGFloat rightImageInset;
    
    CGFloat avatarInset;
    
    CGFloat textFontSize;
    CGFloat textBubblePaddingTop;
    CGFloat textBubblePaddingBottom;
    CGFloat textBubbleTextOffsetTop;
    
    CGFloat topPostInset;
    CGFloat bottomPostInset;
} TGMessageViewModelLayoutConstants;

#ifdef __cplusplus
extern "C" {
#endif
    
void TGMessageViewModelLayoutSetPreferredTextFontSize(CGFloat fontSize);
const TGMessageViewModelLayoutConstants *TGGetMessageViewModelLayoutConstants();
void TGUpdateMessageViewModelLayoutConstants(CGFloat baseFontPointSize);
    
#ifdef __cplusplus
}
#endif

@interface TGMessageViewModel : TGModernViewModel
{
    TGModernViewContext *_context;
    id _authorPeer;
    
    int32_t _mid;
    
    int _collapseFlags;
    bool _editing;
    
    bool _needsEditingCheckButton;
}

@property (nonatomic) bool needsRelativeBoundsUpdates;
@property (nonatomic) bool needsAvatar;

@property (nonatomic) int collapseFlags;

- (instancetype)initWithAuthorPeer:(id)authorPeer context:(TGModernViewContext *)context;

- (void)setAuthorAvatarUrl:(NSString *)authorAvatarUrl groupId:(int64_t)groupId;
- (void)setAuthorAvatarUrl:(NSString *)authorAvatarUrl;
- (void)setAuthorNameColor:(UIColor *)authorNameColor;

- (void)updateAssets;
- (void)refreshMetrics;
- (void)updateSearchText:(bool)animated;
- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage sizeUpdated:(bool *)sizeUpdated;
- (void)relativeBoundsUpdated:(CGRect)bounds;
- (void)imageDataInvalidated:(NSString *)imageUrl;
- (CGRect)effectiveContentFrame;
- (UIView *)referenceViewForImageTransition;
- (void)setTemporaryHighlighted:(bool)temporaryHighlighted viewStorage:(TGModernViewStorage *)viewStorage;
- (void)clearHighlights;

- (void)updateProgress:(bool)progressVisible progress:(float)progress viewStorage:(TGModernViewStorage *)viewStorage animated:(bool)animated;
- (void)updateMediaAvailability:(bool)mediaIsAvailable viewStorage:(TGModernViewStorage *)viewStorage;
- (void)updateMediaVisibility;
- (void)updateMessageAttributes;
- (void)updateEditingState:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage animationDelay:(NSTimeInterval)animationDelay;
- (void)updateInlineMediaContext;
- (void)updateAnimationsEnabled;
- (void)stopInlineMedia;

- (NSString *)linkAtPoint:(CGPoint)point;

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition;

@end
