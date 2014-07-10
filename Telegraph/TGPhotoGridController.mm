#import "TGPhotoGridController.h"

#import "SGraphObjectNode.h"

#import "TGAppDelegate.h"
#import "TGTelegraph.h"

#import "TGActionTableView.h"

#import "TGMessage.h"

#import "TGPhotoGridCell.h"

#import "TGRemoteImageView.h"
#import "TGNavigationBar.h"
#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGDatabase.h"

#import "TGImageViewController.h"
#import "TGTelegraphImageViewControllerCompanion.h"

#import "TGHacks.h"

#import "TGMediaItem.h"

#import <QuartzCore/QuartzCore.h>

#include <set>

@interface TGPhotoGridController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) int64_t conversationId;
@property (nonatomic) bool isEncrypted;

@property (nonatomic, strong) TGActionTableView *tableView;

@property (nonatomic, strong) UIView *placeholderContainerView;

@property (nonatomic, strong) UIActivityIndicatorView *loadingActivityIndicator;

@property (nonatomic, strong) NSMutableArray *internalListModel;
@property (nonatomic, strong) NSArray *presentationListModel;
@property (nonatomic) int imagesPerRow;

@property (nonatomic) bool onceLoaded;
@property (nonatomic) bool loadingMore;
@property (nonatomic) bool canLoadMore;

@property (nonatomic) bool appearAnimation;

@end

@implementation TGPhotoGridController

- (id)initWithConversationId:(int64_t)conversationId isEncrypted:(bool)isEncrypted
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _isEncrypted = isEncrypted;
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        self.wantsFullScreenLayout = true;
        
        _conversationId = conversationId;
        
        _internalListModel = [[NSMutableArray alloc] init];
        
        [self subscribeToPaths];
    }
    return self;
}

- (void)dealloc
{
    [self doUnloadView];
    
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)subscribeToPaths
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [ActionStageInstance() watchForPath:[NSString stringWithFormat:@"/tg/conversation/(%lld)/messages", _conversationId] watcher:self];
        [ActionStageInstance() watchForPath:[NSString stringWithFormat:@"/tg/conversation/(%lld)/messagesChanged", _conversationId] watcher:self];
        [ActionStageInstance() watchForPath:[NSString stringWithFormat:@"/tg/conversation/(%lld)/messagesDeleted", _conversationId] watcher:self];
        [ActionStageInstance() watchForPath:@"/as/media/imageThumbnailUpdated" watcher:self];
    }];
}

- (UIBarStyle)requiredNavigationBarStyle
{
    return UIBarStyleDefault;
}

- (bool)navigationBarShouldBeHidden
{
    return false;
}

