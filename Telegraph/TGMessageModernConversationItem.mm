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

- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage sizeUpdated:(bool *)sizeUpdated
{
    [_viewModel updateMessage:message viewStorage:viewStorage sizeUpdated:sizeUpdated];
}

- (void)updateMediaVisibility
{
    [_viewModel updateMediaVisibility];
}

- (void)updateMessageAttributes
{
    [_viewModel updateMessageAttributes];
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

- (TGModernViewModel *)viewModel
{
    return _viewModel;
}

- (TGModernViewModel *)viewModelForContainerSize:(CGSize)containerSize
{
    bool updateCell = false;
    
    if (_viewModel == nil)
    {
        _viewModel = [self createMessageViewModel:_message containerSize:containerSize];
        [_viewModel updateMediaAvailability:_mediaAvailabilityStatus viewStorage:nil];
        updateCell = true;
    }
    else if (ABS(_viewModel.frame.size.width - containerSize.width) > FLT_EPSILON || _viewModel.collapseFlags != _collapseFlags || _layoutIsInvalid)
    {
        _layoutIsInvalid = false;
        
        _viewModel.collapseFlags = _collapseFlags;
        [_viewModel layoutForContainerSize:containerSize];
        updateCell = true;
    }
    
    if (updateCell)
    {
        if ([self boundCell] != nil)
            [self boundCell]->_needsRelativeBoundsUpdateNotifications = _viewModel.needsRelativeBoundsUpdates;
    }
    
    return _viewModel;
}

- (CGSize)sizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, [self viewModelForContainerSize:containerSize].frame.size.height);
}

