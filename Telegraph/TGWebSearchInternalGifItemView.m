#import "TGWebSearchInternalGifItemView.h"

#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/TGCheckButtonView.h>

#import <LegacyComponents/TGImageView.h>

#import "TGWebSearchInternalGifItem.h"

@interface TGWebSearchInternalGifItemView ()
{
    TGCheckButtonView *_checkButton;
    
    SMetaDisposable *_itemSelectedDisposable;
}
@end

@implementation TGWebSearchInternalGifItemView

- (void)dealloc
{
    [_itemSelectedDisposable dispose];
}

- (void)setItem:(TGWebSearchInternalGifItem *)item synchronously:(bool)synchronously
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
        
        __weak TGWebSearchInternalGifItemView *weakSelf = self;
        [_checkButton setSelected:[item.selectionContext isItemSelected:item.selectableMediaItem] animated:false];
        [_itemSelectedDisposable setDisposable:[[item.selectionContext itemInformativeSelectedSignal:item.selectableMediaItem] startWithNext:^(TGMediaSelectionChange *next)
        {
            __strong TGWebSearchInternalGifItemView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if (next.sender != strongSelf->_checkButton)
                [strongSelf->_checkButton setSelected:next.selected animated:next.animated];
        }]];
    }
    
    CGSize dimensions = CGSizeZero;
    NSString *legacyThumbnailCacheUri = [item.webSearchResult.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:&dimensions];
    dimensions.width *= 10.0f;
    dimensions.height *= 10.0f;
    
    NSString *filePreviewUri = nil;
    
    if ((item.webSearchResult.documentId != 0) && legacyThumbnailCacheUri.length != 0)
    {
        NSMutableString *previewUri = [[NSMutableString alloc] initWithString:@"file-thumbnail://?"];
        if (item.webSearchResult.documentId != 0)
            [previewUri appendFormat:@"id=%" PRId64 "", item.webSearchResult.documentId];
        
        [previewUri appendFormat:@"&file-name=%@", [item.webSearchResult.fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
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
        
        [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)thumbnailSize.width, (int)thumbnailSize.height, (int)renderSize.width, (int)renderSize.height];
        
        if (legacyThumbnailCacheUri != nil)
            [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUri];
        
        filePreviewUri = previewUri;
    }
    
    [self setImageUri:filePreviewUri synchronously:synchronously];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _checkButton.frame = (CGRect){{self.frame.size.width - _checkButton.frame.size.width - 2.0f, 2.0f}, _checkButton.frame.size};
}

- (void)checkButtonPressed
{
    TGWebSearchInternalGifItem *item = (TGWebSearchInternalGifItem *)self.item;
    
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
