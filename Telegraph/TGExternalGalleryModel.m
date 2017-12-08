#import "TGExternalGalleryModel.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGGenericPeerMediaGalleryDefaultHeaderView.h"
#import "TGGenericPeerMediaGalleryActionsAccessoryView.h"
#import "TGGenericPeerMediaGalleryDefaultFooterView.h"
#import "TGActionSheet.h"

#import "TGApplication.h"

#import <LegacyComponents/TGProgressWindow.h>
#import "TGInstagramMediaIdSignal.h"

#import <LegacyComponents/TGRemoteImageView.h>

#import "TGAppDelegate.h"

#import "TGGenericPeerMediaGalleryImageItem.h"
#import "TGGenericPeerMediaGalleryVideoItem.h"
#import "TGGenericPeerGalleryGroupItem.h"

#import <LegacyComponents/TGMediaAssetsLibrary.h>

#import "TGWebpageSignals.h"

@interface TGExternalGalleryModel ()
{
    TGWebPageMediaAttachment *_webPage;
    
    TGGenericPeerMediaGalleryDefaultFooterView *_footerView;
    
    NSMutableDictionary *_groupedItemsMap;
    id<SDisposable> _updatePageDisposable;
}

@end

@implementation TGExternalGalleryModel

- (instancetype)initWithWebPage:(TGWebPageMediaAttachment *)webPage peerId:(int64_t)peerId messageId:(int32_t)messageId
{
    self = [super init];
    if (self != nil)
    {
        _webPage = webPage;
        
        bool foundGallery = false;
        bool isInstantGallery = [[webPage.siteName lowercaseString] isEqualToString:@"instagram"] || [[webPage.siteName lowercaseString] isEqualToString:@"twitter"];
        if (isInstantGallery && webPage.instantPage != nil)
        {
            foundGallery = [self setupWithWebPage:_webPage peerId:peerId messageId:messageId];
        }
        
        if (!foundGallery)
        {
            bool isVideo = false;
            for (id attribute in webPage.document.attributes) {
                if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
                    isVideo = true;
                }
            }
            
            id<TGModernGalleryItem> item = nil;
            
            if (isVideo) {
                TGGenericPeerMediaGalleryVideoItem *videoItem = [[TGGenericPeerMediaGalleryVideoItem alloc] initWithDocument:webPage.document peerId:peerId messageId:messageId];
                videoItem.date = webPage.photo.date;
                videoItem.messageId = messageId;
                videoItem.caption = webPage.photo.caption;
                item = videoItem;
            } else {
                TGGenericPeerMediaGalleryImageItem *imageItem = [[TGGenericPeerMediaGalleryImageItem alloc] initWithImageId:webPage.photo.imageId accessHash:webPage.photo.accessHash orLocalId:0 peerId:peerId messageId:messageId legacyImageInfo:webPage.photo.imageInfo embeddedStickerDocuments:webPage.photo.embeddedStickerDocuments hasStickers:webPage.photo.hasStickers];
                imageItem.date = webPage.photo.date;
                imageItem.messageId = messageId;
                if ([webPage.pageType isEqualToString:@"invoice"]) {
                    imageItem.caption = webPage.pageDescription;
                } else {
                    imageItem.caption = webPage.photo.caption;
                }
                item = imageItem;
            }
            
            NSArray *items = @[item];
            
            [self _replaceItems:items focusingOnItem:item];
            
            if (isInstantGallery)
            {
                __weak TGExternalGalleryModel *weakSelf = self;
                _updatePageDisposable = [[[TGWebpageSignals updatedWebpage:webPage] deliverOn:[SQueue mainQueue]] startWithNext:^(TGWebPageMediaAttachment *updatedWebPage) {
                    __strong TGExternalGalleryModel *strongSelf = weakSelf;
                    if (strongSelf != nil && updatedWebPage.instantPage != nil) {
                        strongSelf->_webPage = updatedWebPage;
                        [strongSelf setupWithWebPage:updatedWebPage peerId:peerId messageId:messageId];
                    }
                }];
            }
        }
    }
    return self;
}

