#import "TGTelegraphImageViewControllerCompanion.h"

#import "TGImageViewController.h"

#import "TGMessage.h"
#import "TGTelegraph.h"

#import "TGAppDelegate.h"

#import "TGForwardTargetController.h"

#import "SGraphObjectNode.h"

#import "TGDatabase.h"

#import "TGHacks.h"

#include <set>

@implementation TGMessageMediaItem

- (id)initWithMessage:(TGMessage *)message author:(TGUser *)author imageInfo:(TGImageInfo *)imageInfo
{
    self = [super init];
    if (self != nil)
    {
        _message = message;
        _author = author;
        _imageInfo = imageInfo;
        _type = TGMediaItemTypePhoto;
    }
    return self;
}

- (id)initWithMessage:(TGMessage *)message author:(TGUser *)author videoAttachment:(TGVideoMediaAttachment *)videoAttachment
{
    self = [super init];
    if (self != nil)
    {
        _message = message;
        _author = author;
        _videoAttachment = videoAttachment;
        _type = TGMediaItemTypeVideo;
    }
    return self;
}

- (void)replaceMessage:(TGMessage *)message
{
    _message = message;
    _cachedItemId = nil;
}

- (id)copyWithZone:(NSZone *)__unused zone
{
    TGMessageMediaItem *mediaItem = [[TGMessageMediaItem alloc] init];
    
    mediaItem.type = _type;
    mediaItem.imageInfo = _imageInfo;
    mediaItem.videoAttachment = _videoAttachment;
    mediaItem.author = _author;
    mediaItem.message = _message;
    
    return mediaItem;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[TGMessageMediaItem class]])
        return false;
    
    TGMessageMediaItem *other = (TGMessageMediaItem *)object;
    
    if (_type != other.type)
        return false;
    
    if ((_imageInfo == nil) != (other.imageInfo == nil) || (_imageInfo != nil && ![_imageInfo isEqual:other.imageInfo]))
        return false;
    
    if ((_videoAttachment != nil) != (other.videoAttachment != nil) || (_videoAttachment != nil && ![_videoAttachment isEqual:other.videoAttachment]))
        return false;
    
    if ((_author == nil) != (other.author == nil) || (_author != nil && ![_author isEqualToUser:other.author]))
        return false;
    
    if ((_message != nil) != (other.message != nil) || (_message != nil && _message.mid != other.message.mid))
        return false;
    
    return true;
}

- (id)itemId
{
    if (_cachedItemId == nil)
        _cachedItemId = [[NSNumber alloc] initWithInt:_message.mid];
    return _cachedItemId;
}

- (int)itemMessageId
{
    return _message.mid;
}

- (id)itemMediaId
{
    if (_videoAttachment != nil)
        return [[TGMediaId alloc] initWithType:1 itemId:_videoAttachment.videoId];
    else
    {
        for (TGMediaAttachment *attachment in _message.mediaAttachments)
        {
            if (attachment.type == TGImageMediaAttachmentType)
            {
                return [[TGMediaId alloc] initWithType:2 itemId:((TGImageMediaAttachment *)attachment).imageId];
            }
        }
    }
    
    return nil;
}

- (int)date
{
    return (int)_message.date;
}

- (int)authorUid
{
    return (int)(_message.fromUid);
}

- (bool)hasLocalId
{
    return _message.local;
}

- (UIImage *)immediateThumbnail
{
    return nil;
}

@end

#pragma mark -

@interface TGTelegraphImageViewControllerCompanion ()

@property (nonatomic) int64_t peerId;

@property (nonatomic, strong) NSMutableArray *messageList;
@property (nonatomic) int totalCount;

@property (nonatomic) int firstItemId;
@property (nonatomic) bool loadingFirstItems;
@property (nonatomic) bool applyFirstItems;

@property (nonatomic) bool isEncrypted;

@end

@implementation TGTelegraphImageViewControllerCompanion