- (bool)statusBarShouldBeHidden
{
    return false;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (CGSize)referenceViewSizeForOrientation:(UIInterfaceOrientation)orientation
{
    if (TGIsPad())
        return self.view.frame.size;
    else
        return [TGViewController screenSizeForInterfaceOrientation:orientation];
}

- (void)loadView
{
    [super loadView];
    
    self.titleText = TGLocalized(@"ConversationMedia.Title");
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _loadingActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadingActivityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    _imagesPerRow = (int)([self referenceViewSizeForOrientation:self.interfaceOrientation].width / (75 + 4));
    
    _tableView = [[TGActionTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_tableView enableSwipeToLeftAction];
    
    [self setExplicitTableInset:UIEdgeInsetsMake(0, 0, 4, 0) scrollIndicatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];

    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)doUnloadView
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
}

- (void)viewDidUnload
{
    [self doUnloadView];
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    _appearAnimation = true;
    
    if (!_onceLoaded)
    {
        _loadingMore = true;
        
        _loadingActivityIndicator.hidden = false;
        if (![_loadingActivityIndicator isAnimating])
            [_loadingActivityIndicator startAnimating];
        
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversations/(%lld)/mediahistory/(0)", _conversationId] options:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:50], @"limit", @(_isEncrypted), @"isEncrypted", nil] watcher:self];
    }
    
    int imagesPerRow = (int)([self referenceViewSizeForOrientation:self.interfaceOrientation].width / (75 + 4));
    if (imagesPerRow != _imagesPerRow)
    {
        _imagesPerRow = imagesPerRow;
        [self reloadData];
    }
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    _appearAnimation = false;
    
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return true;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, true, 0.0f);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *tableImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *temporaryImageView = [[UIImageView alloc] initWithImage:tableImage];
    temporaryImageView.frame = self.view.bounds;
    [self.view insertSubview:temporaryImageView aboveSubview:_tableView];
    
    [UIView animateWithDuration:duration animations:^
    {
        temporaryImageView.alpha = 0.0f;
    } completion:^(__unused BOOL finished)
    {
        [temporaryImageView removeFromSuperview];
    }];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    int imagesPerRow = (int)([self referenceViewSizeForOrientation:toInterfaceOrientation].width / (75 + 4));
    if (_imagesPerRow != imagesPerRow)
        [self reloadData];
    
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)__unused section
{
    return _presentationListModel.count / _imagesPerRow + (_presentationListModel.count % _imagesPerRow != 0 ? 1 : 0);
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row * _imagesPerRow < (int)_presentationListModel.count)
        return (TGIsRetina() ? 78.5f : 78.0f) + 2.0f;
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int rowOffset = indexPath.row * _imagesPerRow;
    int count = _presentationListModel.count;
    if (rowOffset < count)
    {
        static NSString *gridCellIdentifier = @"GC";
        TGPhotoGridCell *gridCell = (TGPhotoGridCell *)[tableView dequeueReusableCellWithIdentifier:gridCellIdentifier];
        if (gridCell == nil)
        {
            gridCell = [[TGPhotoGridCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:gridCellIdentifier];
            gridCell.selectionStyle = UITableViewCellSelectionStyleNone;
            gridCell.watcherHandle = _actionHandle;
        }
        
        gridCell.numberOfImagePlaces = _imagesPerRow;
        [gridCell.imageUrls removeAllObjects];
        [gridCell.imageTags removeAllObjects];
        [gridCell.imageAttachments removeAllObjects];
        for (int i = rowOffset; i < rowOffset + _imagesPerRow && i < count; i++)
        {
            TGMessage *message = [_presentationListModel objectAtIndex:i];
            NSString *imageUrl = [message.additionalProperties objectForKey:@"url"];
            if (imageUrl != nil)
            {
                [gridCell.imageUrls addObject:imageUrl];
                [gridCell.imageTags addObject:[[NSNumber alloc] initWithInt:message.mid]];
                [gridCell.imageAttachments addObject:[message.additionalProperties objectForKey:@"attachment"]];
            }
        }
        
        [gridCell setNeedsLayout];
        
        return gridCell;
    }
    
    static NSString *loadingCellIdentifier = @"LC";
    UITableViewCell *loadingCell = [tableView dequeueReusableCellWithIdentifier:loadingCellIdentifier];
    if (loadingCell == nil)
    {
        loadingCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadingCellIdentifier];
        loadingCell.selectionStyle = UITableViewCellSelectionStyleNone;
        [loadingCell.contentView addSubview:_loadingActivityIndicator];
        _loadingActivityIndicator.frame = CGRectMake((int)((loadingCell.contentView.frame.size.width - _loadingActivityIndicator.frame.size.width) / 2), 14, _loadingActivityIndicator.frame.size.width, _loadingActivityIndicator.frame.size.height);
    }
    
    if (_loadingMore)
    {
        _loadingActivityIndicator.hidden = false;
        if (![_loadingActivityIndicator isAnimating])
            [_loadingActivityIndicator startAnimating];
    }
    else
    {
        _loadingActivityIndicator.hidden = true;
        if ([_loadingActivityIndicator isAnimating])
            [_loadingActivityIndicator stopAnimating];
    }
    
    return loadingCell;
}

- (void)tableView:(UITableView *)__unused tableView willDisplayCell:(UITableViewCell *)__unused cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_canLoadMore && !_loadingMore)
    {
        int rowCount = _presentationListModel.count / _imagesPerRow + (_presentationListModel.count % _imagesPerRow != 0 ? 1 : 0);
        if (indexPath.row + 4 >= rowCount)
        {
            _loadingMore = true;
            _loadingActivityIndicator.hidden = false;
            if (![_loadingActivityIndicator isAnimating])
                [_loadingActivityIndicator startAnimating];
            
            [self loadMore];
        }
    }
}