- (bool)setupWithWebPage:(TGWebPageMediaAttachment *)webPage peerId:(int64_t)peerId messageId:(int32_t)messageId
{
    int32_t date = 0;
    NSArray *galleryItems = nil;
    bool foundGallery = false;
    for (TGInstantPageBlock *block in webPage.instantPage.blocks)
    {
        if ([block isKindOfClass:[TGInstantPageBlockSlideshow class]])
        {
            galleryItems = ((TGInstantPageBlockSlideshow *)block).items;
        } else if ([block isKindOfClass:[TGInstantPageBlockCollage class]])
        {
            galleryItems = ((TGInstantPageBlockCollage *)block).items;
        }
        else if ([block isKindOfClass:[TGInstantPageBlockAuthorAndDate class]])
        {
            date = ((TGInstantPageBlockAuthorAndDate *)block).date;
        }
    }
    
    if (galleryItems.count > 1)
    {
        foundGallery = true;
        
        _groupedItemsMap = [[NSMutableDictionary alloc] init];
        NSMutableArray *groupItems = [[NSMutableArray alloc] init];
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        int32_t itemId = 0;
        NSString *author = webPage.author.length > 0 ? webPage.author : nil;
        for (TGInstantPageBlock *block in galleryItems)
        {
            if ([block isKindOfClass:[TGInstantPageBlockPhoto class]])
            {
                TGInstantPageBlockPhoto *photoBlock = (TGInstantPageBlockPhoto *)block;
                
                TGImageMediaAttachment *image = webPage.instantPage.images[@(photoBlock.photoId)];
                if (image == nil && webPage.photo.imageId == photoBlock.photoId)
                    image = webPage.photo;
                
                if (image != nil)
                {
                    TGGenericPeerMediaGalleryImageItem *imageItem = [[TGGenericPeerMediaGalleryImageItem alloc] initWithMedia:image localId:0 peerId:peerId messageId:itemId == 0 ? messageId : itemId];
                    imageItem.caption = nil;
                    imageItem.groupItems = groupItems;
                    imageItem.groupedId = 2;
                    imageItem.author = author;
                    imageItem.date = date;
                    
                    [items addObject:imageItem];
                    
                    [groupItems addObject:[[TGGenericPeerGalleryGroupItem alloc] initWithGalleryItem:imageItem]];
                    _groupedItemsMap[@(itemId)] = imageItem;
                }
            }
            else if ([block isKindOfClass:[TGInstantPageBlockVideo class]])
            {
                TGInstantPageBlockVideo *videoBlock = (TGInstantPageBlockVideo *)block;
                
                TGVideoMediaAttachment *video = webPage.instantPage.videos[@(videoBlock.videoId)];
                if (video == nil && webPage.document.documentId == videoBlock.videoId)
                {
                    TGDocumentMediaAttachment *documentAttachment = webPage.document;
                    
                    for (id attribute in documentAttachment.attributes)
                    {
                        if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]])
                        {
                            TGDocumentAttributeVideo *videoAttribute = attribute;
                            
                            video = [[TGVideoMediaAttachment alloc] init];
                            video.videoId = documentAttachment.documentId;
                            video.accessHash = documentAttachment.accessHash;
                            video.duration = videoAttribute.duration;
                            video.dimensions = videoAttribute.size;
                            video.thumbnailInfo = documentAttachment.thumbnailInfo;
                            video.caption = documentAttachment.caption;
                            video.roundMessage = videoAttribute.isRoundMessage;
                            
                            TGVideoInfo *videoInfo = [[TGVideoInfo alloc] init];
                            [videoInfo addVideoWithQuality:1 url:[[NSString alloc] initWithFormat:@"video:%lld:%lld:%d:%d", video.videoId, video.accessHash, documentAttachment.datacenterId, documentAttachment.size] size:documentAttachment.size];
                            video.videoInfo = videoInfo;
                            break;
                        }
                    }
                }
                
                if (video != nil)
                {
                    TGGenericPeerMediaGalleryVideoItem *videoItem = [[TGGenericPeerMediaGalleryVideoItem alloc] initWithVideoMedia:video peerId:peerId messageId:itemId == 0 ? messageId : itemId];
                    videoItem.caption = nil;
                    videoItem.groupItems = groupItems;
                    videoItem.groupedId = 2;
                    videoItem.author = author;
                    videoItem.date = date;
                    
                    [items addObject:videoItem];
                    
                    [groupItems addObject:[[TGGenericPeerGalleryGroupItem alloc] initWithGalleryItem:videoItem]];
                    _groupedItemsMap[@(itemId)] = videoItem;
                }
            }
            itemId--;
        }
        
        [self _replaceItems:items focusingOnItem:items.firstObject];
    }
    return foundGallery;
}