- (id)initWithPeerId:(int64_t)peerId firstItemId:(int)firstItemId isEncrypted:(bool)isEncrypted
{
    self = [super init];
    if (self != nil)
    {
        _isEncrypted = isEncrypted;
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _peerId = peerId;
        
        _messageList = [[NSMutableArray alloc] init];
        
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            if (_peerId != 0)
            {
                _loadingFirstItems = true;
                
                _firstItemId = firstItemId;
                
                [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversations/(%lld)/mediahistory/(0-%d)", _peerId, firstItemId] options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:firstItemId], @"atMessageId", [NSNumber numberWithInt:50], @"limit", @(_isEncrypted), @"isEncrypted", nil] watcher:self];
            }
            
            [self subscribeToPaths];
        }];
    }
    return self;
}

- (void)subscribeToPaths
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [ActionStageInstance() watchForPath:[NSString stringWithFormat:@"/tg/conversation/(%lld)/messages", _peerId] watcher:self];
        [ActionStageInstance() watchForPath:[NSString stringWithFormat:@"/tg/conversation/(%lld)/messagesChanged", _peerId] watcher:self];
        [ActionStageInstance() watchForPath:[NSString stringWithFormat:@"/tg/conversation/(%lld)/messagesDeleted", _peerId] watcher:self];
    }];
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

#pragma mark -

- (void)forceDismiss
{
    [TGAppDelegateInstance dismissContentController];
}

- (void)updateItems:(id)currentItemId
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        if (!_loadingFirstItems)
        {
            NSArray *items = [[NSArray alloc] initWithArray:_messageList];
            
            int currentItemIndex = -1;
            
            int index = -1;
            for (TGMessageMediaItem *imageItem in _messageList)
            {
                index++;
                
                if ([imageItem.itemId isEqual:currentItemId])
                {
                    currentItemIndex = index;
                    break;
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                TGImageViewController *imageViewController = _imageViewController;
                
                [imageViewController itemsChanged:items totalCount:_totalCount canLoadMore:true];
                [imageViewController applyCurrentItem:currentItemIndex];
            });
        }
        else
        {
            _applyFirstItems = true;
        }
    }];
}

- (void)loadMoreItems
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        int remoteMessagesProcessed = 0;
        int minMid = INT_MAX;
        int minLocalMid = INT_MAX;
        int index = 0;
        int minDate = INT_MAX;
        
        if (_reverseOrder)
        {
            for (int i = 0; i < (int)_messageList.count && remoteMessagesProcessed < 10; i++)
            {
                TGMessageMediaItem *imageItem = [_messageList objectAtIndex:i];
                if (!imageItem.hasLocalId)
                {
                    remoteMessagesProcessed++;
                    if ([[imageItem itemId] intValue] < minMid)
                        minMid = [[imageItem itemId] intValue];
                    index++;
                }
                else
                {
                    if ([[imageItem itemId] intValue] < minLocalMid)
                        minLocalMid = [[imageItem itemId] intValue];
                }
                
                if ((int)imageItem.date < minDate)
                    minDate = (int)imageItem.date;
            }
        }
        else
        {
            for (int i = _messageList.count - 1; i >= 0 && remoteMessagesProcessed < 10; i--)
            {
                TGMessageMediaItem *imageItem = [_messageList objectAtIndex:i];
                if (!imageItem.hasLocalId)
                {
                    remoteMessagesProcessed++;
                    if ([[imageItem itemId] intValue] < minMid)
                        minMid = [[imageItem itemId] intValue];
                    index++;
                }
                else
                {
                    if ([[imageItem itemId] intValue] < minLocalMid)
                        minLocalMid = [[imageItem itemId] intValue];
                }
                
                if ((int)imageItem.date < minDate)
                    minDate = (int)imageItem.date;
            }
        }
        
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversations/(%lld)/mediahistory/(%d)", _peerId, minMid] options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:index], @"offset", [NSNumber numberWithInt:minLocalMid], @"maxLocalMid", [NSNumber numberWithInt:minDate], @"maxDate", [NSNumber numberWithInt:minMid], @"maxMid", [NSNumber numberWithInt:50], @"limit", [[NSNumber alloc] initWithBool:_reverseOrder], @"reverseOrder", @(_isEncrypted), @"isEncrypted", nil] watcher:self];
    }];
}