- (void)updateToItem:(TGMessageModernConversationItem *)updatedItem viewStorage:(TGModernViewStorage *)viewStorage sizeChanged:(bool *)sizeChanged
{
    if ([updatedItem isKindOfClass:[TGMessageModernConversationItem class]])
    {
        if (_message != updatedItem->_message) // by reference
        {
            _message = updatedItem->_message;
            bool sizeUpdated = false;
            [self updateMessage:_message viewStorage:viewStorage sizeUpdated:&sizeUpdated];
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
            [_viewModel updateMediaAvailability:_mediaAvailabilityStatus viewStorage:viewStorage];
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

- (void)stopInlineMedia
{
    [_viewModel stopInlineMedia];
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
    } else if ([author isKindOfClass:[TGUser class]]) {
        TGUser *user = author;
        [model setAuthorAvatarUrl:user.photoUrlSmall];
        [model setAuthorNameColor:coloredNameForUid(user.uid, TGMessageModernConversationItemLocalUserId)];
    }
}

- (TGMessageViewModel *)createMessageViewModel:(TGMessage *)message containerSize:(CGSize)containerSize
{
    bool useAuthor = [self currentAuthorPeer] != nil && !message.outgoing;
    if (message.outgoing) {
        if ([[self currentAuthorPeer] isKindOfClass:[TGConversation class]]) {
            useAuthor = true;
        }
    }
    
    int forwardIndex = -1;
    int replyIndex = -1;
    int contactIndex = -1;
    int webpageIndex = -1;
    int32_t contactUid = 0;
    bool unsupportedMessage = false;
    
    TGMessage *replyMessage = nil;
    id replyPeer = nil;
    
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
            
            if (attachment.type == TGForwardedMessageMediaAttachmentType)
                forwardIndex = index;
            else if (attachment.type == TGReplyMessageMediaAttachmentType)
                replyIndex = index;
            else if (attachment.type == TGWebPageMediaAttachmentType)
                webpageIndex = index;
        }

        if (replyIndex != -1)
        {
            TGReplyMessageMediaAttachment *replyAttachment = message.mediaAttachments[replyIndex];
            int64_t replyPeerId = replyAttachment.replyMessage.fromUid;
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
            if (replyMessage == nil)
                replyIndex = -1;
        }
        
        index = -1;
        for (TGMediaAttachment *attachment in message.mediaAttachments)
        {
            index++;
            
            switch (attachment.type)
            {
                case TGImageMediaAttachmentType:
                {
                    id forwardPeer = nil;
                    int32_t forwardMessageId = 0;
                    if (forwardIndex != -1)
                    {
                        TGForwardedMessageMediaAttachment *forwardAttachment = message.mediaAttachments[forwardIndex];
                        forwardMessageId = forwardAttachment.forwardMid;
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
                    }
                    
                    TGPhotoMessageViewModel *model = [[TGPhotoMessageViewModel alloc] initWithMessage:message imageMedia:(TGImageMediaAttachment *)attachment authorPeer:useAuthor ? [self currentAuthorPeer] : nil context:_context forwardPeer:forwardPeer forwardMessageId:forwardMessageId replyHeader:replyMessage replyAuthor:replyPeer];
                    if (useAuthor) {
                        [self _setupMessageAuthor:model];
                    }

                    model.collapseFlags = _collapseFlags;
                    [model layoutForContainerSize:containerSize];
                    return model;
                }
                case TGVideoMediaAttachmentType:
                {
                    TGVideoMessageViewModel *model = [[TGVideoMessageViewModel alloc] initWithMessage:message imageInfo:((TGVideoMediaAttachment *)attachment).thumbnailInfo video:(TGVideoMediaAttachment *)attachment authorPeer:useAuthor ? [self currentAuthorPeer] : nil context:_context replyHeader:replyMessage replyAuthor:replyPeer];
                    if (useAuthor) {
                        [self _setupMessageAuthor:model];
                    }
                    model.collapseFlags = _collapseFlags;
                    [model layoutForContainerSize:containerSize];
                    return model;
                }
                case TGLocationMediaAttachmentType:
                {
                    TGLocationMediaAttachment *locationAttachment = (TGLocationMediaAttachment *)attachment;
                    TGMessageViewModel *model = nil;

                    if (locationAttachment.venue)
                    {
                        TGVenueMessageViewModel *venueModel = [[TGVenueMessageViewModel alloc] initWithLatitude:locationAttachment.latitude longitude:locationAttachment.longitude venue:locationAttachment.venue message:message authorPeer:useAuthor ? [self currentAuthorPeer] : nil context:_context];
                        if (useAuthor) {
                            [self _setupMessageAuthor:venueModel];
                        }
                        
                        if (forwardIndex != -1)
                        {
                            id forwardPeer = nil;
                            int32_t forwardMessageId = 0;
                            if (forwardIndex != -1)
                            {
                                TGForwardedMessageMediaAttachment *forwardAttachment = message.mediaAttachments[forwardIndex];
                                forwardMessageId = forwardAttachment.forwardMid;
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
                            }
                            
                            [venueModel setForwardHeader:forwardPeer messageId:forwardMessageId];
                        }
                        if (replyIndex != -1)
                        {
                            TGReplyMessageMediaAttachment *replyAttachment = message.mediaAttachments[replyIndex];
                            int64_t replyPeerId = replyAttachment.replyMessage.fromUid;
                            id replyPeer = nil;
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
                            [venueModel setReplyHeader:replyAttachment.replyMessage peer:replyPeer];
                        }
                        
                        model = venueModel;
                    }
                    else
                    {
                        TGMapMessageViewModel *mapModel = [[TGMapMessageViewModel alloc] initWithLatitude:locationAttachment.latitude longitude:locationAttachment.longitude message:message authorPeer:useAuthor ? [self currentAuthorPeer] : nil context:_context replyHeader:replyMessage replyAuthor:replyPeer];
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
                    TGNotificationMessageViewModel *model = [[TGNotificationMessageViewModel alloc] initWithMessage:_message actionMedia:(TGActionMediaAttachment *)attachment authorPeer:[self currentAuthorPeer] additionalUsers:_additionalUsers context:_context];
                    model.collapseFlags = _collapseFlags;
                    [model layoutForContainerSize:containerSize];
                    return model;
                }
                case TGDocumentMediaAttachmentType:
                {
                    TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                    
                    bool isAnimated = false;
                    CGSize imageSize = CGSizeZero;
                    bool isSticker = false;
                    bool isAudio = false;
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
                        else if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
                        {
                            isSticker = true;
                        }
                        else if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]])
                        {
                            isAudio = true;
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
                            TGStickerMessageViewModel *model = [[TGStickerMessageViewModel alloc] initWithMessage:_message document:documentAttachment size:imageSize authorPeer:useAuthor ? [self currentAuthorPeer] : nil context:_context replyHeader:replyMessage replyPeer:replyPeer];
                            if (useAuthor) {
                                [self _setupMessageAuthor:model];
                            }
                            model.collapseFlags = _collapseFlags;
                            [model layoutForContainerSize:containerSize];
                            return model;
                        }
                    }
                    
                    if ((isAnimated || [documentAttachment.mimeType isEqualToString:@"image/gif"]) && ((imageSize.width > FLT_EPSILON && imageSize.height > FLT_EPSILON) || (documentAttachment.thumbnailInfo != nil && ![documentAttachment.thumbnailInfo empty])))
                    {
                        TGAnimatedImageMessageViewModel *model = [[TGAnimatedImageMessageViewModel alloc] initWithMessage:_message imageInfo:documentAttachment.thumbnailInfo document:documentAttachment authorPeer:useAuthor ? [self currentAuthorPeer] : nil context:_context replyHeader:replyMessage replyAuthor:replyPeer];
                        if (useAuthor) {
                            [self _setupMessageAuthor:model];
                        }
                        model.collapseFlags = _collapseFlags;
                        [model layoutForContainerSize:containerSize];
                        return model;
                    }
                    
                    if (isAudio)
                    {
                        TGMusicAudioMessageModel *model = [[TGMusicAudioMessageModel alloc] initWithMessage:_message authorPeer:useAuthor ? [self currentAuthorPeer] : nil context:_context];
                        if (useAuthor) {
                            [self _setupMessageAuthor:model];
                        }
                        model.collapseFlags = _collapseFlags;
                        [model layoutForContainerSize:containerSize];
                        return model;
                    }
                    
                    TGDocumentMessageViewModel *model = [[TGDocumentMessageViewModel alloc] initWithMessage:_message document:(TGDocumentMediaAttachment *)attachment authorPeer:useAuthor ? [self currentAuthorPeer] : nil context:_context];
                    if (useAuthor) {
                        [self _setupMessageAuthor:model];
                    }
                    
                    if (forwardIndex != -1)
                    {
                        id forwardPeer = nil;
                        int32_t forwardMessageId = 0;
                        if (forwardIndex != -1)
                        {
                            TGForwardedMessageMediaAttachment *forwardAttachment = message.mediaAttachments[forwardIndex];
                            int64_t forwardPeerId = forwardAttachment.forwardPeerId;
                            forwardMessageId = forwardAttachment.forwardMid;
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
                        }
                        [model setForwardHeader:forwardPeer messageId:forwardMessageId];
                    }
                    
                    if (replyIndex != -1)
                    {
                        TGReplyMessageMediaAttachment *replyAttachment = message.mediaAttachments[replyIndex];
                        [model setReplyHeader:replyAttachment.replyMessage peer:replyPeer];
                    }
                    
                    model.collapseFlags = _collapseFlags;
                    [model layoutForContainerSize:containerSize];
                    return model;
                }
                case TGAudioMediaAttachmentType:
                {
                    TGAudioMessageViewModel *model = [[TGAudioMessageViewModel alloc] initWithMessage:_message duration:((TGAudioMediaAttachment *)attachment).duration size:((TGAudioMediaAttachment *)attachment).fileSize fileType:@"" authorPeer:useAuthor ? [self currentAuthorPeer] : nil context:_context];
                    if (useAuthor) {
                        [self _setupMessageAuthor:model];
                    }
                    if (forwardIndex != -1)
                    {
                        id forwardPeer = nil;
                        int32_t forwardMessageId = 0;
                        if (forwardIndex != -1)
                        {
                            TGForwardedMessageMediaAttachment *forwardAttachment = message.mediaAttachments[forwardIndex];
                            int64_t forwardPeerId = forwardAttachment.forwardPeerId;
                            forwardMessageId = forwardAttachment.forwardMid;
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
                        }
                        [model setForwardHeader:forwardPeer messageId:forwardMessageId];
                    }
                    if (replyIndex != -1)
                    {
                        TGReplyMessageMediaAttachment *replyAttachment = message.mediaAttachments[replyIndex];
                        [model setReplyHeader:replyAttachment.replyMessage peer:replyPeer];
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
        
        TGContactMessageViewModel *model = [[TGContactMessageViewModel alloc] initWithMessage:_message contact:contactUser authorPeer:useAuthor ? [self currentAuthorPeer] : nil context:_context];
        
        if (contactUser != nil)
        {
            if (forwardIndex != -1)
            {
                id forwardPeer = nil;
                if (forwardIndex != -1)
                {
                    TGForwardedMessageMediaAttachment *forwardAttachment = message.mediaAttachments[forwardIndex];
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
                }
                
                [model setForwardHeader:forwardPeer];
            }
            
            if (replyIndex != -1)
            {
                TGReplyMessageMediaAttachment *replyAttachment = message.mediaAttachments[replyIndex];
                [model setReplyHeader:replyAttachment.replyMessage peer:replyPeer];
            }
        }
        if (useAuthor) {
            [self _setupMessageAuthor:model];
        }
        
        model.collapseFlags = _collapseFlags;
        [model layoutForContainerSize:containerSize];
        return model;
    }
    
    TGTextMessageModernViewModel *model = [[TGTextMessageModernViewModel alloc] initWithMessage:message authorPeer:useAuthor ? [self currentAuthorPeer] : nil context:_context];
    if (unsupportedMessage)
        [model setIsUnsupported:true];
    
    if (forwardIndex != -1)
    {
        id forwardPeer = nil;
        int32_t forwardMessageId = 0;
        if (forwardIndex != -1)
        {
            TGForwardedMessageMediaAttachment *forwardAttachment = message.mediaAttachments[forwardIndex];
            int64_t forwardPeerId = forwardAttachment.forwardPeerId;
            forwardMessageId = forwardAttachment.forwardMid;
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
        }
        [model setForwardHeader:forwardPeer messageId:forwardMessageId];
    }
    if (replyIndex != -1)
    {
        TGReplyMessageMediaAttachment *replyAttachment = message.mediaAttachments[replyIndex];
        [model setReplyHeader:replyAttachment.replyMessage peer:replyPeer];
    }
    if (useAuthor) {
        [self _setupMessageAuthor:model];
    }
    if (webpageIndex != -1)
        [model setWebPageFooter:message.mediaAttachments[webpageIndex] viewStorage:nil];
    
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

