#import "TGMessageModernConversationItem.h"

#import "NSObject+TGLock.h"

#import "TGPeerIdAdapter.h"

#import "TGUser.h"
#import "TGMessage.h"
#import "TGMessageViewModel.h"
#import "TGPhotoMessageViewModel.h"
#import "TGVideoMessageViewModel.h"
#import "TGMapMessageViewModel.h"
#import "TGVenueMessageViewModel.h"
#import "TGContactMessageViewModel.h"
#import "TGDocumentMessageViewModel.h"
#import "TGNotificationMessageViewModel.h"
#import "TGAudioMessageViewModel.h"
#import "TGAnimatedImageMessageViewModel.h"
#import "TGStickerMessageViewModel.h"
#import "TGMusicAudioMessageModel.h"
#import "TGCallMessageViewModel.h"
#import "TGRoundMessageViewModel.h"
#import "TGHoleMessageViewModel.h"

#import "TGPreparedLocalDocumentMessage.h"

#import "TGTextMessageModernViewModel.h"

#import "TGModernCollectionCell.h"

#import "TGInterfaceAssets.h"
#import "TGImageUtils.h"

#import <map>
#import <CommonCrypto/CommonDigest.h>

#import "TGConversation.h"
#import "TGModernViewContext.h"

#import "TGAnimationUtils.h"

typedef enum {
    TGCachedMessageTypeUnknown = 0,
    TGCachedMessageTypeText = 1,
    TGCachedMessageTypeImage = 2,
    TGCachedMessageTypeNotification = 3
} TGCachedMessageType;

int32_t TGMessageModernConversationItemLocalUserId = 0;

static UIColor *coloredNameForUid(int uid, __unused int currentUserId)
{
    return [[TGInterfaceAssets instance] userColor:uid];
}

@interface TGMessageModernConversationItem () <TGModernCollectionRelativeBoundsObserver>
{
    TGMessageViewModel *_viewModel;
    TGModernViewContext *_context;
    
    TGCachedMessageType _cachedMessageType;
    bool _layoutIsInvalid;
    
    TGUser *_syntheticAuthor;
    
    CGSize _currentContainerSize;
}

@end

@implementation TGMessageModernConversationItem