- (void)preloadCount
{
    if (_firstItemId != 0)
    {
        [TGDatabaseInstance() loadMediaPositionInConversation:_peerId messageId:_firstItemId completion:^(int position, int count)
        {
            _totalCount = count;
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                int resultPosition = position;
                int resultCount = count;
                if (!_reverseOrder)
                    resultPosition = count - position - 1;
                
                TGImageViewController *imageViewController = _imageViewController;
                [imageViewController positionInformationChanged:resultPosition totalCount:resultCount];
            });
        }];
    }
}

- (void)deleteItem:(id)itemId
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        int index = -1;
        for (TGMessageMediaItem *item in _messageList)
        {
            index++;
            
            if ([item.itemId isEqual:itemId])
            {
                [_messageList removeObjectAtIndex:index];
                _totalCount--;
                
                static int actionId = 1;
                [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%lld)/deleteMessages/(preview%d)", _peerId, actionId++] options:[NSDictionary dictionaryWithObject:[[NSArray alloc] initWithObjects:itemId, nil] forKey:@"mids"] watcher:TGTelegraphInstance];
                
                NSArray *newList = [_messageList copy];
                int newTotalCount = _totalCount;
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    TGImageViewController *imageViewController = _imageViewController;
                    [imageViewController itemsChanged:newList totalCount:newTotalCount tryToStayOnItemId:true];
                });
                
                break;
            }
        }
    }];
}

- (void)forwardItem:(id)itemId
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:[itemId intValue]];
        if (message == nil)
            message = [TGDatabaseInstance() loadMediaMessageWithMid:[itemId intValue]];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
         
            if (message != nil)
            {
                TGForwardTargetController *forwardController = [[TGForwardTargetController alloc] initWithForwardMessages:[[NSArray alloc] initWithObjects:message, nil] sendMessages:nil];
                forwardController.watcherHandle = _actionHandle;
                TGNavigationController *navigationController = [TGNavigationController navigationControllerWithRootController:forwardController];
                
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                {
                    navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
                    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                }
                
                TGImageViewController *imageViewController = _imageViewController;
                
                [imageViewController presentViewController:navigationController animated:true completion:nil];
            }
        });
    }];
}

- (bool)manualSavingEnabled
{
    return _peerId > INT_MIN && !TGAppDelegateInstance.autosavePhotos;
}

- (bool)mediaSavingEnabled
{
    return _peerId > INT_MIN;
}

- (bool)deletionEnabled
{
    return true;
}