- (UIView<TGModernGalleryDefaultHeaderView> *)createDefaultHeaderView
{
    if (self.items.count < 2)
        return nil;
    
    __weak TGExternalGalleryModel *weakSelf = self;
    return [[TGGenericPeerMediaGalleryDefaultHeaderView alloc] initWithPositionAndCountBlock:^(id<TGModernGalleryItem> item, NSUInteger *position, NSUInteger *count)
    {
        __strong TGExternalGalleryModel *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (position != NULL)
            {
                NSUInteger index = [strongSelf.items indexOfObject:item];
                if (index != NSNotFound)
                    *position = index;
            }
            if (count != NULL)
                *count = strongSelf.items.count;
        }
    }];
}

- (UIView<TGModernGalleryDefaultFooterView> *)createDefaultFooterView
{
    if (self.items.count < 2)
        return nil;
    
    _footerView = [[TGGenericPeerMediaGalleryDefaultFooterView alloc] init];
    __weak TGExternalGalleryModel *weakSelf = self;
    _footerView.groupItemChanged = ^(TGGenericPeerGalleryGroupItem *item, bool synchronously)
    {
        __strong TGExternalGalleryModel *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        id<TGModernGalleryItem> galleryItem = strongSelf->_groupedItemsMap[@(item.keyId)];
        [strongSelf _focusOnItem:(id<TGModernGalleryItem>)galleryItem synchronously:synchronously];
    };
    
    return _footerView;
}

- (void)_interItemTransitionProgressChanged:(CGFloat)progress
{
    [_footerView setInterItemTransitionProgress:progress];
}