#pragma mark -

- (void)performClose
{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)performSwipeToLeftAction
{
    [self performClose];
}

- (void)reloadData
{
    NSMutableDictionary *temporaryImageCache = [[NSMutableDictionary alloc] init];
    for (UITableViewCell *cell in _tableView.visibleCells)
    {
        if ([cell isKindOfClass:[TGPhotoGridCell class]])
        {
            [((TGPhotoGridCell *)cell) collectCachedPhotos:temporaryImageCache];
        }
    }
    [[TGRemoteImageView sharedCache] addTemporaryCachedImagesSource:temporaryImageCache autoremove:true];
    [_tableView reloadData];
}

#pragma mark -

- (void)loadMore
{
    _loadingMore = true;
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        int remoteMessagesProcessed = 0;
        int minMid = INT_MAX;
        int minLocalMid = INT_MAX;
        int index = 0;
        int minDate = INT_MAX;
        
        for (int i = _internalListModel.count - 1; i >= 0 && remoteMessagesProcessed < 10; i--)
        {
            TGMessage *message = [_internalListModel objectAtIndex:i];
            if (!message.local)
            {
                remoteMessagesProcessed++;
                if (message.mid < minMid)
                    minMid = message.mid;
                index++;
            }
            else
            {
                if (message.mid < minLocalMid)
                    minLocalMid = message.mid;
            }
            
            if ((int)message.date < minDate)
                minDate = (int)message.date;
        }
        
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversations/(%lld)/mediahistory/(%d)", _conversationId, minMid] options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:index], @"offset", [NSNumber numberWithInt:minLocalMid], @"maxLocalMid", [NSNumber numberWithInt:minDate], @"maxDate", [NSNumber numberWithInt:minMid], @"maxMid", [NSNumber numberWithInt:50], @"limit", @(_isEncrypted), @"isEncrypted", nil] watcher:self];
    }];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messages", _conversationId]])
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
                    if (attachment.type == TGImageMediaAttachmentType || attachment.type == TGVideoMediaAttachmentType)
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
        for (TGMessage *message in _internalListModel)
        {
            existingMids.insert(message.mid);
        }
        
        int addedCount = 0;
        
        CGSize imagePixelSize = CGSizeMake(100, 100);
        if (TGIsRetina())
        {
            imagePixelSize.width *= 2;
            imagePixelSize.height *= 2;
        }
        
        for (TGMessage *message in mediaMessages)
        {
            if (existingMids.find(message.mid) == existingMids.end())
            {
                for (TGMediaAttachment *attachment in message.mediaAttachments)
                {
                    if (attachment.type == TGImageMediaAttachmentType)
                    {
                        NSString *imageUrl = [((TGImageMediaAttachment *)attachment).imageInfo closestImageUrlWithSize:imagePixelSize resultingSize:NULL];
                        if (imageUrl != nil)
                        {
                            TGMessage *newMessage = [message copy];
                            newMessage.additionalProperties = [[NSDictionary alloc] initWithObjectsAndKeys:imageUrl, @"url", attachment, @"attachment", nil];
                            [_internalListModel addObject:newMessage];
                            
                            addedCount++;
                        }
                        
                        break;
                    }
                    else if (attachment.type == TGVideoMediaAttachmentType)
                    {
                        NSString *thumbUrl = [((TGVideoMediaAttachment *)attachment).thumbnailInfo closestImageUrlWithSize:imagePixelSize resultingSize:NULL];
                        if (thumbUrl != nil)
                        {
                            TGMessage *newMessage = [message copy];
                            newMessage.additionalProperties = [[NSDictionary alloc] initWithObjectsAndKeys:thumbUrl, @"url", attachment, @"attachment", nil];
                            [_internalListModel addObject:newMessage];
                            
                            addedCount++;
                        }
                    }
                }
                
            }
        }
        
        if (addedCount != 0)
        {
            [_internalListModel sortUsingComparator:^NSComparisonResult(TGMessage *message1, TGMessage *message2)
            {
                NSTimeInterval delta = message1.date - message2.date;
                if (ABS(delta) < FLT_EPSILON)
                {
                    if (message1.local != message2.local)
                        return NSOrderedSame;
                    return message1.mid < message2.mid ? NSOrderedDescending : NSOrderedAscending;
                }
                else
                    return delta < 0 ? NSOrderedDescending : NSOrderedAscending;
            }];

            NSArray *newPresentationListModel = [[NSArray alloc] initWithArray:_internalListModel];
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                _presentationListModel = newPresentationListModel;
                [self updatePlaceholder];
                [self reloadData];
            });
        }
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesChanged", _conversationId]])
    {
        /*NSArray *midMessagePairs = ((SGraphObjectNode *)node).object;
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
            TGImageItem *item = [_messageList objectAtIndex:i];
            std::map<int, TGMessage *>::iterator it = midToNewMessage.find(item.message.mid);
            if (it != midToNewMessage.end())
            {
                item = [item copy];
                item.message = it->second;
                
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
                [_imageViewController itemsChanged:list totalCount:totalCount];
            });
        }*/
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesDeleted", _conversationId]])
    {
        [self deleteMessagesFromList:((SGraphObjectNode *)resource).object];
    }
    if ([path isEqualToString:@"/as/media/imageThumbnailUpdated"])
    {
        NSString *thumbnailUrl = resource;
        
        bool foundUrl = false;
        
        for (TGMessage *message in _internalListModel)
        {
            for (TGMediaAttachment *attachment in message.mediaAttachments)
            {
                if (attachment.type == TGImageMediaAttachmentType)
                {
                    TGImageMediaAttachment *imageAttachment = (TGImageMediaAttachment *)attachment;
                    NSString *attachmentUrl = [imageAttachment.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
                    if (attachmentUrl != nil && [attachmentUrl isEqualToString:thumbnailUrl])
                        foundUrl = true;
                    break;
                }
                else if (attachment.type == TGVideoMediaAttachmentType)
                {
                    TGVideoMediaAttachment *videoAttachment = (TGVideoMediaAttachment *)attachment;
                    NSString *attachmentUrl = [videoAttachment.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
                    if (attachmentUrl != nil && [attachmentUrl isEqualToString:thumbnailUrl])
                        foundUrl = true;
                }
            }
            
            if (foundUrl)
                break;
        }
        
        if (foundUrl)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                for (id cell in _tableView.visibleCells)
                {
                    if ([cell isKindOfClass:[TGPhotoGridCell class]])
                    {
                        [(TGPhotoGridCell *)cell reloadImagesWithUrl:thumbnailUrl];
                    }
                }
            });
        }
    }
}