- (bool)forwardingEnabled
{
    return _peerId > INT_MIN;
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messages", _peerId]])
    {
        NSArray *messages = [((SGraphObjectNode *)resource).object mutableCopy];
        
        NSMutableArray *mediaMessages = [[NSMutableArray alloc] init];
        for (TGMessage *message in messages)
        {
            NSArray *media = message.mediaAttachments;
            if (media != nil && media.count != 0)
            {
                for (TGMediaAttachment *attachment in media)
                {
                    if (attachment.type == TGImageMediaAttachmentType)
                    {
                        [mediaMessages addObject:message];
                        break;
                    }
                }
            }
        }
        
        if (mediaMessages.count == 0)
            return;
        
        std::set<int> existingMids;
        for (TGMessageMediaItem *imageItem in _messageList)
        {
            existingMids.insert([[imageItem itemId] intValue]);
        }
        
        int addedCount = 0;
        
        for (TGMessage *message in mediaMessages)
        {
            if (existingMids.find(message.mid) == existingMids.end())
            {
                for (TGMediaAttachment *attachment in message.mediaAttachments)
                {
                    if (attachment.type == TGImageMediaAttachmentType)
                    {
                        TGMessageMediaItem *imageItem = [[TGMessageMediaItem alloc] initWithMessage:message author:[TGDatabaseInstance() loadUser:(int)message.fromUid] imageInfo:((TGImageMediaAttachment *)attachment).imageInfo];
                        [_messageList addObject:imageItem];
                        
                        addedCount++;
                    }
                    else if (attachment.type == TGVideoMediaAttachmentType)
                    {
                        TGMessageMediaItem *videoItem = [[TGMessageMediaItem alloc] initWithMessage:message author:[TGDatabaseInstance() loadUser:(int)message.fromUid] videoAttachment:(TGVideoMediaAttachment *)attachment];
                        [_messageList addObject:videoItem];
                        
                        addedCount++;
                    }
                }
            }
        }
        
        if (addedCount != 0)
        {
            [_messageList sortUsingComparator:^NSComparisonResult(TGMessageMediaItem *message1, TGMessageMediaItem *message2)
            {
                NSComparisonResult result = NSOrderedSame;
                
                NSTimeInterval delta = message1.date - message2.date;
                if (ABS(delta) < FLT_EPSILON)
                {
                    if (message1.hasLocalId != message2.hasLocalId)
                        result = NSOrderedSame;
                    result = [message2.itemId compare:message1.itemId];
                }
                else
                    result = delta < 0 ? NSOrderedDescending : NSOrderedAscending;
                
                if (_reverseOrder)
                {
                    if (result == NSOrderedAscending)
                        result = NSOrderedDescending;
                    else if (result == NSOrderedDescending)
                        result = NSOrderedAscending;
                }
                
                return result;
            }];
            
            _totalCount += addedCount;
            NSArray *items = [[NSArray alloc] initWithArray:_messageList];
            int totalCount = _totalCount;
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                TGImageViewController *imageViewController = _imageViewController;
                [imageViewController itemsChanged:items totalCount:totalCount tryToStayOnItemId:true];
            });
        }
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesChanged", _peerId]])
    {
        NSArray *midMessagePairs = ((SGraphObjectNode *)resource).object;
        if (midMessagePairs.count % 2 != 0)
            return;
        
        std::map<int, TGMessage *> midToNewMessage;
        int count = midMessagePairs.count;
        for (int i = 0; i < count; i += 2)
        {
            midToNewMessage.insert(std::pair<int, TGMessage *>([[midMessagePairs objectAtIndex:i] intValue], [midMessagePairs objectAtIndex:i + 1]));
        }
        
        bool haveChanges = false;
        
        int itemsCount = _messageList.count;
        for (int i = 0; i < itemsCount; i++)
        {
            TGMessageMediaItem *item = [_messageList objectAtIndex:i];
            std::map<int, TGMessage *>::iterator it = midToNewMessage.find([[item itemId] intValue]);
            if (it != midToNewMessage.end())
            {
                item = [item copy];
                [item replaceMessage:it->second];
                
                [_messageList replaceObjectAtIndex:i withObject:item];    
                haveChanges = true;
            }
        }
        
        if (haveChanges)
        {
            NSArray *list = [_messageList copy];
            int totalCount = _totalCount;
            dispatch_async(dispatch_get_main_queue(), ^
            {
                TGImageViewController *imageViewController = _imageViewController;
                [imageViewController itemsChanged:list totalCount:totalCount tryToStayOnItemId:true];
            });
        }
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesDeleted", _peerId]])
    {
        [self deleteMessagesFromList:((SGraphObjectNode *)resource).object];
    }
}

