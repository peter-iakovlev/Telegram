#import "TGPreviewMenu.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

#import "TGAppDelegate.h"

#import "TGImageUtils.h"
#import "TGSharedPhotoSignals.h"
#import "TGSharedMediaUtils.h"

#import "TGModernConversationController.h"
#import "TGGenericModernConversationCompanion.h"

#import "TGItemPreviewController.h"
#import "TGItemMenuSheetPreviewView.h"

#import "TGBotContextResults.h"
#import "TGBotContextExternalResult.h"
#import "TGBotContextMediaResult.h"
#import "TGBotContextResultSendMessageText.h"
#import "TGBotContextResultSendMessageGeo.h"

#import "TGMessageEntityUrl.h"
#import "TGWebPageMediaAttachment.h"
#import "TGLocationMediaAttachment.h"

#import "TGRecentGifsSignal.h"

#import "TGEmbedItemView.h"
#import "TGPreviewGifItemView.h"
#import "TGPreviewStickerItemView.h"
#import "TGPreviewPhotoItemView.h"
#import "TGPreviewLocationItemView.h"
#import "TGPreviewAboutItemView.h"
#import "TGPreviewWebPageItemView.h"
#import "TGPreviewAudioItemView.h"
#import "TGPreviewTextItemView.h"
#import "TGMenuSheetButtonItemView.h"

#import "TGStickersMenu.h"
#import "TGOpenInMenu.h"

#import "TGSendMessageSignals.h"

#import "TGProgressWindow.h"

@interface TGItemPreviewHandle ()
{
    UIView *_view;
    UILongPressGestureRecognizer *_gestureRecognizer;
    CGPoint _panStartLocation;
    NSTimeInterval _startTimestamp;
}

@property (nonatomic, weak) TGItemPreviewController *controller;
@property (nonatomic, copy) TGItemPreviewController *(^configurator)(CGPoint gestureLocation);

- (instancetype)initWithView:(UIView *)view;

@end


@implementation TGPreviewMenu

+ (TGItemPreviewController *)presentInParentController:(TGViewController *)parentController
                                     expandImmediately:(bool)expandImmediately
                                                result:(TGBotContextResult *)result
                                               results:(TGBotContextResults *)__unused results
                                            sendAction:(void (^)(TGBotContextResult *result))sendAction
                                    sourcePointForItem:(CGPoint (^)(id item))sourcePointForItem
                                            sourceView:(UIView *)__unused sourceView sourceRect:(CGRect (^)(void))__unused sourceRect
{
    if (TGIsPad())
        return nil;
    
    if ([result.type isEqualToString:@"game"]) {
        return nil;
    }
    
    __block NSArray *mainItems = nil;
    __block NSArray *actions = nil;
    
    TGItemMenuSheetPreviewView *previewView = [[TGItemMenuSheetPreviewView alloc] initWithFrame:CGRectZero];
    previewView.presentActionsImmediately = expandImmediately;
    
    __weak TGItemMenuSheetPreviewView *weakPreviewView = previewView;
    [self itemViewsForResult:result parentController:parentController dismissAction:^(bool commit)
    {
        __strong TGItemMenuSheetPreviewView *strongPreviewView = weakPreviewView;
        if (strongPreviewView == nil)
            return;
        
        if (commit)
            [strongPreviewView performCommit];
        else
            [strongPreviewView performDismissal];
    } completion:^(NSArray *mainItemViews, NSArray *actionItemViews)
    {
        mainItems = mainItemViews;
        actions = actionItemViews;
    }];

    if (mainItems.count == 0)
        return nil;
    
    TGMenuSheetButtonItemView *sendItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"ShareMenu.Send") type:TGMenuSheetButtonTypeSend action:^
    {
        __strong TGItemMenuSheetPreviewView *strongPreviewView = weakPreviewView;
        if (strongPreviewView == nil)
            return;

        sendAction(result);
        [strongPreviewView performCommit];
    }];
    
    TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeDefault action:^
    {
        __strong TGItemMenuSheetPreviewView *strongPreviewView = weakPreviewView;
        if (strongPreviewView == nil)
            return;
        
        [strongPreviewView performDismissal];
    }];
    
    NSMutableArray *finalActions = [[NSMutableArray alloc] init];
    [finalActions addObject:sendItem];
    [finalActions addObjectsFromArray:actions];
    [finalActions addObject:cancelItem];
    
    [previewView setupWithMainItemViews:mainItems actionItemViews:finalActions];
    
    TGItemPreviewController *controller = [[TGItemPreviewController alloc] initWithParentController:parentController previewView:previewView];
    controller.sourcePointForItem = sourcePointForItem;
    
    return controller;
}

