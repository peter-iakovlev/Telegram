#import "TGExternalGifSearchResultItemView.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGExternalGifSearchResultItem.h"

#import <LegacyComponents/TGCheckButtonView.h>

#import <LegacyComponents/TGImageView.h>

@interface TGExternalGifSearchResultItemView ()
{
    TGCheckButtonView *_checkButton;
    
    SMetaDisposable *_itemSelectedDisposable;
}
@end

@implementation TGExternalGifSearchResultItemView

- (void)dealloc
{
    [_itemSelectedDisposable dispose];
}

- (void)setItem:(TGExternalGifSearchResultItem *)item synchronously:(bool)synchronously
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
        
        __weak TGExternalGifSearchResultItemView *weakSelf = self;
        [_checkButton setSelected:[item.selectionContext isItemSelected:item.selectableMediaItem] animated:false];
        [_itemSelectedDisposable setDisposable:[[item.selectionContext itemInformativeSelectedSignal:item.selectableMediaItem] startWithNext:^(TGMediaSelectionChange *next)
        {
            __strong TGExternalGifSearchResultItemView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if (next.sender != strongSelf->_checkButton)
                [strongSelf->_checkButton setSelected:next.selected animated:next.animated];
        }]];
    }
    
    [self setImageUri:[[NSString alloc] initWithFormat:@"web-search-thumbnail://?url=%@&width=90&height=90", [TGStringUtils stringByEscapingForURL:item.webSearchResult.thumbnailUrl]] synchronously:synchronously];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _checkButton.frame = (CGRect){{self.frame.size.width - _checkButton.frame.size.width - 2.0f, 2.0f}, _checkButton.frame.size};
}

- (void)checkButtonPressed
{
    TGExternalGifSearchResultItem *item = (TGExternalGifSearchResultItem *)self.item;
    
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
