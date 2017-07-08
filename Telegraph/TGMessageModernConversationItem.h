/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernConversationItem.h"

#ifdef __cplusplus
extern "C" {
#endif
    
extern int32_t TGMessageModernConversationItemLocalUserId;

#ifdef __cplusplus
}
#endif

@class TGMessage;
@class TGUser;
@class TGModernViewContext;

@interface TGMessageModernConversationItem : TGModernConversationItem <NSCopying>
{
    @public TGMessage *_message;
    TGUser *_author;
    NSArray *_additionalUsers;
    NSArray *_additionalConversations;
    int32_t _additionalDate;
    
    bool _mediaAvailabilityStatus;
}

- (instancetype)initWithMessage:(TGMessage *)message context:(TGModernViewContext *)context;
- (id)deepCopy;

- (void)updateAssets;
- (void)refreshMetrics;
- (void)updateSearchText:(bool)animated;
- (void)updateMessage:(TGMessage *)message fromMessage:(TGMessage *)fromMessage viewStorage:(TGModernViewStorage *)viewStorage sizeUpdated:(bool *)sizeUpdated;
- (void)updateMediaVisibility;
- (void)updateMessageAttributes;
- (void)updateMessageVisibility;
- (void)updateEditingState:(TGModernViewStorage *)viewStorage animationDelay:(NSTimeInterval)animationDelay;
- (void)imageDataInvalidated:(NSString *)imageUrl;
- (void)setTemporaryHighlighted:(bool)temporaryHighlighted viewStorage:(TGModernViewStorage *)viewStorage;
- (void)clearHighlights;

- (CGRect)effectiveContentFrame;
- (UIView *)referenceViewForImageTransition;

- (void)collectBoundModelViewFramesRecursively:(NSMutableDictionary *)dict;
- (void)collectBoundModelViewFramesRecursively:(NSMutableDictionary *)dict ifPresentInDict:(NSMutableDictionary *)anotherDict;
- (void)restoreBoundModelViewFramesRecursively:(NSMutableDictionary *)dict;

- (void)updateReplySwipeInteraction:(TGModernViewStorage *)viewStorage ended:(bool)ended;

@end