+ (void)itemViewsForResult:(TGBotContextResult *)result parentController:(TGViewController *)parentController dismissAction:(void (^)(bool commit))dismissAction completion:(void (^)(NSArray *, NSArray *))completion
{
    CGSize size = CGSizeZero;
    TGDocumentMediaAttachment *document = nil;
    bool isCoub = [self _isBotResultCoub:result size:&size document:&document];
    
    int64_t peerId = 0;
    if ([parentController isKindOfClass:[TGModernConversationController class]])
    {
        TGModernConversationCompanion *companion = ((TGModernConversationController *)parentController).companion;
        peerId = [companion requestPeerId];
    }
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    
    TGMenuSheetButtonItemView *copyItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"ShareMenu.CopyShareLink") type:TGMenuSheetButtonTypeDefault action:nil];
    
    TGMenuSheetButtonItemView *saveGifItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Preview.SaveGif") type:TGMenuSheetButtonTypeDefault action:nil];
    
    if (isCoub)
    {
        NSString *coubUrl = [NSString stringWithFormat:@"https://coub.com/v/%@", result.resultId];
        NSString *coubEmbedUrl = [NSString stringWithFormat:@"https://coub.com/embed/%@", result.resultId];
        
        TGWebPageMediaAttachment *webPage = [[TGWebPageMediaAttachment alloc] init];
        webPage.embedType = @"coub";
        webPage.url = coubUrl;
        webPage.embedUrl = coubEmbedUrl;
        webPage.embedSize = size;
        webPage.document = document;
        
        if ([result isKindOfClass:[TGBotContextMediaResult class]])
            webPage.title = ((TGBotContextMediaResult *)result).title;
        
        SSignal *thumbnailSignal = nil;
        if ([result isKindOfClass:[TGBotContextExternalResult class]])
        {
            CGSize thumbnailSize = TGFitSize(size, CGSizeMake(320, 320));
            thumbnailSignal = [TGSharedPhotoSignals cachedExternalThumbnail:((TGBotContextExternalResult *)result).thumbUrl size:thumbnailSize pixelProcessingBlock:nil cacheVariantKey:@"genericContextCell" threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] diskCache:[TGSharedMediaUtils sharedMediaTemporaryPersistentCache]];
        }
        
        TGPreviewAboutItemView *aboutItem = [[TGPreviewAboutItemView alloc] initWithWebPageAttachment:webPage];
        
        TGEmbedItemView *embedItem = [[TGEmbedItemView alloc] initWithWebPageAttachment:webPage preview:true thumbnailSignal:thumbnailSignal peerId:0 messageId:0];
        embedItem.parentController = parentController;
        [items addObject:embedItem];
        
        __weak TGPreviewAboutItemView *weakAboutItem = aboutItem;
        embedItem.onMetadataLoaded = ^(NSString *title, NSString *subtitle)
        {
            __strong TGPreviewAboutItemView *strongAboutItem = weakAboutItem;
            if (strongAboutItem != nil)
                [strongAboutItem setTitle:title subtitle:subtitle];
        };
        
        [items addObject:aboutItem];
        
        copyItem.action = ^
        {
            TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            progressWindow.skipMakeKeyWindowOnDismiss = true;
            [progressWindow show:true];
            [[UIPasteboard generalPasteboard] setString:coubUrl];
            [progressWindow dismissWithSuccess];
        };
        [actions addObject:copyItem];
    }
    else
    {
        if ([result isKindOfClass:[TGBotContextExternalResult class]])
        {
            TGBotContextExternalResult *concreteResult = (TGBotContextExternalResult *)result;
            size = concreteResult.size;
            bool sizeIsNotZero = (size.width > FLT_EPSILON && size.height > FLT_EPSILON);
            
            TGWebPageMediaAttachment *webPage = [[TGWebPageMediaAttachment alloc] init];
            webPage.url = concreteResult.originalUrl;
            webPage.embedUrl = concreteResult.originalUrl;
            webPage.embedSize = size;
            webPage.title = concreteResult.title;
            webPage.pageDescription = concreteResult.pageDescription;
            
            SSignal *thumbnailSignal = nil;
            if (concreteResult.thumbUrl.length > 0)
            {
                TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
                [imageInfo addImageWithSize:size url:concreteResult.thumbUrl];
                
                CGSize thumbnailSize = TGFitSize(size, CGSizeMake(320, 320));
                thumbnailSignal = [TGSharedPhotoSignals cachedExternalThumbnail:concreteResult.thumbUrl size:thumbnailSize pixelProcessingBlock:nil cacheVariantKey:@"genericContextCell" threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] diskCache:[TGSharedMediaUtils sharedMediaTemporaryPersistentCache]];
            }
            
            if ([result.type isEqualToString:@"video"])
            {
                if (!sizeIsNotZero)
                {
                    if ([webPage.embedUrl rangeOfString:@"instagram"].location != NSNotFound)
                        webPage.embedSize = CGSizeMake(640.0f, 640.0f);
                    else
                        webPage.embedSize = CGSizeMake(1280.0f, 720.0f);
                }
                
                TGEmbedItemView *embedItem = [[TGEmbedItemView alloc] initWithWebPageAttachment:webPage preview:true thumbnailSignal:thumbnailSignal peerId:0 messageId:0];
                embedItem.parentController = parentController;
                [items addObject:embedItem];
                
                if (webPage.title.length > 0)
                {
                    TGPreviewAboutItemView *aboutItem = [[TGPreviewAboutItemView alloc] initWithWebPageAttachment:webPage];
                    [items addObject:aboutItem];
                }
                else
                {
                    embedItem.hasNoAboutInformation = true;
                }
                
                copyItem.action = ^
                {
                    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                    progressWindow.skipMakeKeyWindowOnDismiss = true;
                    [progressWindow show:true];
                    [[UIPasteboard generalPasteboard] setString:webPage.url];
                    [progressWindow dismissWithSuccess];
                };
                [actions addObject:copyItem];
            }
            else if ([result.type isEqualToString:@"gif"] && sizeIsNotZero)
            {
                TGPreviewGifItemView *gifItem = [[TGPreviewGifItemView alloc] initWithBotContextExternalResult:concreteResult];
                [items addObject:gifItem];
            }
            else if ([result.type isEqualToString:@"venue"])
            {
                TGLocationMediaAttachment *location = nil;
                if ([result.sendMessage isKindOfClass:[TGBotContextResultSendMessageGeo class]])
                    location = ((TGBotContextResultSendMessageGeo *)result.sendMessage).location;
                
                TGPreviewLocationItemView *locationItem = [[TGPreviewLocationItemView alloc] initWithLocationAttachment:location];
                [items addObject:locationItem];
                
                if (location.venue != nil)
                {
                    TGPreviewAboutItemView *aboutItem = [[TGPreviewAboutItemView alloc] initWithLocationAttachment:location];
                    [items addObject:aboutItem];
                    
                    if (location.venue.address.length > 0)
                    {
                        TGMenuSheetButtonItemView *copyItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Preview.CopyAddress") type:TGMenuSheetButtonTypeDefault action:^
                        {
                            TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                            progressWindow.skipMakeKeyWindowOnDismiss = true;
                            [progressWindow show:true];
                            [[UIPasteboard generalPasteboard] setString:location.venue.address];
                            [progressWindow dismissWithSuccess];
                        }];
                        [actions addObject:copyItem];
                    }
                }
            }
            else if ([result.type isEqualToString:@"article"])
            {
                TGLocationMediaAttachment *location = nil;
                if ([result.sendMessage isKindOfClass:[TGBotContextResultSendMessageGeo class]])
                    location = ((TGBotContextResultSendMessageGeo *)result.sendMessage).location;
                
                if (location != nil)
                {
                    TGPreviewLocationItemView *locationItem = [[TGPreviewLocationItemView alloc] initWithLocationAttachment:location];
                    [items addObject:locationItem];
                    
                    if (location.venue != nil)
                    {
                        TGPreviewAboutItemView *aboutItem = [[TGPreviewAboutItemView alloc] initWithLocationAttachment:location];
                        [items addObject:aboutItem];
                        
                        if (location.venue.address.length > 0)
                        {
                            TGMenuSheetButtonItemView *copyItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Preview.CopyAddress") type:TGMenuSheetButtonTypeDefault action:^
                            {
                                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                                progressWindow.skipMakeKeyWindowOnDismiss = true;
                                [progressWindow show:true];
                                [[UIPasteboard generalPasteboard] setString:location.venue.address];
                                [progressWindow dismissWithSuccess];
                            }];
                            [actions addObject:copyItem];
                        }
                    }
                }
                else if (webPage.url.length > 0)
                {
                    TGPreviewWebPageItemView *webItem = [[TGPreviewWebPageItemView alloc] initWithWebPage:webPage];
                    [items addObject:webItem];
                    
                    TGMenuSheetButtonItemView *openItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Conversation.FileOpenIn") type:TGMenuSheetButtonTypeDefault action:^
                    {
                        dismissAction(false);
                        
                        TGDispatchAfter(0.2, dispatch_get_main_queue(), ^
                        {
                            [parentController.view endEditing:true];
                            [TGOpenInMenu presentInParentController:parentController menuController:nil title:TGLocalized(@"Map.OpenIn") webPageAttachment:webPage buttonTitle:nil buttonAction:nil sourceView:nil sourceRect:nil barButtonItem:nil];
                        });
                    }];
                    [actions addObject:openItem];
                }
            }
            else if ([result.type isEqualToString:@"photo"])
            {
                NSString *url = concreteResult.originalUrl;
                NSString *thumbnailUrl = concreteResult.thumbUrl;
                if (thumbnailUrl.length == 0)
                    thumbnailUrl = url;

                TGPreviewPhotoItemView *photoItem = [[TGPreviewPhotoItemView alloc] initWithThumbURL:[NSURL URLWithString:thumbnailUrl] url:[NSURL URLWithString:url] size:concreteResult.size];
                [items addObject:photoItem];
            }
            else if ([result.type isEqualToString:@"audio"])
            {
                TGPreviewAudioItemView *audioItem = [[TGPreviewAudioItemView alloc] initWithBotContextResult:result];
                [items addObject:audioItem];
            }
        }
        else if ([result isKindOfClass:[TGBotContextMediaResult class]])
        {
            TGBotContextMediaResult *concreteResult = (TGBotContextMediaResult *)result;
            if ([result.type isEqualToString:@"audio"])
            {
                TGPreviewAudioItemView *audioItem = [[TGPreviewAudioItemView alloc] initWithBotContextResult:result];
                [items addObject:audioItem];
            }
            else if (concreteResult.document != nil) {
                TGDocumentMediaAttachment *document = concreteResult.document;
                
                bool isAnimated = false;
                bool isSticker = false;
                id<TGStickerPackReference> packReference = nil;
                bool isVideo = false;
                bool isAudio = false;

                for (id attribute in document.attributes)
                {
                    if ([attribute isKindOfClass:[TGDocumentAttributeAnimated class]])
                    {
                        isAnimated = true;
                        break;
                    }
                    else if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
                    {
                        packReference = ((TGDocumentAttributeSticker *)attribute).packReference;
                        isSticker = true;
                    }
                    else if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]])
                    {
                        isVideo = true;
                    }
                    else if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]])
                    {
                        isAudio = true;
                    }
                }
            
                if (isAnimated)
                {
                    TGPreviewGifItemView *gifItem = [[TGPreviewGifItemView alloc] initWithDocument:document];
                    [items addObject:gifItem];
                    
                    saveGifItem.action = ^
                    {
                        TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                        progressWindow.skipMakeKeyWindowOnDismiss = true;
                        [progressWindow show:true];
                        [TGRecentGifsSignal addRecentGifFromDocument:document];
                        [progressWindow dismissWithSuccess];
                    };
                    [actions addObject:saveGifItem];
                }
                else if (isVideo)
                {
                    CGSize imageSize = [concreteResult.document pictureSize];
                    if (imageSize.width <= FLT_EPSILON || imageSize.height <= FLT_EPSILON)
                        [concreteResult.document.thumbnailInfo imageUrlForLargestSize:&imageSize];
    
                    CGSize thumbnailSize = TGFitSize(imageSize, CGSizeMake(320, 320));
                    SSignal *thumbnailSignal = [TGSharedPhotoSignals cachedRemoteDocumentThumbnail:concreteResult.document size:thumbnailSize pixelProcessingBlock:nil cacheVariantKey:@"mediaContextPanel" threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] diskCache:[TGSharedMediaUtils sharedMediaTemporaryPersistentCache]];
                    
                    TGEmbedItemView *embedItem = [[TGEmbedItemView alloc] initWithDocumentAttachment:document preview:true thumbnailSignal:thumbnailSignal peerId:0 messageId:0];
                    embedItem.parentController = parentController;
                    embedItem.hasNoAboutInformation = true;
                    [items addObject:embedItem];
                }
                else if (isSticker)
                {
                    TGPreviewStickerItemView *stickerItem = [[TGPreviewStickerItemView alloc] initWithDocument:document];
                    [items addObject:stickerItem];
                    
                    if (packReference != nil)
                    {
                        TGMenuSheetButtonItemView *stickerPackItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"StickerPack.ViewPack") type:TGMenuSheetButtonTypeDefault action:^
                        {
                            dismissAction(false);
                            
                            TGDispatchAfter(0.2, dispatch_get_main_queue(), ^
                            {
                                [parentController.view endEditing:true];
                                
                                void (^sendSticker)(TGDocumentMediaAttachment *) = ^(TGDocumentMediaAttachment *sticker)
                                {
                                    [[TGSendMessageSignals sendRemoteDocumentWithPeerId:peerId replyToMid:0 documentAttachment:sticker] startWithNext:nil];
                                };
                                if (peerId == 0)
                                    sendSticker = nil;
                                
                                [TGStickersMenu presentInParentController:parentController stickerPackReference:packReference showShareAction:false sendSticker:sendSticker stickerPackRemoved:nil stickerPackHidden:nil sourceView:parentController.view centered:true];
                            });
                        }];
                        [actions addObject:stickerPackItem];
                    }
                }
            }
            else if (concreteResult.photo != nil)
            {
                if ([result.type isEqualToString:@"photo"])
                {
                    TGPreviewPhotoItemView *photoItem = [[TGPreviewPhotoItemView alloc] initWithImageAttachment:concreteResult.photo];
                    [items addObject:photoItem];
                }
                else if ([result.type isEqualToString:@"video"] && [result.sendMessage isKindOfClass:[TGBotContextResultSendMessageText class]])
                {
                    TGBotContextResultSendMessageText *textMessage = (TGBotContextResultSendMessageText *)result.sendMessage;
                    
                    TGMessageEntityUrl *urlEntity = nil;
                    for (TGMessageEntity *entity in textMessage.entities)
                    {
                        if ([entity isKindOfClass:[TGMessageEntityUrl class]])
                        {
                            urlEntity = (TGMessageEntityUrl *)entity;
                            break;
                        }
                    }
                    
                    if (urlEntity != nil)
                    {
                        NSString *url = [textMessage.message substringWithRange:urlEntity.range];
                        [concreteResult.photo.imageInfo imageUrlForLargestSize:&size];
                        
                        TGWebPageMediaAttachment *webPage = [[TGWebPageMediaAttachment alloc] init];
                        webPage.url = url;
                        webPage.embedUrl = url;
                        webPage.embedSize = size;
                        webPage.title = concreteResult.title;
                        webPage.pageDescription = concreteResult.resultDescription;
                        
                        CGSize thumbnailSize = TGFitSize(size, CGSizeMake(320, 320));
                        SSignal *thumbnailSignal = [TGSharedPhotoSignals cachedRemoteThumbnail:concreteResult.photo.imageInfo size:thumbnailSize pixelProcessingBlock:nil cacheVariantKey:@"mediaContextPanel" threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] diskCache:[TGSharedMediaUtils sharedMediaTemporaryPersistentCache]];
                        
                        TGEmbedItemView *embedItem = [[TGEmbedItemView alloc] initWithWebPageAttachment:webPage preview:true thumbnailSignal:thumbnailSignal peerId:0 messageId:0];
                        embedItem.parentController = parentController;
                        [items addObject:embedItem];
                        
                        if (webPage.title.length > 0)
                        {
                            TGPreviewAboutItemView *aboutItem = [[TGPreviewAboutItemView alloc] initWithWebPageAttachment:webPage];
                            [items addObject:aboutItem];
                        }
                        else
                        {
                            embedItem.hasNoAboutInformation = true;
                        }
                        
                        copyItem.action = ^
                        {
                            TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                            progressWindow.skipMakeKeyWindowOnDismiss = true;
                            [progressWindow show:true];
                            [[UIPasteboard generalPasteboard] setString:webPage.url];
                            [progressWindow dismissWithSuccess];
                        };
                        [actions addObject:copyItem];
                    }
                }
            }
        }
    }
    
    if (completion != nil)
        completion(items, actions);
}