- (UIView<TGModernGalleryDefaultFooterAccessoryView> *)createDefaultLeftAccessoryView
{
    if ([[_webPage pageType] isEqualToString:@"invoice"]) {
        return nil;
    }
    
    TGGenericPeerMediaGalleryActionsAccessoryView *accessoryView = [[TGGenericPeerMediaGalleryActionsAccessoryView alloc] init];
    __weak TGExternalGalleryModel *weakSelf = self;
    accessoryView.action = ^(id<TGModernGalleryItem> item)
    {
        if ([item isKindOfClass:[TGGenericPeerMediaGalleryImageItem class]] || [item isKindOfClass:[TGGenericPeerMediaGalleryVideoItem class]])
        {
            __strong TGExternalGalleryModel *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                UIView *actionSheetView = nil;
                if (strongSelf.actionSheetView)
                    actionSheetView = strongSelf.actionSheetView();
                
                if (actionSheetView != nil)
                {
                    NSMutableArray *actions = [[NSMutableArray alloc] init];
                
                    NSString *openInText = TGLocalized(@"Web.OpenExternal");
                    if ([[strongSelf->_webPage.siteName lowercaseString] isEqualToString:@"instagram"])
                        openInText = TGLocalized(@"Preview.OpenInInstagram");
                    
                    if ([item isKindOfClass:[TGGenericPeerMediaGalleryImageItem class]]) {
                        NSString *lowercaseUrl = strongSelf->_webPage.url.lowercaseString;
                        if (![lowercaseUrl hasPrefix:@"http://t.me/"] && ![lowercaseUrl hasPrefix:@"https://t.me/"] && ![lowercaseUrl hasPrefix:@"http://t.me/"] && ![lowercaseUrl hasPrefix:@"https://t.me/"]) {
                            [actions addObject:[[TGActionSheetAction alloc] initWithTitle:openInText action:@"open" type:TGActionSheetActionTypeGeneric]];
                        }
                    }
                    
                    NSString *imageUrl = [strongSelf->_webPage.photo.imageInfo closestImageUrlWithSize:CGSizeMake(1000.0f, 1000.0f) resultingSize:NULL];
                    
                    NSData *data = nil;
                    
                    static NSString *filesDirectory = nil;
                    static dispatch_once_t onceToken;
                    dispatch_once(&onceToken, ^ {
                        filesDirectory = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"files"];
                    });
                    
                    if (strongSelf->_webPage.photo.imageId != 0)
                    {
                        NSString *photoDirectoryName = nil;
                        photoDirectoryName = [[NSString alloc] initWithFormat:@"image-remote-%" PRIx64 "", (int64_t)strongSelf->_webPage.photo.imageId];
                        NSString *photoDirectory = [filesDirectory stringByAppendingPathComponent:photoDirectoryName];
                    
                        NSString *imagePath = [photoDirectory stringByAppendingPathComponent:@"image.jpg"];
                        data = [NSData dataWithContentsOfFile:imagePath options:NSDataReadingMappedIfSafe error:NULL];
                    }
                    
                    NSString *videoPath = nil;
                    if ([item isKindOfClass:[TGGenericPeerMediaGalleryVideoItem class]]) {
                        videoPath = ((TGGenericPeerMediaGalleryVideoItem *)item).filePath;
                    }
                    
                    if (data == nil) {
                        data = [NSData dataWithContentsOfFile:[[TGRemoteImageView sharedCache] pathForCachedData:imageUrl] options:NSDataReadingMappedIfSafe error:NULL];
                    }
                    
                    if (data != nil || (videoPath != nil && [[NSFileManager defaultManager] fileExistsAtPath:videoPath isDirectory:NULL])) {
                        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Preview.SaveToCameraRoll") action:@"save" type:TGActionSheetActionTypeGeneric]];
                    }
                    
                    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
                    
                    if (actions.count > 1) {
                        [[[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(__unused id target, NSString *action)
                        {
                            if ([action isEqualToString:@"open"])
                            {
                                __strong TGExternalGalleryModel *strongSelf = weakSelf;
                                if (strongSelf != nil)
                                {
                                    NSString *instagramShortcode = [strongSelf instagramShortcodeFromText:strongSelf->_webPage.url];
                                    if (instagramShortcode.length != 0)
                                    {
                                        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://media?id=1"]])
                                        {
                                            TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                                            [progressWindow show:true];
                                            [[[[TGInstagramMediaIdSignal instagramMediaIdForShortcode:instagramShortcode] deliverOn:[SQueue mainQueue]] onDispose:^
                                            {
                                                [progressWindow dismiss:true];
                                            }] startWithNext:^(NSString *mediaId)
                                            {
                                                NSURL *clientUrl = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"instagram://media?id=%@", mediaId]];
                                                if ([[UIApplication sharedApplication] canOpenURL:clientUrl])
                                                {
                                                    [[UIApplication sharedApplication] openURL:clientUrl];
                                                    return;
                                                }
                                            } error:^(__unused id error)
                                            {
                                                __strong TGExternalGalleryModel *strongSelf = weakSelf;
                                                if (strongSelf != nil)
                                                {
                                                    [(TGApplication *)[UIApplication sharedApplication] openURL:[NSURL URLWithString:strongSelf->_webPage.url] forceNative:true];
                                                }
                                            } completed:nil];
                                        }
                                        else
                                        {
                                            __strong TGExternalGalleryModel *strongSelf = weakSelf;
                                            if (strongSelf != nil)
                                            {
                                                strongSelf.dismiss(false, false);
                                                TGDispatchAfter(0.35, dispatch_get_main_queue(), ^
                                                {
                                                    [(TGApplication *)[UIApplication sharedApplication] openURL:[NSURL URLWithString:strongSelf->_webPage.url] forceNative:true];
                                                });
                                            }
                                        }
                                        return;
                                    }
                                    
                                    strongSelf.dismiss(false, false);
                                    TGDispatchAfter(0.35, dispatch_get_main_queue(), ^
                                    {
                                        [(TGApplication *)[UIApplication sharedApplication] openURL:[NSURL URLWithString:strongSelf->_webPage.url] forceNative:true];
                                    });
                                    
                                    if (strongSelf.dismissWhenReady) {
                                        strongSelf.dismissWhenReady(false);
                                    }
                                }
                            }
                            else if ([action isEqualToString:@"save"]) {
                                if ([item isKindOfClass:[TGGenericPeerMediaGalleryImageItem class]]) {
                                    [strongSelf _saveImageDataToCameraRoll:data];
                                } else {
                                    [strongSelf _saveVideoToCameraRoll:videoPath];
                                }
                            }
                        } target:strongSelf] showInView:actionSheetView];
                    }
                }
            }
        }
    };
    return accessoryView;
}