- (void)deleteMessagesFromList:(NSArray *)mids
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        std::set<int> midsSet;
        for (NSNumber *nMid in mids)
            midsSet.insert([nMid intValue]);
        
        int itemsCount = _internalListModel.count;
        
        int deletedCount = 0;
        
        for (int i = 0; i < itemsCount; i++)
        {
            TGMessage *message = [_internalListModel objectAtIndex:i];
            if (midsSet.find(message.mid) != midsSet.end())
            {
                [_internalListModel removeObjectAtIndex:i];
                i--;
                itemsCount--;
                
                deletedCount++;
            }
        }
        
        if (deletedCount != 0)
        {
            NSArray *newPresentationListModel = [[NSArray alloc] initWithArray:_internalListModel];
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                _presentationListModel = newPresentationListModel;
                [self updatePlaceholder];
                [self reloadData];
            });
        }
    }];
}

- (void)actorCompleted:(int)resultCode path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:[NSString stringWithFormat:@"/tg/conversations/(%lld)/mediahistory/", _conversationId]])
    {
        bool canLoadMore = false;
        
        if (resultCode == ASStatusSuccess)
        {
            NSDictionary *dict = ((SGraphObjectNode *)result).object;
            NSArray *mediaItems = [dict objectForKey:@"messages"];
            
            std::set<int> existingMids;
            for (TGMessage *message in _internalListModel)
            {
                existingMids.insert(message.mid);
            }
            
            canLoadMore = mediaItems.count != 0;
            
            CGSize imageSelectionsSize = CGSizeZero;
            
            for (TGMessage *message in mediaItems)
            {
                if (existingMids.find(message.mid) != existingMids.end())
                    continue;
                
                NSString *imageUrl = nil;
                TGMediaAttachment *mediaAttachment = nil;
                
                for (TGMediaAttachment *attachment in message.mediaAttachments)
                {
                    if (attachment.type == TGImageMediaAttachmentType)
                    {
                        __unused CGSize size = CGSizeZero;
                        TGImageMediaAttachment *imageAttachment = (TGImageMediaAttachment *)attachment;
                        imageUrl = [imageAttachment.imageInfo closestImageUrlWithSize:imageSelectionsSize resultingSize:&size];
                        mediaAttachment = attachment;
                        break;
                    }
                    else if (attachment.type == TGVideoMediaAttachmentType)
                    {
                        imageUrl = [((TGVideoMediaAttachment *)attachment).thumbnailInfo closestImageUrlWithSize:imageSelectionsSize resultingSize:NULL];
                        mediaAttachment = attachment;
                        break;
                    }
                }
                
                if (imageUrl != nil)
                {
                    message.additionalProperties = [[NSDictionary alloc] initWithObjectsAndKeys:imageUrl, @"url", mediaAttachment, @"attachment", nil];
                    [_internalListModel addObject:message];
                }
            }
            
            [_internalListModel sortUsingComparator:^NSComparisonResult(TGMessage *message1, TGMessage *message2)
            {
                NSTimeInterval delta = message1.date - message2.date;
                if (ABS(delta) < FLT_EPSILON)
                {
                    if (message1.local != message2.local)
                        return NSOrderedSame;
                    return message1.mid < message2.mid ? NSOrderedDescending : NSOrderedAscending;
                }
                else
                    return delta < 0 ? NSOrderedDescending : NSOrderedAscending;
            }];
        }
        
        NSArray *newPresentationListModel = [[NSArray alloc] initWithArray:_internalListModel];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            _canLoadMore = canLoadMore;
            
            _presentationListModel = newPresentationListModel;
            
            [self updatePlaceholder];
            
            _loadingMore = false;
            _loadingActivityIndicator.hidden = true;
            if ([_loadingActivityIndicator isAnimating])
                [_loadingActivityIndicator stopAnimating];
            
            [self reloadData];
        });
    }
}