- (instancetype)initWithMessage:(TGMessage *)message context:(TGModernViewContext *)context
{
    self = [super init];
    if (self != nil)
    {
        _message = message;
        _context = context;
        
        _mediaAvailabilityStatus = true;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)__unused zone
{
    TGMessageModernConversationItem *copyItem = [[TGMessageModernConversationItem alloc] initWithMessage:_message context:_context];
    copyItem->_viewModel = _viewModel;
    copyItem->_author = _author;
    copyItem->_additionalUsers = _additionalUsers;
    copyItem->_additionalConversations = _additionalConversations;
    copyItem->_additionalDate = _additionalDate;
    copyItem->_collapseFlags = _collapseFlags;
    copyItem->_cachedMessageType = _cachedMessageType;
    copyItem->_mediaAvailabilityStatus = _mediaAvailabilityStatus;
    return copyItem;
}

- (id)deepCopy
{
    TGMessageModernConversationItem *copyItem = [[TGMessageModernConversationItem alloc] initWithMessage:[_message copy] context:_context];
    copyItem->_viewModel = _viewModel;
    copyItem->_author = _author;
    copyItem->_additionalUsers = _additionalUsers;
    copyItem->_additionalConversations = _additionalConversations;
    copyItem->_additionalDate = _additionalDate;
    copyItem->_collapseFlags = _collapseFlags;
    copyItem->_cachedMessageType = _cachedMessageType;
    copyItem->_mediaAvailabilityStatus = _mediaAvailabilityStatus;
    return copyItem;
}

- (Class)cellClass
{
    return [TGModernCollectionCell class];
}

- (void)bindCell:(TGModernCollectionCell *)cell viewStorage:(TGModernViewStorage *)viewStorage
{
    [super bindCell:cell viewStorage:viewStorage];
    
    if (cell != nil)
        cell->_needsRelativeBoundsUpdateNotifications = _viewModel.needsRelativeBoundsUpdates;
    
    [_viewModel bindViewToContainer:[cell contentViewForBinding] viewStorage:viewStorage];
}

- (void)unbindCell:(TGModernViewStorage *)viewStorage
{
    [_viewModel unbindView:viewStorage];
    
    [super unbindCell:viewStorage];
}

- (void)moveToCell:(TGModernCollectionCell *)cell
{
    [super moveToCell:cell];
    
    if ([self boundCell] == cell)
    {
        [_viewModel moveViewToContainer:[cell contentViewForBinding]];
        
        if (cell != nil)
            cell->_needsRelativeBoundsUpdateNotifications = _viewModel.needsRelativeBoundsUpdates;
    }
}

- (void)temporaryMoveToView:(UIView *)view
{
    [_viewModel moveViewToContainer:view];
    
    [super temporaryMoveToView:view];
}

- (void)drawInContext:(CGContextRef)context
{
    [_viewModel drawInContext:context];
}

- (void)relativeBoundsUpdated:(TGModernCollectionCell *)cell bounds:(CGRect)bounds
{
    if (cell == [self boundCell])
    {
        if ([_viewModel needsRelativeBoundsUpdates])
            [_viewModel relativeBoundsUpdated:bounds];
    }
}

- (void)updateAssets
{
    [_viewModel updateAssets];
}

- (void)refreshMetrics
{
    _layoutIsInvalid = true;
    
    [_viewModel refreshMetrics];
}

- (void)updateSearchText:(bool)animated
{
    [_viewModel updateSearchText:animated];
}

- (void)updateMessage:(TGMessage *)message fromMessage:(TGMessage *)__unused fromMessage viewStorage:(TGModernViewStorage *)viewStorage sizeUpdated:(bool *)sizeUpdated containerSize:(CGSize)containerSize
{
    TGModernCollectionCell *rebindCell = nil;
    
    if (_viewModel != nil && !TGPeerIdIsSecretChat(_message.cid) && _message.messageLifetime > 0) {
        bool replaceModel = false;
        if ([_viewModel isKindOfClass:[TGImageMessageViewModel class]]) {
            for (id media in _message.mediaAttachments) {
                if ([media isKindOfClass:[TGImageMediaAttachment class]]) {
                    TGImageMediaAttachment *imageMedia = media;
                    if (imageMedia.imageId == 0 && imageMedia.localImageId == 0) {
                        replaceModel = true;
                        break;
                    }
                } else if ([media isKindOfClass:[TGVideoMediaAttachment class]]) {
                    TGVideoMediaAttachment *videoMedia = media;
                    if (videoMedia.videoId == 0 && videoMedia.localVideoId == 0) {
                        replaceModel = true;
                        break;
                    }
                } if ([media isKindOfClass:[TGDocumentMediaAttachment class]]) {
                    TGDocumentMediaAttachment *documentMedia = media;
                    if (documentMedia.documentId == 0 && documentMedia.localDocumentId == 0) {
                        replaceModel = true;
                        break;
                    }
                }
            }
        }
        
        if (replaceModel) {
            if ([self boundCell] != nil) {
                if ([_viewModel isKindOfClass:[TGImageMessageViewModel class]]) {
                    TGImageMessageViewModel *containerModel = _viewModel.submodels.firstObject;
                    if (containerModel != nil && containerModel.boundView != nil) {
                        UIView *copyView = [containerModel.boundView snapshotViewAfterScreenUpdates:false];
                        if (copyView != nil) {
                            copyView.frame = containerModel.boundView.frame;
                            [containerModel.boundView.superview insertSubview:copyView aboveSubview:containerModel.boundView];
                            
                            [UIView animateWithDuration:0.2 animations:^{
                                copyView.alpha = 0.0f;
                                copyView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
                            } completion:^(__unused BOOL finished) {
                                [copyView removeFromSuperview];
                            }];
                        }
                    }
                }
                rebindCell = [self boundCell];
                [self unbindCell:viewStorage];
            }
            _viewModel = nil;
        }
    }
    
    if (_viewModel == nil) {
        _viewModel = [self createMessageViewModel:_message containerSize:containerSize];
        if (sizeUpdated) {
            *sizeUpdated = true;
        }
        
        if (rebindCell) {
            [self bindCell:rebindCell viewStorage:viewStorage];
            
            if ([_viewModel isKindOfClass:[TGNotificationMessageViewModel class]]) {
                for (TGModernViewModel *model in _viewModel.submodels) {
                    if (model.boundView != nil) {
                        [model.boundView.layer animateAlphaFrom:0.0f to:model.boundView.alpha duration:0.2 timingFunction:kCAMediaTimingFunctionEaseIn removeOnCompletion:true completion:nil];
                    }
                }
            }
        }
    } else {
        [_viewModel updateMessage:message viewStorage:viewStorage sizeUpdated:sizeUpdated];
    }
}

- (void)updateMediaVisibility
{
    [_viewModel updateMediaVisibility];
}

- (void)updateMessageAttributes
{
    [_viewModel updateMessageAttributes];
}

- (void)updateMessageVisibility
{
    [_viewModel updateMessageVisibility];
}

- (void)updateEditingState:(TGModernViewStorage *)viewStorage animationDelay:(NSTimeInterval)animationDelay
{
    [_viewModel updateEditingState:[[self boundCell] contentViewForBinding] viewStorage:viewStorage animationDelay:animationDelay];
}

- (void)imageDataInvalidated:(NSString *)imageUrl
{
    [_viewModel imageDataInvalidated:imageUrl];
}

- (void)setTemporaryHighlighted:(bool)temporaryHighlighted viewStorage:(TGModernViewStorage *)viewStorage
{
    [_viewModel setTemporaryHighlighted:temporaryHighlighted viewStorage:viewStorage];
}

- (void)clearHighlights
{
    [_viewModel clearHighlights];
}

- (CGRect)effectiveContentFrame
{
    return [_viewModel effectiveContentFrame];
}

- (UIView *)referenceViewForImageTransition
{
    return [_viewModel referenceViewForImageTransition];
}

- (void)collectBoundModelViewFramesRecursively:(NSMutableDictionary *)dict
{
    [_viewModel collectBoundModelViewFramesRecursively:dict];
}

- (void)collectBoundModelViewFramesRecursively:(NSMutableDictionary *)dict ifPresentInDict:(NSMutableDictionary *)anotherDict
{
    [_viewModel collectBoundModelViewFramesRecursively:dict ifPresentInDict:anotherDict];
}

- (void)restoreBoundModelViewFramesRecursively:(NSMutableDictionary *)dict
{
    [_viewModel restoreBoundModelViewFramesRecursively:dict];
}

- (void)updateReplySwipeInteraction:(TGModernViewStorage *)viewStorage ended:(bool)ended
{
    [_viewModel updateReplySwipeInteraction:[[self boundCell] contentViewForBinding] viewStorage:viewStorage ended:ended];
}

- (TGModernViewModel *)viewModel
{
    return _viewModel;
}

- (TGModernViewModel *)viewModelForContainerSize:(CGSize)containerSize viewStorage:(TGModernViewStorage *)viewStorage
{
    bool updateCell = false;
    TGModernCollectionCell *rebindCell = nil;
    
    if (_viewModel != nil && !TGPeerIdIsSecretChat(_message.cid) && _message.messageLifetime > 0) {
        bool replaceModel = false;
        if ([_viewModel isKindOfClass:[TGImageMessageViewModel class]]) {
            for (id media in _message.mediaAttachments) {
                if ([media isKindOfClass:[TGImageMediaAttachment class]]) {
                    TGImageMediaAttachment *imageMedia = media;
                    if (imageMedia.imageId == 0 && imageMedia.localImageId == 0) {
                        replaceModel = true;
                        break;
                    }
                } else if ([media isKindOfClass:[TGVideoMediaAttachment class]]) {
                    TGVideoMediaAttachment *videoMedia = media;
                    if (videoMedia.videoId == 0 && videoMedia.localVideoId == 0) {
                        replaceModel = true;
                        break;
                    }
                } if ([media isKindOfClass:[TGDocumentMediaAttachment class]]) {
                    TGDocumentMediaAttachment *documentMedia = media;
                    if (documentMedia.documentId == 0 && documentMedia.localDocumentId == 0) {
                        replaceModel = true;
                        break;
                    }
                }
            }
        }
        
        if (replaceModel) {
            if ([self boundCell] != nil) {
                rebindCell = [self boundCell];
                [self unbindCell:viewStorage];
            }
            _viewModel = nil;
        }
    }
    
    if (_viewModel == nil)
    {
        _viewModel = [self createMessageViewModel:_message containerSize:containerSize];
        [_viewModel updateMediaAvailability:_mediaAvailabilityStatus viewStorage:nil delayDisplay:false];
        updateCell = true;
    }
    else if (ABS(_viewModel.frame.size.width - containerSize.width) > FLT_EPSILON || _viewModel.collapseFlags != _collapseFlags || _layoutIsInvalid)
    {
        _layoutIsInvalid = false;
        
        _viewModel.collapseFlags = _collapseFlags;
        [_viewModel layoutForContainerSize:containerSize];
        updateCell = true;
    }
    
    if (rebindCell) {
        [self bindCell:rebindCell viewStorage:viewStorage];
    }
    
    if (updateCell)
    {
        if ([self boundCell] != nil)
            [self boundCell]->_needsRelativeBoundsUpdateNotifications = _viewModel.needsRelativeBoundsUpdates;
    }
    
    return _viewModel;
}

- (CGSize)sizeForContainerSize:(CGSize)containerSize viewStorage:(TGModernViewStorage *)viewStorage
{
    return CGSizeMake(containerSize.width, [self viewModelForContainerSize:containerSize viewStorage:viewStorage].frame.size.height);
}

- (void)updateToItem:(TGMessageModernConversationItem *)updatedItem viewStorage:(TGModernViewStorage *)viewStorage sizeChanged:(bool *)sizeChanged delayAvailability:(bool)delayAvailability containerSize:(CGSize)containerSize
{
    if ([updatedItem isKindOfClass:[TGMessageModernConversationItem class]])
    {
        if (_message != updatedItem->_message) // by reference
        {
            TGMessage *previousMessage = _message;
            _message = updatedItem->_message;
            bool sizeUpdated = false;
            [self updateMessage:_message fromMessage:previousMessage viewStorage:viewStorage sizeUpdated:&sizeUpdated containerSize:containerSize];
            if (sizeUpdated)
            {
                if (sizeChanged)
                    *sizeChanged = true;
                _layoutIsInvalid = true;
            }
        }
        
        if (_mediaAvailabilityStatus != updatedItem->_mediaAvailabilityStatus)
        {
            _mediaAvailabilityStatus = updatedItem->_mediaAvailabilityStatus;
            [_viewModel updateMediaAvailability:_mediaAvailabilityStatus viewStorage:viewStorage delayDisplay:delayAvailability];
        }
    }
}

- (void)updateProgress:(float)progress viewStorage:(TGModernViewStorage *)viewStorage animated:(bool)animated
{
    [_viewModel updateProgress:progress > -FLT_EPSILON progress:MAX(0.0f, progress) viewStorage:viewStorage animated:animated];
}

- (void)updateInlineMediaContext
{
    [_viewModel updateInlineMediaContext];
}

- (void)updateAnimationsEnabled
{
    [_viewModel updateAnimationsEnabled];
}

- (void)stopInlineMedia:(int32_t)excludeMid
{
    [_viewModel stopInlineMedia:excludeMid];
}

- (void)resumeInlineMedia {
    [_viewModel resumeInlineMedia];
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{
    [_viewModel bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:itemPosition];
}

- (NSDictionary *)parseMimeArguments:(NSString *)string
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSUInteger rangeStart = 0;
    while (rangeStart < string.length && rangeStart != NSNotFound)
    {
        NSUInteger rangeEnd = [string rangeOfString:@";" options:0 range:NSMakeRange(rangeStart, string.length - rangeStart)].location;
        NSString *pairString = nil;
        if (rangeEnd == NSNotFound)
        {
            pairString = [string substringWithRange:NSMakeRange(rangeStart, string.length - rangeStart)];
            rangeStart = rangeEnd;
        }
        else
        {
            pairString = [string substringWithRange:NSMakeRange(rangeStart, rangeEnd - rangeStart)];
            rangeStart = rangeEnd + 1;
        }
        
        pairString = [pairString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (pairString.length != 0)
        {
            NSUInteger eqRange = [pairString rangeOfString:@"="].location;
            if (eqRange != NSNotFound)
            {
                NSString *key = [[pairString substringWithRange:NSMakeRange(0, eqRange)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *value = [[pairString substringWithRange:NSMakeRange(eqRange + 1, pairString.length - eqRange - 1)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                dict[key] = value;
            }
        }
    }
    
    return dict;
}

- (id)currentAuthorPeer {
    TGConversation *conversation = [_context conversation];
    if (conversation.isChannel && !conversation.isChannelGroup && TGMessageSortKeySpace(_message.sortKey) == TGMessageSpaceImportant) {
        TGConversation *conversation = [_context conversation];
        return conversation;
    }
    
    if (_author != nil) {
        return _author;
    } else {
        TGConversation *conversation = [_context conversation];
        return conversation;
    }
    
    return nil;
}

- (void)_setupMessageAuthor:(TGMessageViewModel *)model {
    id author = [self currentAuthorPeer];
    if ([author isKindOfClass:[TGConversation class]]) {
        TGConversation *conversation = author;
        [model setAuthorAvatarUrl:conversation.chatPhotoSmall groupId:conversation.conversationId];
        [model setAuthorNameColor:UIColorRGB(0x3ca5ec)];
        if (_author != nil) {
            [model setAuthorSignature:[_author displayName]];
        } else {
            [model setAuthorSignature:_message.authorSignature];
        }
    } else if ([author isKindOfClass:[TGUser class]]) {
        TGUser *user = author;
        [model setAuthorAvatarUrl:user.photoUrlSmall];
        [model setAuthorNameColor:coloredNameForUid(user.uid, TGMessageModernConversationItemLocalUserId)];
    } else if (_message.authorSignature != nil) {
        [model setAuthorSignature:_message.authorSignature];
    }
}

- (TGMessageViewModel *)createMessageViewModel:(TGMessage *)message containerSize:(CGSize)containerSize
{
    bool useAuthor = ([self currentAuthorPeer] != nil) && !message.outgoing;
    if (message.outgoing) {
        if ([[self currentAuthorPeer] isKindOfClass:[TGConversation class]]) {
            useAuthor = true;
        }
    }
    
    int contactIndex = -1;
    int webpageIndex = -1;
    int gameIndex = -1;
    int invoiceIndex = -1;
    int32_t contactUid = 0;
    bool unsupportedMessage = false;
    TGUser *viaUser = nil;
    
    TGMessage *replyMessage = nil;
    id replyPeer = nil;
    
    id forwardPeer = nil;
    id forwardAuthor = nil;
    int32_t forwardMessageId = 0;
    
    if (message.hole != nil || message.group != nil)
    {
        TGHoleMessageViewModel *model = [[TGHoleMessageViewModel alloc] initWithMessage:_message context:_context];
        model.collapseFlags = _collapseFlags;
        [model layoutForContainerSize:containerSize];
        return model;
    }
    
    if (message.mediaAttachments.count != 0)
    {
        int index = -1;
        for (TGMediaAttachment *attachment in message.mediaAttachments)
        {
            index++;
            
            if (attachment.type == TGForwardedMessageMediaAttachmentType) {
                TGForwardedMessageMediaAttachment *forwardAttachment = (TGForwardedMessageMediaAttachment *)attachment;
                forwardMessageId = forwardAttachment.forwardPostId;
                int64_t forwardPeerId = forwardAttachment.forwardPeerId;
                if (TGPeerIdIsChannel(forwardPeerId)) {
                    for (TGConversation *conversation in _additionalConversations) {
                        if (conversation.conversationId == forwardPeerId) {
                            forwardPeer = conversation;
                            break;
                        }
                    }
                } else {
                    for (TGUser *user in _additionalUsers) {
                        if (user.uid == forwardPeerId) {
                            forwardPeer = user;
                            break;
                        }
                    }
                }
                if (forwardAttachment.forwardAuthorUserId != 0) {
                    for (TGUser *user in _additionalUsers) {
                        if (user.uid == forwardAttachment.forwardAuthorUserId) {
                            forwardAuthor = user;
                            break;
                        }
                    }
                }
            }
            else if (attachment.type == TGReplyMessageMediaAttachmentType) {
                TGReplyMessageMediaAttachment *replyAttachment = (TGReplyMessageMediaAttachment *)attachment;
                int64_t replyPeerId = replyAttachment.replyMessage.fromUid;
                if (TGPeerIdIsChannel(message.cid) && TGMessageSortKeySpace(message.sortKey) == TGMessageSpaceImportant) {
                    replyPeerId = message.cid;
                }
                
                if (TGPeerIdIsChannel(replyPeerId)) {
                    for (TGConversation *conversation in _additionalConversations) {
                        if (conversation.conversationId == replyPeerId) {
                            replyPeer = conversation;
                            break;
                        }
                    }
                } else {
                    for (TGUser *user in _additionalUsers) {
                        if (user.uid == replyPeerId) {
                            replyPeer = user;
                            break;
                        }
                    }
                }
                replyMessage = replyAttachment.replyMessage;
                if (replyMessage == nil) {
                    replyPeer = nil;
                }
            }
            else if (attachment.type == TGWebPageMediaAttachmentType)
                webpageIndex = index;
            else if (attachment.type == TGGameAttachmentType)
                gameIndex = index;
            else if (attachment.type == TGInvoiceMediaAttachmentType)
                invoiceIndex = index;
            else if (attachment.type == TGViaUserAttachmentType) {
                int32_t userId = ((TGViaUserAttachment *)attachment).userId;
                if (userId == 0) {
                    NSString *username = ((TGViaUserAttachment *)attachment).username;
                    if (username.length != 0) {
                        viaUser = [[TGUser alloc] init];
                        viaUser.userName = username;
                    }
                } else {
                    for (TGUser *user in _additionalUsers) {
                        if (userId == user.uid) {
                            viaUser = user;
                            break;
                        }
                    }
                }
            }
        }
        
        TGWebPageMediaAttachment *webPage = nil;
        if (webpageIndex != -1) {
            webPage = message.mediaAttachments[webpageIndex];
        }
        
        index = -1;
        for (TGMediaAttachment *attachment in message.mediaAttachments)
        {
            index++;
            
            switch (attachment.type)
            {
                case TGImageMediaAttachmentType:
                {
                    if (((TGImageMediaAttachment *)attachment).imageId == 0 && ((TGImageMediaAttachment *)attachment).localImageId == 0 && message.messageLifetime > 0) {
                        TGActionMediaAttachment *action = [[TGActionMediaAttachment alloc] init];
                        action.actionType = TGMessageActionCustom;
                        action.actionData = @{@"expiredMedia": attachment};
                        TGNotificationMessageViewModel *model = [[TGNotificationMessageViewModel alloc] initWithMessage:_message actionMedia:action authorPeer:[self currentAuthorPeer] additionalUsers:_additionalUsers context:_context];
                        model.collapseFlags = _collapseFlags;
                        [model layoutForContainerSize:containerSize];
                        return model;
                    } else {
                        TGPhotoMessageViewModel *model = [[TGPhotoMessageViewModel alloc] initWithMessage:message imageMedia:(TGImageMediaAttachment *)attachment authorPeer:useAuthor ? [self currentAuthorPeer] : nil context:_context forwardPeer:forwardPeer forwardAuthor:forwardAuthor forwardMessageId:forwardMessageId replyHeader:replyMessage replyAuthor:replyPeer viaUser:viaUser webPage:webPage];
                        if (useAuthor) {
                            [self _setupMessageAuthor:model];
                        }
                        if (webpageIndex != -1) {
                            TGWebPageMediaAttachment *webPage = message.mediaAttachments[webpageIndex];
                            if (webPage.title.length != 0 || webPage.pageDescription.length != 0 || webPage.siteName.length != 0 || [webPage.photo.imageInfo imageUrlForLargestSize:NULL] != nil || [webPage.document.thumbnailInfo imageUrlForLargestSize:NULL] != nil || webPage.document != nil) {
                                [model setWebPageFooter:webPage invoice:nil viewStorage:nil];
                            }
                        }

                        model.collapseFlags = _collapseFlags;
                        [model layoutForContainerSize:containerSize];
                        return model;
                    }
                }
                case TGVideoMediaAttachmentType:
                {
                    if (((TGVideoMediaAttachment *)attachment).videoId == 0 && ((TGVideoMediaAttachment *)attachment).localVideoId == 0 && message.messageLifetime > 0) {
                        TGActionMediaAttachment *action = [[TGActionMediaAttachment alloc] init];
                        action.actionType = TGMessageActionCustom;
                        action.actionData = @{@"expiredMedia": attachment};
                        TGNotificationMessageViewModel *model = [[TGNotificationMessageViewModel alloc] initWithMessage:_message actionMedia:action authorPeer:[self currentAuthorPeer] additionalUsers:_additionalUsers context:_context];
                        model.collapseFlags = _collapseFlags;
                        [model layoutForContainerSize:containerSize];
                        return model;
                    } else {
                        if (!((TGVideoMediaAttachment *)attachment).roundMessage)
                        {
                            TGVideoMessageViewModel *model = [[TGVideoMessageViewModel alloc] initWithMessage:message imageInfo:((TGVideoMediaAttachment *)attachment).thumbnailInfo video:(TGVideoMediaAttachment *)attachment authorPeer:useAuthor ? [self currentAuthorPeer] : nil context:_context forwardPeer:forwardPeer forwardAuthor:forwardAuthor forwardMessageId:forwardMessageId replyHeader:replyMessage replyAuthor:replyPeer viaUser:viaUser webPage:webPage];
                            if (useAuthor) {
                                [self _setupMessageAuthor:model];
                            }
                            if (webpageIndex != -1) {
                                TGWebPageMediaAttachment *webPage = message.mediaAttachments[webpageIndex];
                                if (webPage.title.length != 0 || webPage.pageDescription.length != 0 || webPage.siteName.length != 0 || [webPage.photo.imageInfo imageUrlForLargestSize:NULL] != nil || [webPage.document.thumbnailInfo imageUrlForLargestSize:NULL] != nil || webPage.document != nil) {
                                    [model setWebPageFooter:webPage invoice:nil viewStorage:nil];
                                }
                            }
                            model.collapseFlags = _collapseFlags;
                            [model layoutForContainerSize:containerSize];
                            return model;
                        }
                        else
                        {
                            TGRoundMessageViewModel *model = [[TGRoundMessageViewModel alloc] initWithMessage:_message video:(TGVideoMediaAttachment *)attachment authorPeer:useAuthor ? [self currentAuthorPeer] : nil context:_context forwardPeer:forwardPeer forwardAuthor:forwardAuthor forwardMessageId:forwardMessageId replyHeader:replyMessage replyPeer:replyPeer];
                            if (useAuthor) {
                                [self _setupMessageAuthor:model];
                            }
                            model.collapseFlags = _collapseFlags;
                            [model layoutForContainerSize:containerSize];
                            return model;
                        }
                    }
                }
                case TGLocationMediaAttachmentType:
                {
                    TGLocationMediaAttachment *locationAttachment = (TGLocationMediaAttachment *)attachment;
                    TGMessageViewModel *model = nil;

                    if (locationAttachment.venue)
                    {
                        TGVenueMessageViewModel *venueModel = [[TGVenueMessageViewModel alloc] initWithLatitude:locationAttachment.latitude longitude:locationAttachment.longitude venue:locationAttachment.venue message:message authorPeer:useAuthor ? [self currentAuthorPeer] : nil viaUser:viaUser context:_context];
                        if (useAuthor) {
                            [self _setupMessageAuthor:venueModel];
                        }
                        
                        if (forwardPeer != nil) {
                            [venueModel setForwardHeader:forwardPeer forwardAuthor:forwardAuthor messageId:forwardMessageId forwardSignature:message.authorSignature];
                        }
                        
                        if (replyMessage != nil)
                        {
                            [venueModel setReplyHeader:replyMessage peer:replyPeer];
                        }
                        
                        model = venueModel;
                    }
                    else
                    {
                        TGMapMessageViewModel *mapModel = [[TGMapMessageViewModel alloc] initWithLatitude:locationAttachment.latitude longitude:locationAttachment.longitude message:message authorPeer:useAuthor ? [self currentAuthorPeer] : nil context:_context forwardPeer:forwardPeer forwardAuthor:forwardAuthor forwardMessageId:forwardMessageId replyHeader:replyMessage replyAuthor:replyPeer viaUser:viaUser];
                        if (useAuthor) {
                            [self _setupMessageAuthor:mapModel];
                        }
                        model = mapModel;
                    }
                    model.collapseFlags = _collapseFlags;
                    [model layoutForContainerSize:containerSize];
                    return model;
                }
                case TGContactMediaAttachmentType:
                {
                    contactIndex = index;
                    contactUid = ((TGContactMediaAttachment *)attachment).uid;
                    break;
                }
                case TGActionMediaAttachmentType:
                {
                    if (_message.actionInfo.actionType == TGMessageActionPhoneCall)
                    {
                        TGCallMessageViewModel *model = [[TGCallMessageViewModel alloc] initWithMessage:_message actionMedia:(TGActionMediaAttachment *)attachment authorPeer:[self currentAuthorPeer] additionalUsers:_additionalUsers context:_context];
                        model.collapseFlags = _collapseFlags;
                        [model layoutForContainerSize:containerSize];
                        return model;
                    }
                    else
                    {
                        TGNotificationMessageViewModel *model = [[TGNotificationMessageViewModel alloc] initWithMessage:_message actionMedia:(TGActionMediaAttachment *)attachment authorPeer:[self currentAuthorPeer] additionalUsers:_additionalUsers context:_context];
                        model.collapseFlags = _collapseFlags;
                        [model layoutForContainerSize:containerSize];
                        return model;
                    }
                }
                case TGDocumentMediaAttachmentType:
                {
                    TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                    
                    if (documentAttachment.documentId == 0 && documentAttachment.localDocumentId == 0 && message.messageLifetime > 0) {
                        TGActionMediaAttachment *action = [[TGActionMediaAttachment alloc] init];
                        action.actionType = TGMessageActionCustom;
                        action.actionData = @{@"expiredMedia": attachment};
                        TGNotificationMessageViewModel *model = [[TGNotificationMessageViewModel alloc] initWithMessage:_message actionMedia:action authorPeer:[self currentAuthorPeer] additionalUsers:_additionalUsers context:_context];
                        model.collapseFlags = _collapseFlags;
                        [model layoutForContainerSize:containerSize];
                        return model;
                    } else {
                        bool isAnimated = false;
                        CGSize imageSize = CGSizeZero;
                        bool isSticker = false;
                        bool isAudio = false;
                        bool isVoice = false;
                        int32_t duration = 0;
                        for (id attribute in documentAttachment.attributes)
                        {
                            if ([attribute isKindOfClass:[TGDocumentAttributeAnimated class]])
                            {
                                isAnimated = true;
                            }
                            else if ([attribute isKindOfClass:[TGDocumentAttributeImageSize class]])
                            {
                                imageSize = ((TGDocumentAttributeImageSize *)attribute).size;
                            }
                            else if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
                                imageSize = ((TGDocumentAttributeVideo *)attribute).size;
                            }
                            else if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
                            {
                                isSticker = true;
                            }
                            else if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]])
                            {
                                TGDocumentAttributeAudio *audio = attribute;
                                if (audio.isVoice) {
                                    isVoice = true;
                                } else {
                                    isAudio = true;
                                }
                                duration = audio.duration;
                            }
                        }
                        
                        if (isSticker)
                        {
                            if (imageSize.width <= FLT_EPSILON || imageSize.height <= FLT_EPSILON)
                            {
                                CGSize size = CGSizeZero;
                                [documentAttachment.thumbnailInfo imageUrlForLargestSize:&size];
                                if (size.width > FLT_EPSILON && size.height > FLT_EPSILON)
                                {
                                    imageSize = TGFillSize(TGFitSize(size, CGSizeMake(512.0f, 512.0f)), CGSizeMake(512.0f, 512.0f));
                                }
                                else
                                    imageSize = CGSizeMake(512.0f, 512.0f);
                            }
                            
                            if (imageSize.width > FLT_EPSILON && imageSize.height > FLT_EPSILON)
                            {
                                TGStickerMessageViewModel *model = [[TGStickerMessageViewModel alloc] initWithMessage:_message document:documentAttachment size:imageSize authorPeer:useAuthor ? [self currentAuthorPeer] : nil context:_context replyHeader:replyMessage replyPeer:replyPeer viaUser:viaUser];
                                if (useAuthor) {
                                    [self _setupMessageAuthor:model];
                                }
                                model.collapseFlags = _collapseFlags;
                                [model layoutForContainerSize:containerSize];
                                return model;
                            }
                        }
                        
                        if (TGPeerIdIsSecretChat(message.cid) && message.layer < 45) {
                            if ([documentAttachment.mimeType isEqualToString:@"video/mp4"] && ((imageSize.width > FLT_EPSILON && imageSize.height > FLT_EPSILON) || (documentAttachment.thumbnailInfo != nil && ![documentAttachment.thumbnailInfo empty]))) {
                                isAnimated = true;
                            }
                        }
                        
                        if ((isAnimated || [documentAttachment.mimeType isEqualToString:@"image/gif"]) && ((imageSize.width > FLT_EPSILON && imageSize.height > FLT_EPSILON) || (documentAttachment.thumbnailInfo != nil && ![documentAttachment.thumbnailInfo empty])))
                        {
                            TGAnimatedImageMessageViewModel *model = [[TGAnimatedImageMessageViewModel alloc] initWithMessage:_message imageInfo:documentAttachment.thumbnailInfo document:documentAttachment authorPeer:useAuthor ? [self currentAuthorPeer] : nil context:_context forwardPeer:forwardPeer forwardAuthor:forwardAuthor forwardMessageId:forwardMessageId replyHeader:replyMessage replyAuthor:replyPeer viaUser:viaUser caption:documentAttachment.caption textCheckingResults:documentAttachment.textCheckingResults];
                            if (useAuthor) {
                                [self _setupMessageAuthor:model];
                            }
                            
                            model.collapseFlags = _collapseFlags;
                            [model layoutForContainerSize:containerSize];
                            return model;
                        }
                        
                        if (isAudio)
                        {
                            TGMusicAudioMessageModel *model = [[TGMusicAudioMessageModel alloc] initWithMessage:_message authorPeer:useAuthor ? [self currentAuthorPeer] : nil viaUser:viaUser context:_context];
                            if (useAuthor) {
                                [self _setupMessageAuthor:model];
                            }
                            
                            if (forwardPeer != nil && [forwardPeer isKindOfClass:[TGConversation class]]) {
                                [model setForwardHeader:forwardPeer forwardAuthor:forwardAuthor messageId:forwardMessageId forwardSignature:message.authorSignature];
                            }
                            
                            if (replyMessage != nil)
                            {
                                [model setReplyHeader:replyMessage peer:replyPeer];
                            }
                            
                            model.collapseFlags = _collapseFlags;
                            [model layoutForContainerSize:containerSize];
                            return model;
                        }
                        
                        if (isVoice) {
                            TGAudioMessageViewModel *model = [[TGAudioMessageViewModel alloc] initWithMessage:_message duration:duration size:documentAttachment.size fileType:@"" authorPeer:useAuthor ? [self currentAuthorPeer] : nil viaUser:viaUser context:_context];
                            if (useAuthor) {
                                [self _setupMessageAuthor:model];
                            }
                            if (forwardPeer != nil)
                            {
                                [model setForwardHeader:forwardPeer forwardAuthor:forwardAuthor messageId:forwardMessageId forwardSignature:message.authorSignature];
                            }
                            if (replyMessage != nil)
                            {
                                [model setReplyHeader:replyMessage peer:replyPeer];
                            }
                            if (webpageIndex != -1) {
                                TGWebPageMediaAttachment *webPage = message.mediaAttachments[webpageIndex];
                                if (webPage.title.length != 0 || webPage.pageDescription.length != 0 || webPage.siteName.length != 0 || [webPage.photo.imageInfo imageUrlForLargestSize:NULL] != nil || [webPage.document.thumbnailInfo imageUrlForLargestSize:NULL] != nil || webPage.document != nil) {
                                    [model setWebPageFooter:webPage invoice:nil viewStorage:nil];
                                }
                            }
                            model.collapseFlags = _collapseFlags;
                            [model layoutForContainerSize:containerSize];
                            return model;
                        }
                        
                        TGDocumentMessageViewModel *model = [[TGDocumentMessageViewModel alloc] initWithMessage:_message document:(TGDocumentMediaAttachment *)attachment authorPeer:useAuthor ? [self currentAuthorPeer] : nil viaUser:viaUser context:_context];
                        if (useAuthor) {
                            [self _setupMessageAuthor:model];
                        }
                        
                        if (forwardPeer != nil)
                        {
                            [model setForwardHeader:forwardPeer forwardAuthor:forwardAuthor messageId:forwardMessageId forwardSignature:message.authorSignature];
                        }
                        
                        if (replyMessage != nil)
                        {
                            [model setReplyHeader:replyMessage peer:replyPeer];
                        }
                        
                        if (webpageIndex != -1) {
                            TGWebPageMediaAttachment *webPage = message.mediaAttachments[webpageIndex];
                            if (webPage.title.length != 0 || webPage.pageDescription.length != 0 || webPage.siteName.length != 0 || [webPage.photo.imageInfo imageUrlForLargestSize:NULL] != nil || [webPage.document.thumbnailInfo imageUrlForLargestSize:NULL] != nil || webPage.document != nil) {
                                [model setWebPageFooter:webPage invoice:nil viewStorage:nil];
                            }
                        }
                        
                        model.collapseFlags = _collapseFlags;
                        [model layoutForContainerSize:containerSize];
                        return model;
                    }
                }
                case TGAudioMediaAttachmentType:
                {
                    TGAudioMessageViewModel *model = [[TGAudioMessageViewModel alloc] initWithMessage:_message duration:((TGAudioMediaAttachment *)attachment).duration size:((TGAudioMediaAttachment *)attachment).fileSize fileType:@"" authorPeer:useAuthor ? [self currentAuthorPeer] : nil viaUser:viaUser context:_context];
                    if (useAuthor) {
                        [self _setupMessageAuthor:model];
                    }
                    if (forwardPeer != nil)
                    {
                        [model setForwardHeader:forwardPeer forwardAuthor:forwardAuthor messageId:forwardMessageId forwardSignature:message.authorSignature];
                    }
                    if (replyMessage != nil)
                    {
                        [model setReplyHeader:replyMessage peer:replyPeer];
                    }
                    
                    if (webpageIndex != -1) {
                        TGWebPageMediaAttachment *webPage = message.mediaAttachments[webpageIndex];
                        if (webPage.title.length != 0 || webPage.pageDescription.length != 0 || webPage.siteName.length != 0 || [webPage.photo.imageInfo imageUrlForLargestSize:NULL] != nil || [webPage.document.thumbnailInfo imageUrlForLargestSize:NULL] != nil || webPage.document != nil) {
                            [model setWebPageFooter:webPage invoice:nil viewStorage:nil];
                        }
                    }
                    
                    model.collapseFlags = _collapseFlags;
                    [model layoutForContainerSize:containerSize];
                    return model;
                }
                case TGUnsupportedMediaAttachmentType:
                {
                    unsupportedMessage = true;
                    break;
                }
                default:
                    break;
            }
        }
    }
    
    if (contactIndex != -1)
    {
        TGUser *contactUser = nil;
        for (TGUser *user in _additionalUsers)
        {
            if (user.uid == contactUid)
            {
                contactUser = user;
                break;
            }
        }
        
        TGContactMessageViewModel *model = [[TGContactMessageViewModel alloc] initWithMessage:_message contact:contactUser authorPeer:useAuthor ? [self currentAuthorPeer] : nil context:_context viaUser:viaUser];
        
        if (contactUser != nil)
        {
            if (forwardPeer != nil)
            {
                [model setForwardHeader:forwardPeer forwardAuthor:forwardAuthor messageId:forwardMessageId];
            }
            
            if (replyMessage != nil)
            {
                [model setReplyHeader:replyMessage peer:replyPeer];
            }
        }
        if (useAuthor) {
            [self _setupMessageAuthor:model];
        }
        
        model.collapseFlags = _collapseFlags;
        [model layoutForContainerSize:containerSize];
        return model;
    }
    
    TGTextMessageModernViewModel *model = [[TGTextMessageModernViewModel alloc] initWithMessage:message hasGame:(gameIndex != -1) hasInvoice:invoiceIndex != -1 authorPeer:useAuthor ? [self currentAuthorPeer] : nil viaUser:viaUser context:_context];
    if (unsupportedMessage)
        [model setIsUnsupported:true];
    
    if (forwardPeer != nil)
    {
        [model setForwardHeader:forwardPeer forwardAuthor:forwardAuthor messageId:forwardMessageId forwardSignature:message.forwardAuthorSignature];
    }
    if (replyMessage != nil)
    {
        [model setReplyHeader:replyMessage peer:replyPeer];
    }
    if (useAuthor) {
        [self _setupMessageAuthor:model];
    }
    if (webpageIndex != -1) {
        TGWebPageMediaAttachment *webPage = message.mediaAttachments[webpageIndex];
        if (webPage.title.length != 0 || webPage.pageDescription.length != 0 || webPage.siteName.length != 0 || [webPage.photo.imageInfo imageUrlForLargestSize:NULL] != nil || [webPage.document.thumbnailInfo imageUrlForLargestSize:NULL] != nil || webPage.document != nil) {
            [model setWebPageFooter:webPage invoice:nil viewStorage:nil];
        }
    } else if (gameIndex != -1) {
        TGGameMediaAttachment *game = message.mediaAttachments[gameIndex];
        [model setWebPageFooter:[game webPageWithText:message.text entities:message.entities] invoice:nil viewStorage:nil];
    }
    else if (invoiceIndex != -1) {
        TGInvoiceMediaAttachment *invoice = message.mediaAttachments[invoiceIndex];
        [model setWebPageFooter:[invoice webpage] invoice:invoice viewStorage:nil];
    }
    model.collapseFlags = _collapseFlags;
    [model layoutForContainerSize:containerSize];
    return model;
}

static inline TGCachedMessageType getMessageType(TGMessageModernConversationItem *item)
{
    if (item->_cachedMessageType == TGCachedMessageTypeUnknown)
    {
        if (item->_message.mediaAttachments.count != 0)
        {
            int index = -1;
            for (TGMediaAttachment *attachment in item->_message.mediaAttachments)
            {
                index++;
                
                switch (attachment.type)
                {
                    case TGImageMediaAttachmentType:
                    case TGVideoMediaAttachmentType:
                    case TGLocationMediaAttachmentType:
                    {
                        item->_cachedMessageType = TGCachedMessageTypeImage;
                        return item->_cachedMessageType;
                    }
                    case TGActionMediaAttachmentType:
                    {
                        item->_cachedMessageType = TGCachedMessageTypeNotification;
                        return item->_cachedMessageType;
                    }
                    default:
                        break;
                }
            }
        }
        
        item->_cachedMessageType = TGCachedMessageTypeText;
        return item->_cachedMessageType;
    }
    
    return item->_cachedMessageType;
}

- (bool)collapseWithItem:(TGMessageModernConversationItem *)item forContainerSize:(CGSize)__unused containerSize
{
    if (item->_message.outgoing == _message.outgoing)
    {
        if (!item->_message.outgoing && [item currentAuthorPeer] != nil)
            return false;
        
        TGCachedMessageType currentType = getMessageType(self);
        TGCachedMessageType anotherType = getMessageType(item);
        
        if ((currentType == TGCachedMessageTypeText || currentType == TGCachedMessageTypeImage) == (anotherType == TGCachedMessageTypeText || anotherType == TGCachedMessageTypeImage))
        {
            if (!_message.outgoing && (_message.fromUid != item->_message.fromUid))
                return false;
            return true;
        }
    }
    
    return false;
}

@end