+ (bool)hasNoPreviewForResult:(TGBotContextResult *)result
{
    if ([result.type isEqualToString:@"audio"] || [result.type isEqualToString:@"game"])
        return true;
    
    if ([result isKindOfClass:[TGBotContextExternalResult class]])
    {
        TGBotContextExternalResult *concreteResult = (TGBotContextExternalResult *)result;
        if (concreteResult.url.length == 0 && concreteResult.thumbUrl.length == 0 && concreteResult.originalUrl.length == 0 && ![concreteResult.type isEqualToString:@"venue"])
            return true;
    }
    
    return false;
}

+ (bool)_isBotResultCoub:(TGBotContextResult *)result size:(CGSize *)size document:(TGDocumentMediaAttachment **)document
{
    bool isCoub = false;
    
    if ([result.type isEqualToString:@"gif"] && ([result.sendMessage isKindOfClass:[TGBotContextResultSendMessageText class]]))
    {
        TGBotContextResultSendMessageText *textMessage = result.sendMessage;
        TGMessageEntityUrl *urlEntity = nil;
        for (TGMessageEntity *entity in textMessage.entities)
        {
            if ([entity isKindOfClass:[TGMessageEntityUrl class]])
            {
                urlEntity = (TGMessageEntityUrl *)entity;
                break;
            }
        }
        
        if (urlEntity != nil)
        {
            NSString *url = [textMessage.message substringWithRange:urlEntity.range];
            if ([url hasPrefix:@"coub.com"])
                isCoub = true;
        }
        
        if (isCoub && size != NULL)
        {
            if ([result isKindOfClass:[TGBotContextMediaResult class]])
            {
                TGDocumentMediaAttachment *resultDocument = ((TGBotContextMediaResult *)result).document;
                if (document != NULL)
                    *document = resultDocument;
                
                for (id attribute in resultDocument.attributes)
                {
                    if ([attribute isKindOfClass:[TGDocumentAttributeImageSize class]])
                    {
                        *size = ((TGDocumentAttributeImageSize *)attribute).size;
                        break;
                    }
                    else if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]])
                    {
                        *size = ((TGDocumentAttributeVideo *)attribute).size;
                        break;
                    }
                }
            }
            else if ([result isKindOfClass:[TGBotContextExternalResult class]])
            {
                *size = ((TGBotContextExternalResult *)result).size;
            }
        }
    }
    
    return isCoub;
}