- (void)updatePlaceholder
{
    if (!_canLoadMore && _presentationListModel.count == 0)
    {
        if (_placeholderContainerView != nil && _placeholderContainerView.alpha > 1.0f - FLT_EPSILON)
            return;
        
        if (_placeholderContainerView == nil)
        {
            UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
            labelView.numberOfLines = 0;
            labelView.lineBreakMode = NSLineBreakByWordWrapping;
            labelView.textAlignment = NSTextAlignmentCenter;
            labelView.text = TGLocalized(@"ConversationMedia.EmptyTitle");
            labelView.font = TGSystemFontOfSize(26.0f);
            labelView.textColor = UIColorRGB(0x999999);
            labelView.backgroundColor = [UIColor whiteColor];
            [labelView sizeToFit];
            
            CGRect containerFrame = CGRectMake(0, 0, labelView.frame.size.width, labelView.frame.size.height);
            
            _placeholderContainerView = [[UIView alloc] initWithFrame:CGRectIntegral(CGRectOffset(containerFrame, (self.view.frame.size.width - containerFrame.size.width) / 2, (self.view.frame.size.height - containerFrame.size.height) / 2))];
            _placeholderContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            
            [_placeholderContainerView addSubview:labelView];
            
            labelView.frame = CGRectIntegral(CGRectOffset(labelView.frame, (_placeholderContainerView.frame.size.width - labelView.frame.size.width) / 2, 0.0f));
        }
        
        [self.view insertSubview:_placeholderContainerView belowSubview:_tableView];
        
        if (!_appearAnimation)
        {
            _placeholderContainerView.alpha = 0.0f;
            [UIView animateWithDuration:0.2 animations:^
            {
                _placeholderContainerView.alpha = 1.0f;
                _tableView.alpha = 0.0f;
            }];
        }
        else
        {
            _placeholderContainerView.alpha = 1.0f;
            _tableView.alpha = 0.0f;
        }
    }
    else if (_placeholderContainerView != nil && _placeholderContainerView.alpha > FLT_EPSILON)
    {
        if (!_appearAnimation)
        {
            [UIView animateWithDuration:0.2 animations:^
            {
                _placeholderContainerView.alpha = 0.0f;
                _tableView.alpha = 1.0f;
            } completion:^(BOOL finished)
            {
                if (finished)
                {
                    [_placeholderContainerView removeFromSuperview];
                    _placeholderContainerView = nil;
                    
                    _tableView.backgroundColor = [UIColor whiteColor];
                }
            }];
        }
        else
        {
            [_placeholderContainerView removeFromSuperview];
            _placeholderContainerView = nil;
            
            _tableView.backgroundColor = [UIColor whiteColor];
        }
    }
}

