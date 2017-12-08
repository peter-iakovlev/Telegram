#import "TGInternalGifSearchResultItemView.h"

#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/TGCheckButtonView.h>

#import <LegacyComponents/TGImageView.h>

#import "TGInternalGifSearchResultItem.h"

#import "TGSharedFileSignals.h"
#import "TGSharedPhotoSignals.h"
#import "TGSharedMediaUtils.h"

@interface TGInternalGifSearchResultItemView ()
{
    TGCheckButtonView *_checkButton;
    
    SMetaDisposable *_itemSelectedDisposable;
}
@end

@implementation TGInternalGifSearchResultItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {        
#ifdef DEBUG
        UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 6.0f, 6.0f)];
        overlayView.backgroundColor = [UIColor greenColor];
        overlayView.alpha = 0.8f;
        overlayView.userInteractionEnabled = false;
        [self addSubview:overlayView];
#endif
    }
    return self;
}

- (void)setItem:(TGInternalGifSearchResultItem *)item synchronously:(bool)synchronously
{
    [super setItem:item synchronously:synchronously];
    
    if (item.selectionContext != nil)
    {
        if (_checkButton == nil)
        {
            _checkButton = [[TGCheckButtonView alloc] initWithStyle:TGCheckButtonStyleMedia];
            [_checkButton addTarget:self action:@selector(checkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_checkButton];
        }
        
        if (_itemSelectedDisposable == nil)
            _itemSelectedDisposable = [[SMetaDisposable alloc] init];
        
        __weak TGInternalGifSearchResultItemView *weakSelf = self;
        [_checkButton setSelected:[item.selectionContext isItemSelected:item.selectableMediaItem] animated:false];
        [_itemSelectedDisposable setDisposable:[[item.selectionContext itemInformativeSelectedSignal:item.selectableMediaItem] startWithNext:^(TGMediaSelectionChange *next)
        {
            __strong TGInternalGifSearchResultItemView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if (next.sender != strongSelf->_checkButton)
                [strongSelf->_checkButton setSelected:next.selected animated:next.animated];
        }]];
    }
    
    if (item.webSearchResult.photo != nil) {
        [self setImageSignal:[TGSharedPhotoSignals cachedRemoteThumbnail:item.webSearchResult.photo.imageInfo size:CGSizeMake(132.0f, 132.0f) pixelProcessingBlock:nil cacheVariantKey:@"gridView" threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] diskCache:[TGSharedMediaUtils sharedMediaTemporaryPersistentCache]]];
    } else {
        CGSize dimensions = CGSizeZero;
        NSString *legacyThumbnailCacheUri = [item.webSearchResult.document.thumbnailInfo closestImageUrlWithSize:CGSizeMake(100.0f, 100.0f) resultingSize:&dimensions pickLargest:true];
        dimensions.width *= 100.0f;
        dimensions.height *= 100.0f;
        
        for (id attribute in item.webSearchResult.document.attributes) {
            if ([attribute isKindOfClass:[TGDocumentAttributeImageSize class]]) {
                dimensions = ((TGDocumentAttributeImageSize *)attribute).size;
                break;
            } else if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
                dimensions = ((TGDocumentAttributeVideo *)attribute).size;
                break;
            }
        }
        
        CGSize thumbnailSize = CGSizeMake(90.0f, 90.0f);
        CGSize renderSize = CGSizeZero;
        if (dimensions.width < dimensions.height)
        {
            renderSize.height = CGFloor((dimensions.height * thumbnailSize.width / dimensions.width));
            renderSize.width = thumbnailSize.width;
        }
        else
        {
            renderSize.width = CGFloor((dimensions.width * thumbnailSize.height / dimensions.height));
            renderSize.height = thumbnailSize.height;
        }
        
        legacyThumbnailCacheUri = [item.webSearchResult.document.thumbnailInfo closestImageUrlWithSize:renderSize resultingSize:&dimensions pickLargest:true];
        
        NSString *filePreviewUri = nil;
        
        if ((item.webSearchResult.document.documentId != 0) && legacyThumbnailCacheUri.length != 0)
        {
            NSMutableString *previewUri = [[NSMutableString alloc] initWithString:@"file-thumbnail://?"];
            if (item.webSearchResult.document.documentId != 0)
                [previewUri appendFormat:@"id=%" PRId64 "", item.webSearchResult.document.documentId];
            
            [previewUri appendString:@"&forceHighQuality=1"];
            
            [previewUri appendFormat:@"&file-name=%@", [item.webSearchResult.document.fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)thumbnailSize.width, (int)thumbnailSize.height, (int)renderSize.width, (int)renderSize.height];
            
            if (legacyThumbnailCacheUri != nil)
                [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUri];
            
            filePreviewUri = previewUri;
        }
        
        [self setImageUri:filePreviewUri synchronously:synchronously];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _checkButton.frame = (CGRect){{self.frame.size.width - _checkButton.frame.size.width - 2.0f, 2.0f}, _checkButton.frame.size};
}

- (void)checkButtonPressed
{
    TGInternalGifSearchResultItem *item = (TGInternalGifSearchResultItem *)self.item;
    
    [_checkButton setSelected:!_checkButton.selected animated:true];
    [item.selectionContext setItem:item.selectableMediaItem selected:_checkButton.selected animated:false sender:_checkButton];
}

- (void)setHidden:(bool)hidden animated:(bool)animated
{
    if (hidden == self.imageView.hidden)
        return;
    
    self.imageView.hidden = hidden;
    
    if (animated)
    {
        if (!hidden)
        {
            for (UIView *view in self.subviews)
            {
                if (view != self.imageView)
                    view.alpha = 0.0f;
            }
        }
        
        [UIView animateWithDuration:0.2 animations:^
        {
            if (!hidden)
            {
                for (UIView *view in self.subviews)
                {
                    if (view != self.imageView)
                        view.alpha = 1.0f;
                }
            }
        }];
    }
    else
    {
        for (UIView *view in self.subviews)
        {
            if (view != self.imageView)
                view.alpha = hidden ? 0.0f : 1.0f;
        }
    }
}

@end