- (void)_saveImageDataToCameraRoll:(NSData *)data
{
    if (data == nil)
        return;
    
    if (![[[LegacyComponentsGlobals provider] accessChecker] checkPhotoAuthorizationStatusForIntent:TGPhotoAccessIntentSave alertDismissCompletion:nil])
        return;
    
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [progressWindow show:true];
    
    [[[[TGMediaAssetsLibrary sharedLibrary] saveAssetWithImageData:data] deliverOn:[SQueue mainQueue]] startWithNext:nil error:^(__unused id error)
    {
        [[[LegacyComponentsGlobals provider] accessChecker] checkPhotoAuthorizationStatusForIntent:TGPhotoAccessIntentSave alertDismissCompletion:nil];
        [progressWindow dismiss:true];
    } completed:^
    {
        [progressWindow dismissWithSuccess];
    }];
}


- (void)_saveVideoToCameraRoll:(NSString *)filePath
{
    if (filePath == nil)
        return;
    
    if (![[[LegacyComponentsGlobals provider] accessChecker] checkPhotoAuthorizationStatusForIntent:TGPhotoAccessIntentSave alertDismissCompletion:nil])
        return;
    
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [progressWindow show:true];
    
    [[[[TGMediaAssetsLibrary sharedLibrary] saveAssetWithVideoAtUrl:[NSURL fileURLWithPath:filePath]] deliverOn:[SQueue mainQueue]] startWithNext:nil error:^(__unused id error)
     {
         [[[LegacyComponentsGlobals provider] accessChecker] checkPhotoAuthorizationStatusForIntent:TGPhotoAccessIntentSave alertDismissCompletion:nil];
         [progressWindow dismiss:true];
     } completed:^
     {
         [progressWindow dismissWithSuccess];
     }];
}

- (NSString *)instagramShortcodeFromText:(NSString *)text
{
    NSArray *prefixes = @
    [
     @"http://instagram.com/p/",
     @"https://instagram.com/p/",
     @"http://www.instagram.com/p/",
     @"https://www.instagram.com/p/"
     ];
    
    NSString *currentPrefix = nil;
    for (NSString *prefix in prefixes)
    {
        if ([text hasPrefix:prefix])
        {
            currentPrefix = prefix;
            break;
        }
    }
    
    if (currentPrefix != nil)
    {
        NSString *prefix = currentPrefix;
        int length = (int)text.length;
        bool badCharacters = false;
        int slashCount = 0;
        
        NSUInteger excl = [text rangeOfString:@"?"].location;
        if (excl != NSNotFound)
            length = (int)excl;
        
        for (int i = (int)prefix.length; i < length; i++)
        {
            unichar c = [text characterAtIndex:i];
            if ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_' || c == '/' || c == '-')
            {
                if (c == '/')
                {
                    if (slashCount >= 2)
                    {
                        badCharacters = true;
                        break;
                    }
                    slashCount++;
                }
            }
            else
            {
                badCharacters = true;
                break;
            }
        }
        
        if (!badCharacters)
        {
            NSString *shortcode = [text substringFromIndex:prefix.length];
            if ([shortcode hasSuffix:@"/"])
                shortcode = [shortcode substringToIndex:shortcode.length - 1];
            
            return shortcode;
        }
    }
    
    return nil;
}

@end