#pragma mark -

- (void)actionStageActionRequested:(NSString *)action options:(NSDictionary *)options
{
    if ([action isEqualToString:@"openImage"])
    {
        NSValue *nRect = [options objectForKey:@"rectInWindowCoords"];
        NSNumber *nTag = [options objectForKey:@"tag"];
        if (nTag == nil)
            return;
        
        UIView *hideView = nil;
        int messageId = [nTag intValue];
        for (UITableViewCell *cell in [_tableView visibleCells])
        {
            if ([cell isKindOfClass:[TGPhotoGridCell class]])
            {
                TGPhotoGridCell *gridCell = (TGPhotoGridCell *)cell;
                for (NSNumber *nMessageId in gridCell.imageTags)
                {
                    if ([nMessageId intValue] == messageId)
                    {
                        CGRect rect = [gridCell rectForImageWithTag:nTag];
                        if (!CGRectIsNull(rect))
                        {
                            hideView = [gridCell viewForImageWithTag:nTag];
                        }
                        
                        break;
                    }
                }
            }
        }
        
        int mid = [nTag intValue];
        id<TGMediaItem> imageItem = nil;
        
        for (TGMessage *message in _presentationListModel)
        {
            if (message.mid == mid)
            {
                for (TGMediaAttachment *attachment in message.mediaAttachments)
                {
                    if (attachment.type == TGImageMediaAttachmentType)
                    {
                        TGImageMediaAttachment *imageAttachment = (TGImageMediaAttachment *)attachment;
                        
                        imageItem = [[TGMessageMediaItem alloc] initWithMessage:message author:[TGDatabaseInstance() loadUser:(int)message.fromUid] imageInfo:imageAttachment.imageInfo];
                        break;
                    }
                    else if (attachment.type == TGVideoMediaAttachmentType)
                    {
                        TGVideoMediaAttachment *videoAttachment = (TGVideoMediaAttachment *)attachment;
                        
                        imageItem = [[TGMessageMediaItem alloc] initWithMessage:message author:[TGDatabaseInstance() loadUser:(int)message.fromUid] videoAttachment:videoAttachment];
                        break;
                    }
                }
                
                break;
            }
        }
        
        UIImage *image = nil;
        
        if (imageItem != nil)
        {
            NSString *thumbnailUrl = nil;
            
            if ([imageItem imageInfo] != nil)
                thumbnailUrl = [[imageItem imageInfo] closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
            else if ([imageItem videoAttachment] != nil)
                thumbnailUrl = [[[imageItem videoAttachment] thumbnailInfo] closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
            
            if (thumbnailUrl != nil)
                image = [[TGRemoteImageView sharedCache] cachedImage:thumbnailUrl availability:TGCacheBoth];
        }

        if (imageItem != nil && image != nil)
        {
            CGRect windowSpaceFrame = [nRect CGRectValue];
            TGImageViewController *imageViewController = [[TGImageViewController alloc] initWithImageItem:imageItem placeholder:image];
            imageViewController.saveToGallery = _conversationId > INT_MIN && TGAppDelegateInstance.autosavePhotos;
            imageViewController.ignoreSaveToGalleryUid = TGTelegraphInstance.clientUserId;
            imageViewController.groupIdForDownloadingItems = _conversationId;
            if ([imageItem type] == TGMediaItemTypeVideo)
                imageViewController.autoplay = true;
            
            TGTelegraphImageViewControllerCompanion *companion = [[TGTelegraphImageViewControllerCompanion alloc] initWithPeerId:_conversationId firstItemId:mid isEncrypted:_isEncrypted];
            imageViewController.imageViewCompanion = companion;
            companion.imageViewController = imageViewController;
            
            [imageViewController animateAppear:self.view anchorForImage:_tableView fromRect:windowSpaceFrame fromImage:image start:^
            {
                hideView.hidden = true;
            }];
            imageViewController.tags = [[NSMutableDictionary alloc] initWithObjectsAndKeys:nTag, @"tag", nil];
            imageViewController.watcherHandle = _actionHandle;
            
            [TGAppDelegateInstance presentContentController:imageViewController];
        }
    }
    else if ([action isEqualToString:@"hideImage"])
    {
        int messageId = [[options objectForKey:@"messageId"] intValue];
        if (messageId != 0)
        {
            for (UITableViewCell *cell in [_tableView visibleCells])
            {
                if ([cell isKindOfClass:[TGPhotoGridCell class]])
                {
                    TGPhotoGridCell *gridCell = (TGPhotoGridCell *)cell;
                    for (NSNumber *nMessageId in gridCell.imageTags)
                    {
                        if ([nMessageId intValue] == messageId)
                        {
                            CGRect rect = [gridCell rectForImageWithTag:[NSNumber numberWithInt:messageId]];
                            if (!CGRectIsNull(rect))
                            {
                                [gridCell viewForImageWithTag:[NSNumber numberWithInt:messageId]].hidden = [[options objectForKey:@"hide"] boolValue];
                            }
                            
                            break;
                        }
                    }
                }
            }
        }
    }
    else if ([action isEqualToString:@"closeImage"])
    {
        TGImageViewController *imageViewController = [options objectForKey:@"sender"];
        
        int currentMessageId = [[imageViewController currentItemId] intValue];
        
        CGRect targetRect = CGRectZero;
        
        UIView *showView = nil;
        
        UIImage *currentImage = nil;
        
        if (currentMessageId != 0)
        {
            int messageId = currentMessageId;
            for (UITableViewCell *cell in [_tableView visibleCells])
            {
                if ([cell isKindOfClass:[TGPhotoGridCell class]])
                {
                    TGPhotoGridCell *gridCell = (TGPhotoGridCell *)cell;
                    for (NSNumber *nMessageId in gridCell.imageTags)
                    {
                        if ([nMessageId intValue] == messageId)
                        {
                            CGRect rect = [gridCell rectForImageWithTag:[NSNumber numberWithInt:messageId]];
                            if (!CGRectIsNull(rect))
                            {
                                targetRect = [self.view.window convertRect:rect fromView:gridCell];
                                showView = [gridCell viewForImageWithTag:[NSNumber numberWithInt:messageId]];
                                showView.hidden = true;
                                
                                currentImage = [[TGRemoteImageView sharedCache] cachedImage:((TGRemoteImageView *)showView).currentUrl availability:TGCacheBoth];
                                if (currentImage == nil)
                                    currentImage = ((TGRemoteImageView *)showView).currentImage;
                            }
                            
                            break;
                        }
                    }
                }
            }
        }
        
        if (currentImage == nil)
            targetRect = CGRectZero;
        
        id<TGAppManager> appManager = TGAppDelegateInstance;
        
        [imageViewController animateDisappear:self.view anchorForImage:_tableView toRect:targetRect toImage:currentImage swipeVelocity:0.0f completion:^
        {
            [appManager dismissContentController];
            showView.hidden = false;
            UIView *alphaView = [showView viewWithTag:201];
            alphaView.alpha = 0.0f;
            [UIView animateWithDuration:0.3 animations:^
            {
                alphaView.alpha = 1.0f;
            }];
        }];
        
        [((TGNavigationController *)self.navigationController) updateControllerLayout:false];
    }
}

@end
