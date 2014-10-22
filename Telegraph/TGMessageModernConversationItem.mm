#import "TGMessageModernConversationItem.h"

#import "NSObject+TGLock.h"

#import "TGUser.h"
#import "TGMessage.h"
#import "TGMessageViewModel.h"
#import "TGPhotoMessageViewModel.h"
#import "TGVideoMessageViewModel.h"
#import "TGMapMessageViewModel.h"
#import "TGContactMessageViewModel.h"
#import "TGDocumentMessageViewModel.h"
#import "TGNotificationMessageViewModel.h"
#import "TGAudioMessageViewModel.h"
#import "TGAnimatedImageMessageViewModel.h"
#import "TGYoutubeMessageViewModel.h"
#import "TGInstagramMessageViewModel.h"

#import "TGPreparedLocalDocumentMessage.h"

#import "TGTextMessageModernViewModel.h"

#import "TGModernCollectionCell.h"

#import "TGInterfaceAssets.h"

#import <map>
#import <CommonCrypto/CommonDigest.h>

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

- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage
{
    [_viewModel updateMessage:message viewStorage:viewStorage];
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

- (void)updateToItem:(TGMessageModernConversationItem *)updatedItem viewStorage:(TGModernViewStorage *)viewStorage
{
    if ([updatedItem isKindOfClass:[TGMessageModernConversationItem class]])
    {
        if (_message != updatedItem->_message) // by reference
        {
            _message = updatedItem->_message;
            [self updateMessage:_message viewStorage:viewStorage];
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

- (TGMessageViewModel *)createMessageViewModel:(TGMessage *)message containerSize:(CGSize)containerSize
{
    bool useAuthor = _author != nil && !message.outgoing;
    
    int forwardIndex = -1;
    int contactIndex = -1;
    int32_t contactUid = 0;
    bool unsupportedMessage = false;
    
    if (message.mediaAttachments.count != 0)
    {
        int index = -1;
        for (TGMediaAttachment *attachment in message.mediaAttachments)
        {
            index++;
            
            if (attachment.type == TGForwardedMessageMediaAttachmentType)
            {
                forwardIndex = index;
                
                break;
            }
        }
        
        index = -1;
        for (TGMediaAttachment *attachment in message.mediaAttachments)
        {
            index++;
            
            switch (attachment.type)
            {
                case TGImageMediaAttachmentType:
                {
                    TGPhotoMessageViewModel *model = [[TGPhotoMessageViewModel alloc] initWithMessage:message imageMedia:(TGImageMediaAttachment *)attachment author:useAuthor ? _author : nil context:_context];
                    if (useAuthor)
                        [model setAuthorAvatarUrl:_author.photoUrlSmall];
                    model.collapseFlags = _collapseFlags;
                    [model layoutForContainerSize:containerSize];
                    return model;
                }
                case TGVideoMediaAttachmentType:
                {
                    TGVideoMessageViewModel *model = [[TGVideoMessageViewModel alloc] initWithMessage:message imageInfo:((TGVideoMediaAttachment *)attachment).thumbnailInfo video:(TGVideoMediaAttachment *)attachment author:useAuthor ? _author : nil context:_context];
                    if (useAuthor)
                        [model setAuthorAvatarUrl:_author.photoUrlSmall];
                    model.collapseFlags = _collapseFlags;
                    [model layoutForContainerSize:containerSize];
                    return model;
                }
                case TGLocationMediaAttachmentType:
                {
                    TGMapMessageViewModel *model = [[TGMapMessageViewModel alloc] initWithLatitude:((TGLocationMediaAttachment *)attachment).latitude longitude:((TGLocationMediaAttachment *)attachment).longitude message:message author:useAuthor ? _author : nil context:_context];
                    if (useAuthor)
                        [model setAuthorAvatarUrl:_author.photoUrlSmall];
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
                    TGNotificationMessageViewModel *model = [[TGNotificationMessageViewModel alloc] initWithMessage:_message actionMedia:(TGActionMediaAttachment *)attachment author:_author additionalUsers:_additionalUsers context:_context];
                    model.collapseFlags = _collapseFlags;
                    [model layoutForContainerSize:containerSize];
                    return model;
                }
                case TGDocumentMediaAttachmentType:
                {
                    TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                    
                    if ([documentAttachment.mimeType isEqualToString:@"image/gif"] && documentAttachment.thumbnailInfo != nil && ![documentAttachment.thumbnailInfo empty])
                    {   
                        TGAnimatedImageMessageViewModel *model = [[TGAnimatedImageMessageViewModel alloc] initWithMessage:_message imageInfo:documentAttachment.thumbnailInfo document:documentAttachment author:useAuthor ? _author : nil context:_context];
                        if (useAuthor)
                            [model setAuthorAvatarUrl:_author.photoUrlSmall];
                        model.collapseFlags = _collapseFlags;
                        [model layoutForContainerSize:containerSize];
                        return model;
                    }
                    else
                    {
                        TGDocumentMessageViewModel *model = [[TGDocumentMessageViewModel alloc] initWithMessage:_message document:(TGDocumentMediaAttachment *)attachment author:useAuthor ? _author : nil context:_context];
                        if (useAuthor)
                        {
                            [model setAuthorNameColor:coloredNameForUid(_author.uid, TGMessageModernConversationItemLocalUserId)];
                            [model setAuthorAvatarUrl:_author.photoUrlSmall];
                        }
                        
                        if (forwardIndex != -1)
                        {
                            TGForwardedMessageMediaAttachment *forwardAttachment = message.mediaAttachments[forwardIndex];
                            int forwardUid = forwardAttachment.forwardUid;
                            TGUser *forwardUser = nil;
                            for (TGUser *user in _additionalUsers)
                            {
                                if (user.uid == forwardUid)
                                {
                                    forwardUser = user;
                                    break;
                                }
                            }
                            [model setForwardHeader:forwardUser];
                        }
                        
                        model.collapseFlags = _collapseFlags;
                        [model layoutForContainerSize:containerSize];
                        return model;
                    }
                }
                case TGAudioMediaAttachmentType:
                {
                    TGAudioMessageViewModel *model = [[TGAudioMessageViewModel alloc] initWithMessage:_message audio:(TGAudioMediaAttachment *)attachment author:useAuthor ? _author : nil context:_context];
                    if (useAuthor)
                    {
                        [model setAuthorNameColor:coloredNameForUid(_author.uid, TGMessageModernConversationItemLocalUserId)];
                        [model setAuthorAvatarUrl:_author.photoUrlSmall];
                    }
                    if (forwardIndex != -1)
                    {
                        TGForwardedMessageMediaAttachment *forwardAttachment = message.mediaAttachments[forwardIndex];
                        int forwardUid = forwardAttachment.forwardUid;
                        TGUser *forwardUser = nil;
                        for (TGUser *user in _additionalUsers)
                        {
                            if (user.uid == forwardUid)
                            {
                                forwardUser = user;
                                break;
                            }
                        }
                        [model setForwardHeader:forwardUser];
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
        
        TGContactMessageViewModel *model = [[TGContactMessageViewModel alloc] initWithMessage:_message contact:contactUser author:useAuthor ? _author : nil context:_context];
        
        if (contactUser != nil)
        {
            if (forwardIndex != -1)
            {
                TGForwardedMessageMediaAttachment *forwardAttachment = message.mediaAttachments[forwardIndex];
                int forwardUid = forwardAttachment.forwardUid;
                TGUser *forwardUser = nil;
                for (TGUser *user in _additionalUsers)
                {
                    if (user.uid == forwardUid)
                    {
                        forwardUser = user;
                        break;
                    }
                }
                [model setForwardHeader:forwardUser];
            }
        }
        if (useAuthor)
        {
            [model setAuthorNameColor:coloredNameForUid(_author.uid, TGMessageModernConversationItemLocalUserId)];
            [model setAuthorAvatarUrl:_author.photoUrlSmall];
        }
        
        model.collapseFlags = _collapseFlags;
        [model layoutForContainerSize:containerSize];
        return model;
    }
    
    if ([message.text hasPrefix:@"http://youtu.be/"])
    {
        TGYoutubeMessageViewModel *model = [[TGYoutubeMessageViewModel alloc] initWithVideoId:[message.text substringFromIndex:@"http://youtu.be/".length] message:message author:useAuthor ? _author : nil context:_context];
        model.collapseFlags = _collapseFlags;
        [model layoutForContainerSize:containerSize];
        return model;
    }
    else if ([message.text hasPrefix:@"http://instagram.com/p/"])
    {
        NSString *shortcode = [message.text substringFromIndex:@"http://instagram.com/p/".length];
        if ([shortcode hasSuffix:@"/"])
            shortcode = [shortcode substringToIndex:shortcode.length - 1];
        
        TGInstagramMessageViewModel *model = [[TGInstagramMessageViewModel alloc] initWithShortcode:shortcode message:message author:useAuthor ? _author : nil context:_context];
        model.collapseFlags = _collapseFlags;
        [model layoutForContainerSize:containerSize];
        return model;
    }
    
    TGTextMessageModernViewModel *model = [[TGTextMessageModernViewModel alloc] initWithMessage:message author:useAuthor ? _author : nil context:_context];
    if (unsupportedMessage)
        [model setIsUnsupported:true];
    
    if (forwardIndex != -1)
    {
        TGForwardedMessageMediaAttachment *forwardAttachment = message.mediaAttachments[forwardIndex];
        int forwardUid = forwardAttachment.forwardUid;
        TGUser *forwardUser = nil;
        for (TGUser *user in _additionalUsers)
        {
            if (user.uid == forwardUid)
            {
                forwardUser = user;
                break;
            }
        }
        [model setForwardHeader:forwardUser];
    }
    if (useAuthor)
    {
        [model setAuthorNameColor:coloredNameForUid(_author.uid, TGMessageModernConversationItemLocalUserId)];
        [model setAuthorAvatarUrl:_author.photoUrlSmall];
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
        if (!item->_message.outgoing && item->_author != nil)
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