+ (TGItemPreviewHandle *)setupPreviewControllerForView:(UIView *)view configurator:(TGItemPreviewController *(^)(CGPoint gestureLocation))configurator
{
    TGItemPreviewHandle *handle = [[TGItemPreviewHandle alloc] initWithView:view];
    handle.configurator = configurator;
    
    return handle;
}

@end

@interface TGItemPreviewPressGestureRecognizer : UILongPressGestureRecognizer
{
    NSTimeInterval _previousTimestamp;
    CGPoint _previousPosition;
}

@property (nonatomic, readonly) CGPoint velocity;

@end

@implementation TGItemPreviewHandle

- (instancetype)initWithView:(UIView *)view
{
    self = [super init];
    if (self != nil)
    {
        _view = view;
        
        _gestureRecognizer = [[TGItemPreviewPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePress:)];
        _gestureRecognizer.minimumPressDuration = 0.17;
        [_view addGestureRecognizer:_gestureRecognizer];
    }
    return self;
}

- (void)dealloc
{
    [_view removeGestureRecognizer:_gestureRecognizer];
}

- (NSTimeInterval)requiredPressDuration
{
    return _gestureRecognizer.minimumPressDuration;
}

- (void)setRequiredPressDuration:(NSTimeInterval)requiredPressDuration
{
    _gestureRecognizer.minimumPressDuration = requiredPressDuration;
}