- (void)actorCompleted:(int)resultCode path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:[NSString stringWithFormat:@"/tg/conversations/(%lld)/mediahistory/", _peerId]])
    {
        bool canLoadMore = false;
        
        if (resultCode == ASStatusSuccess)
        {
            NSDictionary *dict = ((SGraphObjectNode *)result).object;
            NSArray *mediaItems = [dict objectForKey:@"messages"];
            
            int returnedCount = [[dict objectForKey:@"count"] intValue];
            if (returnedCount >= 0)
                _totalCount = returnedCount;
            
            std::set<int> existingMids;
            for (TGMessageMediaItem *imageItem in _messageList)
            {
                existingMids.insert([[imageItem itemId] intValue]);
            }
            
            canLoadMore = mediaItems.count != 0;
            
            for (TGMessage *message in mediaItems)
            {
                if (existingMids.find(message.mid) != existingMids.end())
                    continue;
                
                for (TGMediaAttachment *attachment in message.mediaAttachments)
                {
                    if (attachment.type == TGImageMediaAttachmentType)
                    {
                        TGMessageMediaItem *imageItem = [[TGMessageMediaItem alloc] initWithMessage:message author:[TGDatabaseInstance() loadUser:(int)message.fromUid] imageInfo:((TGImageMediaAttachment *)attachment).imageInfo];
                        [_messageList addObject:imageItem];
                        
                        break;
                    }
                    else if (attachment.type == TGVideoMediaAttachmentType)
                    {
                        TGMessageMediaItem *imageItem = [[TGMessageMediaItem alloc] initWithMessage:message author:[TGDatabaseInstance() loadUser:(int)message.fromUid] videoAttachment:(TGVideoMediaAttachment *)attachment];
                        [_messageList addObject:imageItem];
                        
                        break;
                    }
                }
            }
        }
        else
        {
            canLoadMore = false;
        }
        
        [_messageList sortUsingComparator:^NSComparisonResult(TGMessageMediaItem *message1, TGMessageMediaItem *message2)
        {
            NSComparisonResult result = NSOrderedSame;
            
            NSTimeInterval delta = message1.date - message2.date;
            if (ABS(delta) < FLT_EPSILON)
            {
                if (message1.hasLocalId != message2.hasLocalId)
                {
                    result = message1.hasLocalId ? NSOrderedDescending : NSOrderedAscending;
                }
                else
                    result = [message2.itemId compare:message1.itemId];
            }
            else
                result = delta < 0 ? NSOrderedDescending : NSOrderedAscending;
            
            if (_reverseOrder)
            {
                if (result == NSOrderedAscending)
                    result = NSOrderedDescending;
                else if (result == NSOrderedDescending)
                    result = NSOrderedAscending;
            }
            
            return result;
        }];
        
        NSArray *items = [[NSArray alloc] initWithArray:_messageList];
        int totalCount = _totalCount;
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (_loadingFirstItems)
            {
                _loadingFirstItems = false;
                
                if (_applyFirstItems)
                {
                    _applyFirstItems = false;
                    
                    [self updateItems:[[NSNumber alloc] initWithInt:_firstItemId]];
                }
            }
            else
            {
                TGImageViewController *imageViewController = _imageViewController;
                [imageViewController itemsChanged:items totalCount:totalCount canLoadMore:canLoadMore];
            }
        });
    }
}

- (void)actionStageActionRequested:(NSString *)action options:(NSDictionary *)options
{
    if ([action isEqualToString:@"willForwardMessages"])
    {
        UIViewController *controller = [[options objectForKey:@"controller"] navigationController];
        if (controller == nil)
            return;
        
        TGImageViewController *imageViewController = _imageViewController;
        imageViewController.currentStatusBarStyle = UIStatusBarStyleDefault;
        imageViewController.view.hidden = true;
        
        [imageViewController.watcherHandle requestAction:@"hideImage" options:@{@"hide": @(true), @"messageId": @0, @"sender": imageViewController}];
        
        [imageViewController dismissViewControllerAnimated:true completion:^
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [TGAppDelegateInstance dismissContentController];
                [TGHacks setApplicationStatusBarAlpha:1.0f];
            });
        }];
    }
}

#pragma mark -

- (void)deleteMessagesFromList:(NSArray *)mids
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        std::set<int> midsSet;
        for (NSNumber *nMid in mids)
            midsSet.insert([nMid intValue]);
        
        int itemsCount = _messageList.count;
        
        int deletedCount = 0;
        
        for (int i = 0; i < itemsCount; i++)
        {
            TGMessageMediaItem *item = [_messageList objectAtIndex:i];
            if (midsSet.find([[item itemId] intValue]) != midsSet.end())
            {
                [_messageList removeObjectAtIndex:i];
                i--;
                itemsCount--;
                
                deletedCount++;
            }
        }
        
        if (deletedCount != 0)
        {
            NSArray *newList = [_messageList copy];
            _totalCount = MAX(0, _totalCount - deletedCount);
            int newTotalCount = _totalCount;
            dispatch_async(dispatch_get_main_queue(), ^
            {
                TGImageViewController *imageViewController = _imageViewController;
                [imageViewController itemsChanged:newList totalCount:newTotalCount tryToStayOnItemId:true];
            });
        }
    }];
}

- (bool)editingEnabled
{
    return false;
}

- (void)activateEditing
{
}

@end