- (void)handlePress:(TGItemPreviewPressGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:_view];
    CGPoint velocity = gestureRecognizer.velocity;
    
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            TGItemPreviewController *controller = self.configurator(location);
            if (controller != nil)
            {
                self.controller = controller;
                
                _panStartLocation = location;
                _startTimestamp = CFAbsoluteTimeGetCurrent();
            }
            else
            {
                gestureRecognizer.enabled = false;
                gestureRecognizer.enabled = true;
            }
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            TGItemPreviewController *controller = self.controller;
            TGItemPreviewView *previewView = controller.previewView;
            [previewView _handlePanOffset:location.y - _panStartLocation.y];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            TGItemPreviewController *controller = self.controller;
            if (fabs(CFAbsoluteTimeGetCurrent() - _startTimestamp) > 0.1)
            {
                TGItemPreviewView *previewView = controller.previewView;
                if (previewView.isLocked)
                    [previewView _handlePressEnded];
                else if (![previewView _maybeLockWithVelocity:velocity.y])
                    [controller dismiss];
            }
            else
            {
                TGDispatchAfter(0.3, dispatch_get_main_queue(), ^
                {
                    [controller dismiss];
                });
            }
        }
            break;
            
        default:
            break;
    }
}

@end


@implementation TGItemPreviewPressGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    _previousTimestamp = event.timestamp;
    
    UITouch *touch = [touches anyObject];
    _previousPosition = [touch locationInView:self.view];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    NSTimeInterval currentTime = event.timestamp;
    NSTimeInterval elapsedTime = currentTime - _previousTimestamp;
    
    _previousTimestamp = currentTime;
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    CGFloat dx = location.x - _previousPosition.x;
    CGFloat dy = location.y - _previousPosition.y;
    
    _velocity = CGPointMake(dx / elapsedTime, dy / elapsedTime);
    
    _previousPosition = location;
}

@end

